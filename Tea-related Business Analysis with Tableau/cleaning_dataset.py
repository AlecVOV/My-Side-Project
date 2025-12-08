import pandas as pd

# Step 1: Load the data
file_path = 'Assessment 3 Dataset Sem 2 2025.xlsx'
df = pd.read_excel(file_path)

# Step 2: Display initial info to understand the data
print("Original Dataset Info:")
print(df.info())
print(f"\nOriginal number of rows: {len(df)}")

# Step 3: Clean the data

# 3.1 Handle Negative Inventory
# Assuming negative inventory is an error and should be set to zero.
print(f"\nNumber of rows with negative Inventory: {(df['Inventory'] < 0).sum()}")
df['Inventory'] = df['Inventory'].clip(lower=0)  # This sets all negative values to 0

# 3.2 Handle Extreme Negative Gross Margins (Potential Errors/Outliers)
# Define a threshold. This is subjective and should be based on domain knowledge.
# For example, a Gross Margin of -100 or lower is highly suspicious.
gross_margin_threshold = -100
print(f"Number of rows with Gross Margin <= {gross_margin_threshold}: {(df['Gross Margin'] <= gross_margin_threshold).sum()}")

# Remove these extreme outliers (Recommended for analysis if they are errors)
df_cleaned = df[df['Gross Margin'] > gross_margin_threshold].copy()

# 3.3 Reset index after potential row removal
df_cleaned.reset_index(drop=True, inplace=True)

# Step 4: Display cleaned data info
print("\nCleaned Dataset Info:")
print(df_cleaned.info())
print(f"Cleaned number of rows: {len(df_cleaned)}")

# Step 5: Export the cleaned data to a new Excel file
output_file_path = 'Assessment 3 Dataset Sem 2 2025_CLEANED.xlsx'
df_cleaned.to_excel(output_file_path, index=False)

print(f"\nCleaned data successfully exported to '{output_file_path}'")