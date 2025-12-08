## Project Overview

This project involves comprehensive data analysis and visualization of tea business operations across multiple US states using Tableau. The analysis examines sales performance, market segmentation, geographic distribution, and financial metrics to provide actionable business insights.

## Dataset

**File**: Assessment 3 Dataset Sem 2 2025_CLEANED.csv

The dataset was cleaned using a Python script `cleaning_dataset.py` and contains tea business data with the following dimensions:

- **Geographic Coverage**: 14 US states across 4 regions
  - West: California, Colorado, Oregon, Utah, Washington
  - Central: Illinois, Iowa, Wisconsin
  - East: Connecticut, Massachusetts
  - South: Florida, Louisiana, New Mexico, Texas

- **Business Metrics**:
  - Sales data
  - Total expenses
  - Marketing costs
  - Product types (various tea products)
  - Market size categories

## Key Analysis Components

### 1. Geographic Analysis
- State-level performance mapping
- Regional comparison (West, Central, East, South)
- Geographic distribution of sales and market presence

### 2. Financial Analysis
- Sales performance tracking
- Expense analysis
- Marketing cost efficiency
- Profitability metrics

### 3. Market Segmentation
- Market size categorization
- Product type analysis
- Customer segment insights

### 4. Time-Series Analysis
- Monthly/yearly trend analysis
- Seasonal patterns
- Performance over time

## Tableau Workbook

**File**: Book1.twb

The Tableau workbook contains multiple visualizations and dashboards:

### Dashboards
- **Final Dashboard**: Comprehensive overview of key metrics
- **Dashboard 2**: Secondary analysis view
- Multiple chart variations (Chart 1, 2, 3, 4)

### Visualization Types
- Geographic maps showing state and regional data
- Time-series charts for trend analysis
- Bar charts for comparative analysis
- KPI indicators for key metrics

## Skills & Tools Demonstrated

### Technical Skills
- **Data Cleaning**: Python (Pandas, data preprocessing)
- **Data Visualization**: Tableau (advanced dashboards, calculated fields, filters)
- **Data Analysis**: Statistical analysis, trend identification, pattern recognition

### Business Analysis Skills
- Market segmentation analysis
- Financial performance evaluation
- Geographic market analysis
- Strategic insights generation

### Tableau Techniques Used
- Custom calculated fields
- Interactive filters and parameters
- Multi-level geographic mapping
- Dashboard design and layout optimization
- Data blending and relationships

## Key Insights & Findings

The analysis enables stakeholders to:
- Identify top-performing states and regions
- Understand cost structures and profitability drivers
- Evaluate marketing effectiveness across different markets
- Make data-driven decisions for market expansion
- Optimize product mix based on regional preferences

## Project Structure

```
.
├── data.csv  # Cleaned dataset
├── Book1.twb                                     # Tableau workbook with visualizations
├── cleaning_dataset.py                           # Data cleaning script
└── README.md                                     # Project documentation
```

## How to Use

1. **Data Preparation**:
   - Run cleaning_dataset.py if you need to re-clean the raw data
   - Cleaned data is available in the CSV file

2. **Tableau Analysis**:
   - Open Book1.twb in Tableau Desktop
   - Explore interactive dashboards and charts
   - Modify filters to analyze specific regions, time periods, or metrics

3. **Customization**:
   - Add new calculated fields for additional metrics
   - Create custom views based on specific business questions
   - Export visualizations for presentations or reports

## Learning Outcomes

Through this project, I developed proficiency in:

1. **Data Cleaning & Preparation**
   - Handling missing values and data inconsistencies
   - Data transformation and standardization
   - Python-based data preprocessing

2. **Tableau Expertise**
   - Creating interactive and intuitive dashboards
   - Using calculated fields and LOD expressions
   - Implementing filters and parameters for dynamic analysis
   - Geographic mapping and spatial analysis

3. **Business Intelligence**
   - Translating business requirements into analytical solutions
   - Identifying meaningful patterns and trends
   - Presenting insights in a clear, actionable format

4. **Analytical Thinking**
   - Multi-dimensional data analysis
   - Comparative analysis across regions and time periods
   - Drawing actionable conclusions from complex datasets

## Future Enhancements

Potential improvements for this project:
- Predictive analytics for sales forecasting
- Customer segmentation using clustering algorithms
- Real-time data integration
- Mobile-responsive dashboard versions
- Additional KPIs for deeper operational insights

## Requirements

- **Tableau Desktop** (version 2020.1 or later)
- **Python 3.x** (for data cleaning script)
  - pandas
  - numpy