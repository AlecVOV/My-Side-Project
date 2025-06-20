# R Script for BUSA8090 – Data and Visualisation for Business (Assignment 2 - Part 1)
# This script performs data preprocessing on the `crash_incidents.csv` dataset.
# The steps are:
# 1. Load the data
# 2. Clean missing values
# 3. Convert date columns
# 4. Handle outliers
# 5. Reduce categorical variables with too many categories
# 6. Create additional features
# 7. Export the cleaned data to CSV

# --- Setup ---
# Install packages if they are not already installed
install.packages(c("data.table", "dplyr", "lubridate", "ggplot2", "DescTools", "R.utils"))
# Import required libraries
library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)
library(DescTools) 
library(R.utils)   


theme_set(theme_bw()) 

# --- 1. Loading Data ---
start_time <- proc.time()
print("Starting data preprocessing:")

# Define file paths
input_file <- "crash_incidents.csv"
output_file <- "crash_incidents_cleaned.csv"

# Check if input file exists
if (!file.exists(input_file)) {
  stop(paste("Input file not found:", input_file))
}

# Check file size
file_size_bytes <- file.info(input_file)$size
file_size_mb <- file_size_bytes / (1024 * 1024)
print(sprintf("Input file size: %.2f MB", file_size_mb))
print(sprintf("Reading the file: ", input_file))

# Count total rows in the file (can be slow for very large files)
print("Counting total rows (this may take a moment)")
df <- fread(input_file)
total_rows <- nrow(df) # Get rows after loading
print(sprintf("Total rows in dataset: %s", format(total_rows, big.mark = ",")))
print(sprintf("Loaded %d rows for processing", nrow(df)))

# Display initial data sample (equivalent to df.head())
print("Initial data sample:")
print(head(df))

# --- 2. Exploring Dataset Structure ---
print("Dataset Information:")
print(sprintf("Number of rows: %d", nrow(df)))
print(sprintf("Number of columns: %d", ncol(df)))

print("Data Types:")
# data.table's print method often shows types, or use str() or sapply
str(df, list.len = ncol(df)) # More detailed structure

# Check for missing values
missing_values <- sapply(df, function(x) sum(is.na(x)))
missing_percent <- (missing_values / nrow(df)) * 100

missing_df <- data.frame(
  Column = names(missing_values),
  Missing_Values = missing_values,
  Percentage = missing_percent,
  row.names = NULL
)

# Display columns with missing values, sorted by most missing
missing_df <- missing_df[missing_df$Missing_Values > 0, ]
missing_df <- missing_df[order(-missing_df$Missing_Values), ]
print("Columns with Missing Values:")
print(missing_df)

# --- 3. Data Cleaning ---
print("Handling missing values")

# Identify columns with significant missing data (>50%)
missing_threshold <- 0.5
cols_to_drop <- names(df)[sapply(df, function(x) mean(is.na(x))) > missing_threshold]

if (length(cols_to_drop) > 0) {
  print(sprintf("Dropping %d columns with >%.0f%% missing values:", length(cols_to_drop), missing_threshold * 100))
  print(cols_to_drop)
  df <- df[, !..cols_to_drop] # data.table way to drop columns
}

# For remaining columns with missing values:
# - Fill numeric columns with median
# - Fill categorical columns with mode

# Get numeric column names
numeric_cols <- names(df)[sapply(df, is.numeric)]
for (col in numeric_cols) {
  if (any(is.na(df[[col]]))) {
    median_val <- median(df[[col]], na.rm = TRUE)
    # Using data.table's set for efficiency
    set(df, i = which(is.na(df[[col]])), j = col, value = median_val)
    print(sprintf("  - Filled missing values in %s with median (%.2f)", col, median_val))
  }
}

# Get character/factor column names
# Note: fread might read some seemingly categorical columns as numeric if possible.
# Be sure about your column types.
categorical_cols <- names(df)[sapply(df, function(x) is.character(x) || is.factor(x))]
# Custom function to get mode, handling cases where Mode might return multiple or NA
get_mode_val <- function(x) {
  if (all(is.na(x))) return("Unknown") # All values are NA
  modes <- DescTools::Mode(x, na.rm = TRUE)
  if (length(modes) == 0 || is.na(modes[1])) return("Unknown") # No mode found or mode is NA
  return(as.character(modes[1])) # Return the first mode as character
}

for (col in categorical_cols) {
  if (any(is.na(df[[col]]))) {
    mode_val <- get_mode_val(df[[col]])
    set(df, i = which(is.na(df[[col]])), j = col, value = mode_val)
    print(sprintf("  - Filled missing values in %s with mode ('%s')", col, mode_val))
  }
}

# Check remaining missing values
remaining_missing <- sum(sapply(df, function(x) sum(is.na(x))))
print(sprintf("Remaining missing values after cleaning: %d", remaining_missing))


# --- 4. Converting Date Columns ---
print("Converting date columns...")

# Identify columns with 'date' or 'time' in their name (case-insensitive)
date_col_candidates <- names(df)[grepl("date|time", names(df), ignore.case = TRUE)]

# Attempt to convert these columns
# lubridate's parse_date_time is flexible.
# Define expected formats if known, otherwise it tries common ones.
# Example: formats = c("Ymd HMS", "Y-m-d H:M:S", "m/d/Y H:M", "d-M-Y")
for (col in date_col_candidates) {
  # Check if column still exists and is not already POSIXct/Date
  if (col %in% names(df) && !is.POSIXct(df[[col]]) && !is.Date(df[[col]])) {
    # Try to parse; this is a general attempt. For specific formats, be more explicit.
    # Important: Ensure the column is character before trying to parse if it's factor
    if(is.factor(df[[col]])) df[, (col) := as.character(get(col))]
    # Store original NAs to avoid issues if all are NA after failed conversion attempts
    original_NAs <- is.na(df[[col]])
    # Attempt conversion
    # Using suppressWarnings as parse_date_time can be verbose with failures
    parsed_dates <- suppressWarnings(parse_date_time(df[[col]], orders = guess_formats(df[[col]], c("ymd HMS", "ymd", "mdy HMS", "mdy", "dmy HMS", "dmy"))))
    # If parsing results in all NAs and there were non-NA values originally, it might be a poor guess
    # or the column is not truly a date/time column in a recognizable format.
    if (all(is.na(parsed_dates[!original_NAs])) && any(!original_NAs)) {
        print(sprintf("  - Could not reliably convert %s or it's not a date/time column. Skipping extraction.", col))
    } else if (!all(is.na(parsed_dates))) { # If at least some dates were parsed
        df[, (col) := parsed_dates] # Update column using data.table syntax
        # Check if conversion was successful (i.e., it's now a POSIXt/Date type)
        if (is.POSIXct(df[[col]]) || is.Date(df[[col]])) {
          df[, paste0(col, "_year") := year(get(col))]
          df[, paste0(col, "_month") := month(get(col))]
          df[, paste0(col, "_day") := day(get(col))]
          df[, paste0(col, "_dayofweek") := wday(get(col), week_start = 1)] # Monday=1 to Sunday=7
          print(sprintf("  - Converted %s to datetime and extracted components", col))
        } else {
          print(sprintf("  - Could not convert %s after attempting parsing.", col))
        }
    } else {
        print(sprintf("  - No values parsed for %s, column might be all NA or unparseable.", col))
    }
  }
}

# Display sample of datetime columns and their derived features
date_derived_cols <- names(df)[grep("_year|_month|_day|_dayofweek", names(df))]
# Ensure original date_cols are also selected if they exist and were converted
actual_date_cols_converted <- intersect(date_col_candidates, names(df)[sapply(df, function(x) is.POSIXct(x) || is.Date(x))])

if (length(date_derived_cols) > 0) {
  print("Sample of date-derived columns:")
  print(head(df[, c(actual_date_cols_converted, date_derived_cols), with = FALSE]))
}


# --- 5. Handling Outliers ---
print("Handling outliers...")

# Update numeric columns list (some date components are numeric)
numeric_cols_for_outliers <- names(df)[sapply(df, is.numeric)]

# Exclude date-related components that were just generated if they shouldn't be capped
cols_to_exclude_from_outlier_capping <- date_derived_cols
numeric_cols_to_cap <- setdiff(numeric_cols_for_outliers, cols_to_exclude_from_outlier_capping)

for (col in numeric_cols_to_cap) {
  if (sum(!is.na(df[[col]])) < 2) { # Need at least 2 non-NA values for quantile
      print(sprintf("  - Skipping outlier capping for %s due to insufficient non-NA data", col))
      next
  }
  Q1 <- quantile(df[[col]], 0.25, na.rm = TRUE)
  Q3 <- quantile(df[[col]], 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1

  # If IQR is 0 
  if (IQR_val == 0) {
    print(sprintf("  - Skipping outlier capping for %s as IQR is 0", col))
    next
  }

  lower_bound <- Q1 - 1.5 * IQR_val
  upper_bound <- Q3 + 1.5 * IQR_val

  outliers_lower <- df[[col]] < lower_bound
  outliers_upper <- df[[col]] > upper_bound
  num_outliers <- sum(outliers_lower, na.rm = TRUE) + sum(outliers_upper, na.rm = TRUE)

  if (num_outliers > 0) {
    # Cap the outliers (clip)
    current_col_values <- df[[col]]
    current_col_values[which(outliers_lower)] <- lower_bound
    current_col_values[which(outliers_upper)] <- upper_bound
    df[, (col) := current_col_values] # data.table assignment
    print(sprintf("  - Capped %d outliers in %s", num_outliers, col))
  }
}

# Visualize distribution of a few numeric columns after outlier handling
# Take up to 3 numeric columns that were subject to capping
sample_num_cols_plot <- head(numeric_cols_to_cap, 3)

if (length(sample_num_cols_plot) > 0) {
  plots <- lapply(sample_num_cols_plot, function(col_name) {
    # Ensure column exists and has non-NA values before plotting
    if (col_name %in% names(df) && sum(!is.na(df[[col_name]])) > 0) {
      ggplot(df, aes_string(x = col_name)) +
        geom_histogram(aes(y = ..density..), bins = 30, fill = "blue", alpha = 0.7) +
        geom_density(alpha = .2, fill = "#FF6666") +
        ggtitle(sprintf("Distribution of %s after outlier handling", col_name)) +
        theme_minimal() # Or use the global theme_bw()
    } else {
      NULL # Return NULL if column can't be plotted
    }
  })
  # Remove NULL plots (if any column was skipped)
  plots <- plots[!sapply(plots, is.null)]

  # Print plots (in RStudio, they'll appear one by one or in a grid if arranged)
  # For saving or specific layout, use gridExtra::grid.arrange or similar
  if (length(plots) > 0) {
    print("Displaying sample numeric distributions (if graphics device is available):")
    tryCatch({
        for(p in plots) print(p)
    }, error = function(e) {
        message("Could not display plots. Ensure a graphics device is available or save plots to file.")
    })
  }
}


# --- 6. Handling Categorical Variables ---

print("Handling categorical variables...")

# Update categorical columns list
# Exclude any columns that might have been converted to other types or removed
current_cols <- names(df)
categorical_cols <- current_cols[sapply(df[, ..current_cols], function(x) is.character(x) || is.factor(x))]


if (length(categorical_cols) > 0) {
  cat_stats_list <- lapply(categorical_cols, function(col) {
    data.frame(Column = col, Unique_Values = df[, uniqueN(get(col))]) # data.table uniqueN
  })
  cat_stats <- rbindlist(cat_stats_list) # Combine list of data.frames
  cat_stats <- cat_stats[order(-Unique_Values)]

  print("Categorical column statistics:")
  print(cat_stats)

  # Reduce categories for columns with too many
  # Python code uses > 100 unique values, keeps top 50.
  max_unique_threshold <- 100
  top_n_categories <- 50

  for (col in cat_stats$Column) { # Iterate based on sorted stats for clarity
    num_unique <- df[, uniqueN(get(col))] # Get unique count for the column
    if (num_unique > max_unique_threshold) {
      print(sprintf("  - Reducing categories in %s (had %d unique values)", col, num_unique))
      # Get top N most common categories
      top_cats_table <- df[, .N, by = col][order(-N)][1:min(top_n_categories, .N)]
      top_cats <- top_cats_table[[col]]

      # Replace values not in top_cats with "Other"
      # data.table approach:
      df[!get(col) %in% top_cats, (col) := "Other"]
      # Convert to factor to manage levels properly if desired, though not strictly necessary
      # df[, (col) := factor(get(col))]
      print(sprintf("    ...Reduced to top %d categories + 'Other'", length(top_cats)))
    }
  }
} else {
  print("No categorical columns found to process.")
}


# --- 7. Creating Additional Features ---
print("Creating additional features...")
crash_year_col <- "crash_date_year" 
vehicle_year_col <- "vehicle_year" 

if (crash_year_col %in% names(df) && vehicle_year_col %in% names(df)) {
  # Ensure both columns are numeric
  if (is.numeric(df[[crash_year_col]]) && is.numeric(df[[vehicle_year_col]])) {
    tryCatch({
      df[, vehicle_age_at_crash := get(crash_year_col) - get(vehicle_year_col)]

      # Remove negative ages (data errors) by setting them to NA
      df[vehicle_age_at_crash < 0, vehicle_age_at_crash := NA_real_]
      print("  - Created 'vehicle_age_at_crash' feature")

      # Visualize vehicle age distribution
      if (sum(!is.na(df$vehicle_age_at_crash)) > 0) {
        p_age <- ggplot(df[!is.na(vehicle_age_at_crash)], aes(x = vehicle_age_at_crash)) +
          geom_histogram(bins = 30, fill = "steelblue", alpha = 0.8, aes(y=..density..)) +
          geom_density(alpha=.2, fill="orange") +
          ggtitle("Distribution of Vehicle Age at Crash") +
          xlab("Vehicle Age (years)") +
          ylab("Density")
        # print(p_age) # Display plot
        # pdf("vehicle_age_distribution.pdf", width=10, height=6)
        # print(p_age)
        # dev.off()
        # print("Vehicle age distribution plot saved to vehicle_age_distribution.pdf")
        tryCatch({ print(p_age) }, error = function(e) { message("Could not display vehicle age plot.")})
      } else {
        print("  - No valid data for vehicle_age_at_crash to visualize.")
      }
    }, error = function(e) {
      print(sprintf("  - Could not create vehicle age feature: %s", e$message))
   })
  } else {
    print(sprintf("  - Could not create vehicle age: '%s' or '%s' is not numeric.", crash_year_col, vehicle_year_col))
  }
} else {
  print(sprintf("  - Skipping 'vehicle_age_at_crash': required columns ('%s', '%s') not found.", crash_year_col, vehicle_year_col))
}


# --- 8. Final Cleaning and Validation ---
print("Final cleaning and validation...")

# Identify critical columns (containing terms like 'crash', 'fatal', 'severity', 'injury')
# This attempts to match the Python logic.
critical_col_keywords <- c("crash", "fatal", "severity", "injury")
critical_cols <- names(df)[sapply(names(df), function(col_name) {
  any(sapply(critical_col_keywords, function(keyword) grepl(keyword, col_name, ignore.case = TRUE)))
})]

if (length(critical_cols) > 0) {
  print(sprintf("Identified critical columns: %s", paste(critical_cols, collapse = ", ")))
  rows_before <- nrow(df)

  # Remove rows with NA in any of these critical columns
  # Using data.table's na.omit for specific columns
  # Note: na.omit default in R works row-wise for the entire data.frame.
  # For specific columns with data.table: df[complete.cases(df[, ..critical_cols])]
  df <- df[complete.cases(df[, ..critical_cols])]

  rows_after <- nrow(df)
  print(sprintf("Removed %d rows with missing values in critical columns", rows_before - rows_after))
} else {
  print("No critical columns identified for NA removal based on keywords.")
}

# Verify data quality after cleaning
print("Final data quality check:")
print(sprintf("Number of rows after final cleaning: %s", format(nrow(df), big.mark = ",")))
print(sprintf("Number of columns: %d", ncol(df)))
print(sprintf("Remaining missing values: %d", sum(sapply(df, function(x) sum(is.na(x))))))


# --- 9. Export Cleaned Data ---
print(sprintf("Exporting %s cleaned rows to %s...", format(nrow(df), big.mark = ","), output_file))
# Using data.table::fwrite for efficiency
fwrite(df, output_file, row.names = FALSE)

# Print summary
end_time <- proc.time()
processing_time_seconds <- (end_time - start_time)["elapsed"]
processing_time_minutes <- processing_time_seconds / 60

print(sprintf("Data preprocessing complete in %.2f minutes", processing_time_minutes))
print(sprintf("Original dataset had approximately: %s rows (based on initial load)", format(total_rows, big.mark = ",")))
print(sprintf("Cleaned dataset: %s rows", format(nrow(df), big.mark = ",")))
print(sprintf("Output file: %s", output_file))

# Display sample of the final cleaned data
print("Sample of the cleaned data:")
print(head(df))