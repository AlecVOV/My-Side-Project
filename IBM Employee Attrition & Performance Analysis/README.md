# IBM Employee Attrition & Performance Analysis

**HR Analytics | Predictive Modeling | Business Intelligence**

A comprehensive 4-stage analysis of employee attrition patterns and performance metrics for strategic HR decision-making. This project transforms raw HR data into actionable insights for employee retention and organizational development.

## 🎯 Project Overview

This project addresses the critical business challenge of employee attrition through data-driven analysis. By examining IBM's employee data, we develop predictive models and identify key factors influencing employee retention, enabling proactive HR strategies and improved organizational performance.

## 📊 Dataset Information

- **Source Dataset**: WA_Fn-UseC_-HR-Employee-Attrition.csv
- **Domain**: Human Resources Analytics
- **Scale**: 1,470 employees with 35 initial features
- **Final Cleaned Dataset**: [cleaned_WA_Fn-UseC_-HR-Employee-Attrition.csv](./Stage%203/cleaned_WA_Fn-UseC_-HR-Employee-Attrition.csv) (46 features after preprocessing)
- **Target Variable**: Employee Attrition (Yes/No → 1/0)

## 🔍 Project Objectives

1. **Primary Goal**: Predict employee attrition with high accuracy
2. **Business Impact**: Identify key drivers of employee turnover
3. **Strategic Insights**: Provide actionable recommendations for HR policies
4. **Cost Reduction**: Enable proactive retention strategies

## 📁 Project Structure

```
IBM Employee Attrition & Performance Analysis/
├── README.md                                    # Project documentation
├── Stage 1/                                     # Project Planning
│   └── Stage 1 - Proposal.docx                 # Project proposal and objectives
├── Stage 2/                                     # Data Cleaning & Preprocessing
│   ├── Report_and_Insight.docx                 # Stage 2 findings and insights
│   └── code and data/
│       └── Complete_HR_Data_Cleaning_Process.ipynb  # Comprehensive data cleaning pipeline
├── Stage 3/                                     # Feature Engineering & Model Preparation
│   └── cleaned_WA_Fn-UseC_-HR-Employee-Attrition.csv  # Final cleaned dataset
└── Stage 4/                                     # Advanced Analysis & Modeling
    └── [Advanced modeling and final insights]
```

## 🚀 Stage Breakdown

### Stage 1: Project Planning & Proposal
- **Deliverable**: [Stage 1 - Proposal.docx](./Stage%201/Stage%201%20-%20Proposal.docx)
- **Focus**: Project scope, objectives, and methodology definition
- **Outcome**: Structured approach to HR analytics problem

### Stage 2: Data Cleaning & Preprocessing ⭐
- **Code**: [Complete_HR_Data_Cleaning_Process.ipynb](./Stage%202/code%20and%20data/Complete_HR_Data_Cleaning_Process.ipynb)
- **Report**: [Report_and_Insight.docx](./Stage%202/Report_and_Insight.docx)
- **Key Achievements**:
  - ✅ **Data Quality**: No missing values or duplicates found
  - ✅ **Feature Reduction**: Removed single-value columns (`EmployeeCount`, `Over18`, `StandardHours`)  
  - ✅ **Encoding**: Applied one-hot encoding to 7 categorical variables
  - ✅ **Target Mapping**: Converted Attrition (Yes=1, No=0)
  - ✅ **Outlier Detection**: Identified 114 potential outliers in MonthlyIncome
  - ✅ **Scaling Ready**: Prepared 14 numerical features for normalization

### Stage 3: Feature Engineering & Model Preparation
- **Output**: [cleaned_WA_Fn-UseC_-HR-Employee-Attrition.csv](./Stage%203/cleaned_WA_Fn-UseC_-HR-Employee-Attrition.csv)
- **Features**: 46 engineered features ready for modeling
- **Quality**: Fully processed dataset with verified data integrity

### Stage 4: Advanced Analysis & Modeling
- **Focus**: Predictive modeling and business insights
- **Deliverables**: Model performance analysis and strategic recommendations

## 🛠️ Technical Implementation

### Data Cleaning Pipeline (Stage 2)
The comprehensive cleaning process includes:

1. **Data Loading & Inspection**: Initial dataset exploration (1,470 × 35)
2. **Missing Value Analysis**: Verified no missing data
3. **Duplicate Detection**: Confirmed no duplicate records
4. **Single-Value Removal**: Dropped non-informative columns
5. **Outlier Analysis**: IQR-based outlier detection for numerical features
6. **Categorical Encoding**: One-hot encoding with `drop_first=True`
7. **Target Transformation**: Binary encoding of attrition variable
8. **Feature Scaling**: MinMax scaling preparation for numerical features
9. **Data Validation**: Comprehensive verification of cleaned dataset

### Key Features After Processing
- **Numerical Features**: Age, DailyRate, DistanceFromHome, HourlyRate, MonthlyIncome, etc.
- **Encoded Categories**: BusinessTravel, Department, EducationField, Gender, JobRole, MaritalStatus, OverTime
- **Target Variable**: Attrition (0: No, 1: Yes)

## 📈 Key Findings & Insights

### Data Quality Assessment
- **✅ Clean Dataset**: No missing values or duplicates
- **📊 Feature Engineering**: Expanded from 35 to 46 meaningful features
- **🎯 Target Balance**: Properly encoded binary classification target
- **📋 Data Integrity**: All categorical variables successfully encoded

### Technical Achievements
- **Robust Pipeline**: Reusable data cleaning workflow
- **Feature Optimization**: Removed redundant single-value columns
- **Encoding Excellence**: Proper categorical variable transformation
- **Validation Framework**: Comprehensive data quality verification

## 🔧 Technologies Used

| **Category** | **Technologies** |
|--------------|------------------|
| **Programming** | Python |
| **Data Processing** | pandas, numpy |
| **Machine Learning** | scikit-learn, MinMaxScaler |
| **Development** | Jupyter Notebook |
| **Visualization** | Data profiling and statistical analysis |

## 📊 Business Impact

This project demonstrates capability to:
- **Transform Complex HR Data**: Convert raw employee data into analysis-ready format
- **Ensure Data Quality**: Implement comprehensive data validation processes
- **Enable Predictive Analytics**: Prepare clean datasets for machine learning models
- **Support Strategic Decisions**: Provide data foundation for HR policy optimization

## 🔄 Next Steps & Future Enhancements

1. **Model Development**: Train multiple classification algorithms
2. **Feature Importance**: Identify key attrition predictors
3. **Business Insights**: Translate model findings into HR strategies
4. **Deployment**: Create interactive dashboards for HR teams
5. **Monitoring**: Implement model performance tracking

## 📋 How to Use

1. **Start with Stage 1**: Review project proposal for context
2. **Explore Stage 2**: Follow the comprehensive data cleaning process
3. **Access Clean Data**: Use Stage 3 cleaned dataset for modeling
4. **Build Models**: Apply machine learning techniques in Stage 4

---

**Part of**: [Data Science & Analytics Portfolio](../README.md)

**Technologies**: Python, pandas, scikit-learn, HR Analytics, Predictive Modeling

**Industry**: Human Resources, Employee Analytics, Business Intelligence