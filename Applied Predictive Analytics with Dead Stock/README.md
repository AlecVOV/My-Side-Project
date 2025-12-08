# Applied Predictive Analytics with Dead Stock

## 📋 Project Overview

This project analyzes inventory data from Australian warehouses to predict which items are likely to become dead stock - inventory that hasn't moved for extended periods and is unlikely to sell due to obsolescence, lack of demand, or other factors.

**Dataset:** 3,000+ inventory records from warehouses across Australia  
**Target Variable:** Dead stock (Binary: Yes/No)  
**Goal:** Build classification models to identify potential dead stock items for better warehouse management decisions

## 🎯 Learning Objectives

Through this tutorial project, you will learn:

### 1. **Data Preprocessing & Exploration**
- Loading and inspecting datasets with `pandas`
- Understanding different variable types (numeric, ordinal, nominal)
- Analyzing data structure using `df.info()` and `value_counts()`
- Identifying and handling missing values
- Making informed decisions about feature selection

### 2. **Data Cleaning Techniques**
- Implementing **mean imputation** for numeric features
- Implementing **mode imputation** for categorical features
- Understanding when and why to use different imputation strategies
- Handling text descriptions and redundant features

### 3. **Feature Engineering**
- Creating dummy variables with `pd.get_dummies()`
- One-hot encoding categorical features
- Extracting meaningful patterns from text using regular expressions
- Feature extraction from composite columns (e.g., parsing 'Item Type' into 'Item_Category' and 'Source')
- Handling multi-state and warehouse location encoding

### 4. **Data Preparation for Machine Learning**
- Splitting data into features (X) and target (y)
- Creating train-test splits with stratification
- Understanding the importance of `random_state` for reproducibility
- Feature scaling using `StandardScaler`
- Preventing data leakage by fitting scalers only on training data

### 5. **Machine Learning Model Building**
- **Linear Classifier:** Logistic Regression
  - Training with standardized data
  - Understanding convergence parameters (`max_iter`)
- **Nonlinear Classifier:** Random Forest
  - Understanding tree-based models don't require scaling
  - Configuring ensemble parameters

### 6. **Model Evaluation & Comparison**
- Computing accuracy metrics for training and test sets
- Understanding overfitting vs. generalization
- Comparing linear vs. nonlinear models
- Using multiple metrics: Accuracy, Precision, Recall, F1-Score
- Interpreting confusion matrices

### 7. **Business Insights & Interpretation**
- Identifying key predictive features (inventory aging metrics)
- Understanding domain-specific indicators (e.g., '% of over 2 year', 'Over 3 Years Quantity')
- Making model recommendations based on interpretability and performance
- Translating model results into actionable business decisions

## 🛠️ Technologies & Libraries

```python
- pandas           # Data manipulation and analysis
- numpy            # Numerical computing
- scikit-learn     # Machine learning (LogisticRegression, RandomForestClassifier, StandardScaler, train_test_split)
- re               # Regular expressions for text parsing
```

## 📊 Key Features in Dataset

- **Location Data:** Warehouse codes (1N0, 1N1, 1W0), State (NSW, WA)
- **Inventory Metrics:** Total Quantity, Unit Cost, Total Value
- **Aging Metrics:** 6 Months QTY, 12 Months QTY, 2 Years QTY, Over 2 Years Qty, Over 3 Years Quantity
- **Sales Data:** Monthly sales (Jan-Dec), Average monthly, Inventory Turn
- **Classification:** ABC Class (A-J ranking), Business Area, Item Type
- **Target:** Dead stock indicator

## 🔍 Model Performance

| Model | Training Accuracy | Test Accuracy | Characteristics |
|-------|------------------|---------------|-----------------|
| **Logistic Regression** | 99.86% | 99.57% | Best generalization, interpretable, recommended |
| **Random Forest** | 99.17% | 98.41% | High accuracy, slightly more overfitting |

## 💡 Key Takeaways

1. **Inventory aging metrics** (Over 2 Years Qty, Over 3 Years Quantity) are the strongest predictors of dead stock
2. **Simpler models** (Logistic Regression) can outperform complex models when data has clear linear separability
3. **Feature selection** is crucial - redundant features should be removed to improve model efficiency
4. **Domain knowledge** helps in feature engineering and model interpretation
5. **Proper data preprocessing** (imputation, encoding, scaling) is essential for model performance

## 📁 Project Structure

```
.
├── Dataset/
│   └── Inventory.csv           # Raw inventory data
├── code.ipynb                  # Main Jupyter notebook with analysis
└── README.md                   # This file
```

## 🚀 Getting Started

1. Clone this repository
2. Install required dependencies: `pip install pandas numpy scikit-learn`
3. Open code.ipynb in Jupyter Notebook or VSCode
4. Run cells sequentially to reproduce the analysis

## 📚 Best Practices Demonstrated

- ✅ Train-test split with stratification for imbalanced datasets
- ✅ Fitting preprocessing on training data only (avoiding data leakage)
- ✅ Using appropriate encoding for different variable types
- ✅ Model comparison based on multiple criteria (accuracy, interpretability, generalization)
- ✅ Clear documentation and justification of decisions
- ✅ Business-oriented interpretation of results

## 🎓 Ideal For

- Data science students learning classification workflows
- Professionals transitioning into machine learning
- Anyone interested in inventory management analytics
- Practitioners wanting to understand end-to-end ML pipelines

## 📝 License

This is an educational project. Feel free to use and modify for learning purposes.

---

**Note:** This project demonstrates a complete machine learning workflow from data exploration to model evaluation, focusing on practical business applications in inventory management.