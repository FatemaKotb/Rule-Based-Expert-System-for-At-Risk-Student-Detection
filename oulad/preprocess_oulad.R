# preprocess_oulad.R
# Creates a processed OULAD CSV for the Python notebook.

# install.packages("ouladFormat")  # Run once if needed
library(ouladFormat)


# -----------------------------
# Configuration
# -----------------------------

# OULAD anonymizes courses as module codes.
# A presentation is one offering of a module; BBB / 2013J is one manageable course offering.
MODULE <- "BBB"
PRESENTATION <- "2013J"

# Use the first 14 weeks for early prediction.
# This captures early activity while still predicting before the final outcome.
WEEK_BEGIN <- 1
WEEK_END <- 14

# Include the main feature groups for student-risk prediction.
USE_DEMOGRAPHICS <- TRUE
USE_REGISTRATION <- TRUE
USE_ASSESSMENT <- TRUE

# Aggregate VLE clicks by activity type first.
# These activity columns are later summed into one total_clicks feature.
VLE_AGGREGATION <- "activity"

# Keep raw click counts so total_clicks is easy to interpret.
VLE_CLICK_FORMAT <- "total"

# Remove repeat attempts to focus on first-attempt student behavior.
REPEAT_STUDENTS <- "remove"

# Keep withdrawn students because withdrawal is part of the at-risk outcome.
WITHDRAWN_STUDENTS <- "keep"

# FALSE treats missing assessment values as zero in weighted assessment calculations.
# This is useful when missing assessment data can indicate non-submission.
REMOVE_MISSING_ASSESSMENTS <- FALSE

# Use the real OULAD data, not the small example dataset included with the package.
USE_EXAMPLE_DATA <- FALSE

OUTPUT_FILE <- "data/oulad_processed.csv"


# -----------------------------
# Build Processed Dataset
# -----------------------------

oulad_output <- combined_dataset(
  module = MODULE,
  presentation = PRESENTATION,
  demographics = USE_DEMOGRAPHICS,
  registration = USE_REGISTRATION,
  assessment = USE_ASSESSMENT,
  VLE = VLE_AGGREGATION,
  VLE_clicks = VLE_CLICK_FORMAT,
  week_begin = WEEK_BEGIN,
  week_end = WEEK_END,
  repeat_students = REPEAT_STUDENTS,
  withdrawn_students = WITHDRAWN_STUDENTS,
  na.rm = REMOVE_MISSING_ASSESSMENTS,
  example_data = USE_EXAMPLE_DATA
)


# -----------------------------
# Extract Student-Level Table
# -----------------------------

processed_data <- oulad_output$dataset_combined

if (!is.data.frame(processed_data)) {
  stop("dataset_combined was not returned as a dataframe.")
}


# -----------------------------
# Aggregate VLE Clicks
# -----------------------------

vle_click_columns <- c(
  "forumng",
  "glossary",
  "homepage",
  "oucollaborate",
  "oucontent",
  "quiz",
  "resource",
  "sharedsubpage",
  "subpage",
  "url"
)

vle_click_columns <- intersect(vle_click_columns, names(processed_data))

if (length(vle_click_columns) > 0) {
  processed_data$total_clicks <- rowSums(
    processed_data[, vle_click_columns],
    na.rm = TRUE
  )

  processed_data <- processed_data[
    ,
    !(names(processed_data) %in% vle_click_columns)
  ]
} else {
  processed_data$total_clicks <- 0
}


# -----------------------------
# Remove Individual Assessment Columns
# -----------------------------

# Keep average_CA_score as the assessment-performance summary.
# Drop raw numeric assessment ID columns because they are less interpretable in ES rules.
assessment_id_columns <- names(processed_data)[
  grepl("^[0-9]+$", names(processed_data))
]

processed_data <- processed_data[
  ,
  !(names(processed_data) %in% assessment_id_columns)
]


# -----------------------------
# Remove Unused or Leaky Columns
# -----------------------------

columns_to_drop <- c(
  "id_student",            # Identifier, not a predictive feature.
  "code_module",           # Constant because MODULE is fixed.
  "code_presentation",     # Constant because PRESENTATION is fixed.
  "num_of_prev_attempts",  # Constant after removing repeat attempts.
  "date_unregistration"    # Leaks withdrawal information.
)

columns_to_drop <- intersect(columns_to_drop, names(processed_data))

processed_data <- processed_data[
  ,
  !(names(processed_data) %in% columns_to_drop)
]


# -----------------------------
# Reorder Columns
# -----------------------------

# Group columns by source/category so the final CSV is easier to inspect.
registration_columns <- c(
  "date_registration"
)

demographic_columns <- c(
  "gender",
  "region",
  "highest_education",
  "imd_band",
  "age_band",
  "studied_credits",
  "disability"
)

assessment_columns <- c(
  "average_CA_score"
)

engagement_columns <- c(
  "total_clicks"
)

target_column <- c(
  "final_result"
)

ordered_columns <- c(
  registration_columns,
  demographic_columns,
  assessment_columns,
  engagement_columns,
  target_column
)

# Keep only columns that exist in the processed dataset.
ordered_columns <- intersect(ordered_columns, names(processed_data))

processed_data <- processed_data[, ordered_columns]


# -----------------------------
# Export
# -----------------------------

dir.create(
  dirname(OUTPUT_FILE),
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  processed_data,
  OUTPUT_FILE,
  row.names = FALSE
)

cat("Saved:", OUTPUT_FILE, "\n")
cat("Rows:", nrow(processed_data), "\n")
cat("Columns:", ncol(processed_data), "\n")
cat("Columns kept:\n")
for (column_name in names(processed_data)) {
  cat("-", column_name, "\n")
}