install.packages(c("dplyr", "lubridate", "ggplot2", "sf", "leaflet", "RColorBrewer", "leaflet.extras", "tidyverse", "readr"))
library(dplyr)
library(lubridate)
library(ggplot2)
library(sf) 
library(leaflet) 
library(RColorBrewer) 
library(tidyverse)  
library(readr)      

# Load the dataset
crashes_data <- read.csv("crash_incidents_cleaned.csv")

# Inspect the data
print(head(crashes_data))
print(str(crashes_data))
print(colnames(crashes_data))

# Data Cleaning and Preparation (basic steps, adjust as needed)
# 1. Convert date/time related columns to appropriate types
# 2. Assuming Crash_Year and Crash_Month are numeric or character
# 3. Create a proper date column for time series analysis
crashes_data <- crashes_data %>%
  mutate(
    Crash_Date = make_date(Crash_Year, match(Crash_Month, month.name), 1) # Creates date at start of month
  )

# Convert Crash_Severity to a factor with ordered levels if applicable
# This helps in ordering bars in charts logically.
# You might need to adjust the levels based on your actual data.
severity_levels <- c("Property damage only", "Minor injury", "Medical treatment", "Hospitalisation", "Fatal")
crashes_data$Crash_Severity <- factor(crashes_data$Crash_Severity, levels = severity_levels, ordered = TRUE)

# Ensure Crash_Hour is numeric if it's not already
if(is.character(crashes_data$Crash_Hour)) {
  crashes_data$Crash_Hour <- as.numeric(crashes_data$Crash_Hour)
}

# Ensure Crash_Day_Of_Week is a factor with correct order
# Example:
days_ordered <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
if("Crash_Day_Of_Week" %in% colnames(crashes_data)){
    crashes_data$Crash_Day_Of_Week <- factor(crashes_data$Crash_Day_Of_Week, levels = days_ordered, ordered = TRUE)
}

# Remove rows with NA in critical columns for specific plots
# For map visualization:
crashes_map_data <- crashes_data %>%
  filter(!is.na(Crash_Longitude) & !is.na(Crash_Latitude))

# For time series:
crashes_ts_data <- crashes_data %>%
  filter(!is.na(Crash_Date))

# For severity:
crashes_severity_data <- crashes_data %>%
  filter(!is.na(Crash_Severity))

# --- 1. Pie Chart: The crash severity distribution ---
# Check column names to find the crash severity field
print(colnames(crashes_data))

# --- Replace 'Crash_Severity' below with the correct column name if different ---
# Summarize crash severity distribution
severity_dist <- crashes_data %>%
  count(Crash_Severity) %>%
  mutate(percentage = round(100 * n / sum(n), 1))


# Print the summary table
print(severity_dist)

# Plot a pie chart of crash severity
ggplot(severity_dist, aes(x = "", y = percentage, fill = Crash_Severity)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") +
  geom_text(aes(label = paste0(percentage, "%")),
            position = position_stack(vjust = 0.5)) +
  theme_void() +
  labs(title = "Crash Severity Distribution") +
  theme(legend.title = element_blank())


# --- 2. Time Series Visualization ---
# Visualization 1a: Aggregate crash counts per month
crashes_per_month <- crashes_ts_data %>%
  group_by(Crash_Date) %>%
  summarise(Total_Crashes = n(), # Count of crash incidents
            Total_Casualties = sum(Count_Casualty_Total, na.rm = TRUE))

# To look for seasonality within years (average crashes per month across all years)
average_crashes_by_month_of_year <- crashes_ts_data %>%
  mutate(Month_Name = factor(format(Crash_Date, "%B"), levels = month.name)) %>%
  group_by(Month_Name) %>%
  summarise(Average_Crashes = n() / length(unique(Crash_Year))) %>%
  arrange(Month_Name) # Ensure months are in order

ggplot(average_crashes_by_month_of_year, aes(x = Month_Name, y = Average_Crashes, group = 1)) +
  geom_line(color = "green4") +
  geom_point(color = "green4") +
  labs(
    title = "Average Monthly Crash Pattern (Seasonality)",
    x = "Month",
    y = "Average Number of Crashes"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Visualization 2b: trends by Crash_Day_Of_Week 
if("Crash_Day_Of_Week" %in% colnames(crashes_data)){
  crashes_by_day_of_week <- crashes_data %>%
    filter(!is.na(Crash_Day_Of_Week)) %>%
    group_by(Crash_Day_Of_Week) %>%
    summarise(Total_Crashes = n())

  ggplot(crashes_by_day_of_week, aes(x = Crash_Day_Of_Week, y = Total_Crashes)) +
    geom_bar(stat = "identity", fill = "cornflowerblue") +
    labs(
      title = "Total Crashes by Day of the Week",
      x = "Day of Week",
      y = "Total Number of Crashes"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}


# --- 3. Map Visualization ---
# Plotting individual crash incidents (sample for performance)
# This is a large dataset, it's wise to plot all the point
# Taking a smaller sample for demonstration (5000 points)
sample_size <- min(5000, nrow(crashes_map_data)) # Plot up to 5000 points
crashes_map_sample <- crashes_map_data[sample(nrow(crashes_map_data), sample_size), ]

# Get the list of severities present in your sample data
present_severity_levels <- levels(droplevels(crashes_map_sample$Crash_Severity))

# Create a color scheme for these severities
pal <- colorFactor(
  palette = "YlOrRd", # Using Yellow-Orange-Red colors
  domain = present_severity_levels
)

# Make the map
map_points <- leaflet(data = crashes_map_sample) %>%
  addTiles() %>% # Basic map background
  addCircleMarkers(
    lng = ~Crash_Longitude,
    lat = ~Crash_Latitude,
    radius = 3,
    color = ~pal(Crash_Severity), # <<< COLOR DOTS BY SEVERITY
    stroke = FALSE,
    fillOpacity = 0.7,
    popup = ~paste("Severity:", Crash_Severity, "<br>Date:", Crash_Date)
  ) %>%
  addLegend(
    position = "bottomright",
    pal = pal,                # Use the same color scheme
    values = ~Crash_Severity, # Link to severity data
    title = "Crash Severity"  # Legend title
  )

# Show the map
print(map_points)


# --- 4. Severity Visualizations (By Time) ---
# Visualization 3a - Severity by Time of Day (Crash_Hour) Stacked bar chart
# Ensure Crash_Hour is numeric and clean (0-23)
severity_by_hour <- crashes_severity_data %>%
  filter(!is.na(Crash_Hour) & !is.na(Crash_Severity)) %>%
  group_by(Crash_Hour, Crash_Severity) %>%
  summarise(Count = n(), .groups = 'drop')

ggplot(severity_by_hour, aes(x = Crash_Hour, y = Count, fill = Crash_Severity)) +
  geom_bar(stat = "identity", position = "stack") +
  labs(
    title = "Crash Severity by Hour of Day (Stacked)",
    x = "Hour of Day (0-23)",
    y = "Number of Crashes",
    fill = "Crash Severity"
  ) +
  scale_fill_brewer(palette = "Spectral") + # Choose a palette that works for severity
  theme_minimal() +
  scale_x_continuous(breaks = seq(0, 23, by = 2)) # Adjust breaks for readability


# Visualization 4b - Severity by Day of Week (Crash_Day_Of_Week)
if("Crash_Day_Of_Week" %in% colnames(crashes_severity_data) && "Crash_Severity" %in% colnames(crashes_severity_data)){
  severity_by_day <- crashes_severity_data %>%
    filter(!is.na(Crash_Day_Of_Week) & !is.na(Crash_Severity)) %>%
    group_by(Crash_Day_Of_Week, Crash_Severity) %>%
    summarise(Count = n(), .groups = 'drop')

  ggplot(severity_by_day, aes(x = Crash_Day_Of_Week, y = Count, fill = Crash_Severity)) +
    geom_bar(stat = "identity", position = "stack") + # or position = "dodge"
    labs(
      title = "Crash Severity by Day of Week (Stacked)",
      x = "Day of Week",
      y = "Number of Crashes",
      fill = "Crash Severity"
    ) +
    scale_fill_brewer(palette = "Spectral") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
}

# --- 5. Severity Visualizations (By Location) ---
# Visualization 4: Severity by a Location-Related Factor or Crash Characteristic
# Severity vs. Roadway Feature (Crash_Roadway_Feature)
# Using a stacked percentage bar chart
if ("Crash_Roadway_Feature" %in% colnames(crashes_severity_data) && "Crash_Severity" %in% colnames(crashes_severity_data)) {
  crashes_severity_data_rf <- crashes_severity_data %>%
    filter(!is.na(Crash_Roadway_Feature) & Crash_Roadway_Feature != "" & !is.na(Crash_Severity))

  severity_by_road_feature <- crashes_severity_data_rf %>%
    group_by(Crash_Roadway_Feature, Crash_Severity) %>%
    summarise(Count = n(), .groups = 'drop') %>%
    # Optional: Filter for top N roadway features if there are too many
    group_by(Crash_Roadway_Feature) %>%
    mutate(Total_Crashes_Feature = sum(Count)) %>%
    ungroup() %>%
    # arrange(desc(Total_Crashes_Feature)) %>%
    # top_n(10, Total_Crashes_Feature) # Example: Top 10 features
    filter(Total_Crashes_Feature > 1000) # Example: features with >1000 crashes

  ggplot(severity_by_road_feature, aes(x = reorder(Crash_Roadway_Feature, -Total_Crashes_Feature), y = Count, fill = Crash_Severity)) +
    geom_bar(stat = "identity", position = "fill") + # "fill" for 100% stacked
    labs(
      title = "Proportion of Crash Severity by Roadway Feature",
      x = "Roadway Feature",
      y = "Proportion of Crashes",
      fill = "Crash Severity"
    ) +
    scale_y_continuous(labels = scales::percent_format()) +
    scale_fill_brewer(palette = "Spectral") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) # Rotate labels if long

} else {
  print("Column 'Crash_Roadway_Feature' not found, skipping severity vs. roadway feature plot.")
}




