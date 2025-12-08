# ------------------------------------------------------------------------------
# PHẦN 1: CÀI ĐẶT VÀ GỌI THƯ VIỆN VÀ ĐỌC DỮ LIỆU
# ------------------------------------------------------------------------------
install.packages(c("readxl", "dplyr", "stringr", "ggplot2", "car", "stargazer", "corrplot", "lmtest", "caret", "sandwich"))

library(readxl)     # read excel file
library(dplyr)      # process data
library(stringr)    # process comma
library(ggplot2)    # draw chart
library(car)        # Check  VIF
library(stargazer)  # pretty output
library(corrplot)   # draw maxtrix correlation
library(lmtest)     # test model
library(caret)      # split data train/test
library(sandwich)   # calculate robust SE

# set correct path with double \\
setwd("C:\\Users\\Admin\\OneDrive\\Assignment Working\\Sem 2\\IUHDA101 - Khám Phá Cấu Trúc Dữ Liệu")

# read file Excel
df_raw <- read_excel("data.xlsx", sheet = "Data")

# review original data
print("Dữ liệu gốc:")
dim(df_raw) # find out how many rows and columns

# ------------------------------------------------------------------------------
# PHẦN 2: LÀM SẠCH VÀ XỬ LÝ DỮ LIỆU (DATA CLEANING)
# ------------------------------------------------------------------------------

# Step 1: Fix comman into dot
df_clean <- df_raw %>%
  mutate(
    price_per_m2 = as.numeric(str_replace(price_per_m2, ",", ".")),
    apartment_area = as.numeric(str_replace(apartment_area, ",", ".")),
    distance_to_center_km = as.numeric(str_replace(distance_to_center_km, ",", "."))
  )

# Step 2: Remove NA value
df_clean <- na.omit(df_clean)

# Step 3: Convert categorical variable into factor 
df_clean$ward <- as.factor(df_clean$ward)
df_clean$has_green_view <- as.factor(df_clean$has_green_view)
df_clean$has_wind_corridor <- as.factor(df_clean$has_wind_corridor)
df_clean$developer_tier <- as.factor(df_clean$developer_tier) 

# Step 4: process outlier using IQR method
# Calculate quantiles
Q1 <- quantile(df_clean$price_per_m2, 0.25)
Q3 <- quantile(df_clean$price_per_m2, 0.75)
IQR_val <- Q3 - Q1

# define acceptable range
lower_bound <- Q1 - 1.5 * IQR_val
upper_bound <- Q3 + 1.5 * IQR_val

# Remove the lower and the upper bound value
df_final <- subset(df_clean, price_per_m2 > lower_bound & price_per_m2 < upper_bound)

cat("Giá trị còn lại sau khi loại các giá trị ngoại biên:", nrow(df_final), "\n")

# Step5: Convert log for pricing (Chart will be distributed accurately)
df_final$log_price <- log(df_final$price_per_m2)

# ------------------------------------------------------------------------------
# PHẦN 3: PHÂN TÍCH KHÁM PHÁ (EDA)
# ------------------------------------------------------------------------------

# Histogram chart
# Before Log
p1 <- ggplot(df_final, aes(x = price_per_m2)) + 
  geom_histogram(fill="blue", bins=30) + 
  ggtitle("Phân phối giá trước khi Log")
print(p1)

# After Log 
p2 <- ggplot(df_final, aes(x = log_price)) + 
  geom_histogram(fill="green", bins=30) + 
  ggtitle("Phân phối giá sau khi Log")
print(p2)

# Correlation Matrix
# Only take numerical value to put on chart
numeric_vars <- df_final %>% select(price_per_m2, green_coverage_ratio, 
                                    orientation_solar_score, building_spacing_ratio, 
                                    apartment_area, distance_to_center_km)

M <- cor(numeric_vars)
corrplot(M, method = "color", type = "upper", 
         addCoef.col = "black", # Hien so len cho de nhin
         tl.col = "black", tl.srt = 45, 
         title = "Ma tran tuong quan")

# Standardize for comparing strong/weak for Model Beta
df_std <- df_final
cols_to_scale <- c("green_coverage_ratio", "orientation_solar_score", "building_spacing_ratio", 
                   "apartment_area", "distance_to_center_km")
df_std[cols_to_scale] <- scale(df_std[cols_to_scale])

# ------------------------------------------------------------------------------
# PHẦN 4: XÂY DỰNG MÔ HÌNH (THEO 3 GIAI ĐOẠN)
# ------------------------------------------------------------------------------

# --- Stage 1: Base Model (MODEL 1) ---
# Chi dung bien Thiet ke + Distance (Bo Ward ra de tranh da cong tuyen luc dau)
model_basic <- lm(log_price ~ green_coverage_ratio + orientation_solar_score + 
                  building_spacing_ratio + has_green_view + has_wind_corridor +
                  apartment_area + distance_to_center_km, 
                  data = df_final)

print("--- Check VIF Model 1  ---")
vif(model_basic)


# --- Stage 2: Enhanced Model (MODEL 2 - High R Squared) ---
# Adding more strong valriable like: Developer + Ward + Shopping
# Target: Boost R squared to highest
model_high_R2 <- lm(log_price ~ green_coverage_ratio + orientation_solar_score + 
                    building_spacing_ratio + has_green_view + has_wind_corridor +
                    apartment_area + developer_tier + shopping_access_score + ward, 
                    data = df_final)

# Check if VIF is too high
print("--- Check VIF Model 2  ---")
vif(model_high_R2) 

# --- Stage 3: Blanced Model (FINAL MODEL - MODEL 3) ---
# Keep Developer (important), remove Ward va Shopping (noising valriable), keep Distance
model_final <- lm(log_price ~ 
                  green_coverage_ratio + orientation_solar_score + 
                  building_spacing_ratio + has_green_view + has_wind_corridor +
                  apartment_area + 
                  developer_tier + distance_to_center_km, 
                  data = df_final)

print("--- Check VIF Model 3  ---")
vif(model_final)


# Comparing 3 R squared of 3 models
cat("R2 Model Basic:", summary(model_basic)$r.squared, "\n")
cat("R2 Model High:", summary(model_high_R2)$r.squared, "\n")
cat("R2 Model Final:", summary(model_final)$r.squared, "\n")

# ------------------------------------------------------------------------------
# PHẦN 5: KIỂM ĐỊNH VÀ KHẮC PHỤC LỖI (DIAGNOSTICS)
# ------------------------------------------------------------------------------

# 1. Check VIF of  Model Final
print("--- VIF of Model Final ---")
vif_values <- vif(model_final)
print(vif_values) # < 10 iz very gud

# 2. Check Heteroscedasticity
print("---  Breusch-Pagan ---")
bptest(model_final)
# If p-value is small which mean can be wrong so we should need Robust SE 

# 3. Assess residuals follow a normal distribution
qqPlot(model_final, main=" Q-Q Plot")

# 4. Fixing Error: Calculate Robust Standard Errors 
cov_matrix <- vcovHC(model_final, type = "HC1")
robust_se <- sqrt(diag(cov_matrix))

# Export Final Result for Report
stargazer(model_final, type = "text",
          se = list(robust_se),
          title = "Final Regression Result (Model 3 - Final)",
          column.labels = c("Final Model"),
          star.cutoffs = c(0.05, 0.01, 0.001))

# ------------------------------------------------------------------------------
# PHẦN 6: DỰ BÁO (PREDICTION)
# ------------------------------------------------------------------------------

# Spilting data into 80% Train, 20% Test
set.seed(123) # Set seed de ket qua khong bi nhay lung tung
trainIndex <- createDataPartition(df_final$log_price, p = .8, list = FALSE, times = 1)
dataTrain <- df_final[ trainIndex,]
dataTest  <- df_final[-trainIndex,]

# Train model
model_pred <- lm(log_price ~ green_coverage_ratio + orientation_solar_score + 
                 building_spacing_ratio + has_green_view + has_wind_corridor +
                 apartment_area + developer_tier + distance_to_center_km, 
                 data = dataTrain)

# Predict model test set
predictions <- predict(model_pred, dataTest)

# Calculate metrics
rmse_val <- RMSE(predictions, dataTest$log_price)
r2_val <- R2(predictions, dataTest$log_price)

cat("Result on test set:\n")
cat("RMSE:", rmse_val, "\n")
cat("R-squared:", r2_val, "\n")
