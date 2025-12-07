# Data Analysis Skills

1. **Exploratory Data Analysis (EDA)**
   - Loading and inspecting data using pandas
   - Data cleaning (column name stripping)
   - Basic statistical exploration with `.info()` and `.head()`

2. **Data Visualization**
   - Creating scatter plots with matplotlib
   - Adding trend lines using numpy's `polyfit`
   - Customizing plot aesthetics (colors, sizing, labels)

3. **Statistical Analysis**
   - Calculating correlation coefficients (0.90 shows strong positive relationship between guest nights and tax revenue)
   - Understanding the relationship between variables

## Machine Learning Fundamentals

1. **Linear Regression Modeling**
   - Using scikit-learn's `LinearRegression`
   - Model training with `.fit()`
   - Making predictions with `.predict()`
   - Data reshaping for sklearn compatibility

2. **Model Evaluation**
   - R-squared value: **0.8078** (80.78% of variance explained)
   - RMSE: **462.31** (average prediction error in millions)
   - Understanding coefficient interpretation:
     - Intercept: 33.55 (base tax revenue)
     - Slope: 0.149 (for every 1,000 guest nights increase, tax revenue increases by ~$0.15M)

3. **Statistical Modeling**
   - Using statsmodels for more detailed statistical analysis
   - Comparing sklearn vs statsmodels approaches

# Key Business Insights

From the **strong correlation (0.90)** and **high R-squared (0.81)**, you can learn that:
- Guest nights are a reliable predictor of tax revenue
- Tourism activity directly impacts local government revenue
- The predictive model can help forecast tax revenue based on expected tourism

This project demonstrates practical data science workflow: data exploration → visualization → modeling → evaluation.