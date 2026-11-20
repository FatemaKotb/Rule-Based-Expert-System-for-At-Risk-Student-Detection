import csv
from dataclasses import dataclass, field
from pathlib import Path
import re
import textwrap

import matplotlib.pyplot as plt


@dataclass
class Node:
    label: str
    children: dict[str, "Node"] = field(default_factory=dict)
    prediction: str | None = None
    confidence: float | None = None
    samples: int | None = None


def parse_conditions(conditions: str) -> list[str]:
    return [part.strip() for part in conditions.split(" AND ") if part.strip()]


def insert_rule(root: Node, conditions: list[str], prediction: str, confidence: float, samples: int) -> None:
    current = root
    for cond in conditions:
        if cond not in current.children:
            current.children[cond] = Node(label=cond)
        current = current.children[cond]
    current.prediction = prediction
    current.confidence = confidence
    current.samples = samples


def count_leaves(node: Node) -> int:
    if not node.children:
        return 1
    return sum(count_leaves(child) for child in node.children.values())


def assign_positions(node: Node, depth: int, x_left: float, x_right: float, positions: dict[int, tuple[float, float]], labels: dict[int, str], ids: dict[int, Node], next_id: list[int]) -> int:
    node_id = next_id[0]
    next_id[0] += 1

    x_center = (x_left + x_right) / 2.0
    y = -depth

    positions[node_id] = (x_center, y)
    labels[node_id] = node.label
    ids[node_id] = node

    if node.children:
        span = x_right - x_left
        running_left = x_left
        total_leaves = count_leaves(node)

        for child in node.children.values():
            child_leaves = count_leaves(child)
            child_span = span * (child_leaves / total_leaves)
            child_left = running_left
            child_right = running_left + child_span
            assign_positions(child, depth + 1, child_left, child_right, positions, labels, ids, next_id)
            running_left = child_right

    return node_id


def gather_edges(parent_id: int, node: Node, node_id_lookup: dict[int, Node], edges: list[tuple[int, int]]) -> None:
    for child in node.children.values():
        child_id = next(k for k, v in node_id_lookup.items() if v is child)
        edges.append((parent_id, child_id))
        gather_edges(child_id, child, node_id_lookup, edges)


def wrap_label(text: str, width: int = 26) -> str:
    return "\n".join(textwrap.wrap(text, width=width, break_long_words=False))


def format_condition_label(text: str) -> str:
    """Format split conditions over two lines for readability."""
    pattern = r"^(.*?)\s*(<=|>=|<|>|is not|is)\s*(.*)$"
    match = re.match(pattern, text)
    if match:
        feature, op, value = match.groups()
        feature = feature.strip()
        rhs = f"{op} {value.strip()}"
        return f"{feature}\n{rhs}"

    return wrap_label(text, width=22)


def render_tree(csv_path: Path, out_png: Path) -> None:
    root = Node(label="Start")

    with csv_path.open("r", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            conds = parse_conditions(row["conditions"])
            prediction = row["prediction"].strip()
            confidence = float(row["confidence"])
            samples = int(row["training_samples"])
            insert_rule(root, conds, prediction, confidence, samples)

    positions: dict[int, tuple[float, float]] = {}
    labels: dict[int, str] = {}
    node_lookup: dict[int, Node] = {}
    next_id = [0]

    root_id = assign_positions(
        node=root,
        depth=0,
        x_left=0.0,
        x_right=1.0,
        positions=positions,
        labels=labels,
        ids=node_lookup,
        next_id=next_id,
    )

    edges: list[tuple[int, int]] = []
    gather_edges(root_id, root, node_lookup, edges)

    max_depth = max(-y for _, y in positions.values())
    fig_width = max(18, count_leaves(root) * 1.35)
    fig_height = max(12, (max_depth + 2) * 2.15)

    fig, ax = plt.subplots(figsize=(fig_width, fig_height), dpi=150)

    for parent_id, child_id in edges:
        x1, y1 = positions[parent_id]
        x2, y2 = positions[child_id]
        ax.plot([x1, x2], [y1, y2], color="#5c6b73", linewidth=1.2, zorder=1)

    for node_id, (x, y) in positions.items():
        node = node_lookup[node_id]
        is_leaf = not node.children

        if is_leaf and node.prediction is not None:
            pred = node.prediction
            conf = node.confidence if node.confidence is not None else 0.0
            smp = node.samples if node.samples is not None else 0
            label = f"{pred}\nconf={conf:.3f}\nsamples={smp}"
            if pred.lower().startswith("at risk"):
                face = "#f8d7da"
            else:
                face = "#d1e7dd"
        else:
            label = format_condition_label(labels[node_id])
            face = "#dbeafe" if node_id != root_id else "#fde68a"

        ax.text(
            x,
            y,
            label,
            ha="center",
            va="center",
            fontsize=10,
            bbox={"boxstyle": "round,pad=0.3", "facecolor": face, "edgecolor": "#334155", "linewidth": 0.8},
            zorder=2,
        )

    ax.set_title("Rule-Derived Decision Tree", fontsize=18, pad=24)
    ax.axis("off")
    plt.tight_layout()

    out_png.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_png, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    base = Path(__file__).resolve().parent
    csv_file = base / "oulad_generated_expert_system_rules.csv"
    out_file = base / "oulad_decision_tree_from_rules.png"
    render_tree(csv_file, out_file)
    print(f"Saved: {out_file}")
