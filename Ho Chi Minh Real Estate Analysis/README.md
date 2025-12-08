# Ho Chi Minh Real Estate Price Analysis

## Project Overview

The project investigates how apartment prices (per m²) are influenced by:

### Key Variables Analyzed:
- **Environmental factors**: `green_coverage_ratio`, `has_green_view`, `has_wind_corridor`
- **Building design**: `building_spacing_ratio`, `orientation_solar_score`
- **Property characteristics**: `apartment_area`, `developer_tier`
- **Location**: `distance_to_center_km`, `ward`, `shopping_access_score`

## Methodology

The analysis in Code_R.R follows a structured approach:

1. **Data Cleaning**: Handles comma/dot conversion, removes NA values and outliers using IQR method
2. **EDA**: Creates histograms and correlation matrices
3. **Model Building**: Three progressive models:
   - Model 1: Base model with design + distance variables
   - Model 2: Enhanced model (high R²) including developer, ward, shopping
   - Model 3: **Final balanced model** (R² = 0.786)
4. **Diagnostics**: VIF testing, heteroscedasticity checks (Breusch-Pagan), robust standard errors
5. **Prediction**: 80/20 train-test split for validation

## Key Findings

From FinalOutput.txt, the final model shows:
- **Negative impacts**: Higher `building_spacing_ratio` (-1.154***), greater `distance_to_center_km` (-0.454***)
- **Positive impacts**: `has_wind_corridor` (+0.129***), `has_green_view` (+0.077*)
- Lower-tier developers negatively affect prices
- Model explains **78.6%** of price variation (Adjusted R²)