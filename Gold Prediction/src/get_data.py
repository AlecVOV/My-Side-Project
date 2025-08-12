import yfinance as yf
import pandas as pd
from datetime import datetime
import os

# Create data folder if it doesn't exist
os.makedirs('data', exist_ok=True)
os.makedirs('data/processed', exist_ok=True)
os.makedirs('data/raw', exist_ok=True)

# Tickers
gold_ticker = 'GC=F'
usd_ticker = 'DX-Y.NYB'
vnd_ticker = 'VND=X'
DEFAULT_START_DATE = '2000-01-01'  # Default start date for historical data
DEFAULT_END_DATE = datetime.now().strftime('%Y-%m-%d')  # Default end date is today

# Conversion factor from Troy Ounce to Tael
TROY_OUNCE_TO_TAEL = 0.8294

# Process and gather that data
print("Fetching data...")

# Input the time span to gather data
while True:
    try:
        start_date = input("Enter the start date (YYYY-MM-DD, eg: '2000-01-01'): ")
        end_date = input("Enter the end date (YYYY-MM-DD, eg: 'today'): ")
        datetime.strptime(start_date, '%Y-%m-%d')
        datetime.strptime(end_date, '%Y-%m-%d')
        break
    except ValueError:
        print("Invalid date format. Please use YYYY-MM-DD, we will use the default dates.")
        start_date = DEFAULT_START_DATE
        end_date = DEFAULT_END_DATE
        break

# Get historical data with auto_adjust=False to suppress warning
print("Downloading gold data...")
gold_data = yf.download(gold_ticker, start=start_date, end=end_date, auto_adjust=False, progress=False)
print("Downloading USD index data...")
usd_data = yf.download(usd_ticker, start=start_date, end=end_date, auto_adjust=False, progress=False)
print("Downloading VND exchange rate data...")
vnd_data = yf.download(vnd_ticker, start=start_date, end=end_date, auto_adjust=False, progress=False)

# Fix column structure for single ticker downloads - flatten multi-level columns
if isinstance(gold_data.columns, pd.MultiIndex):
    gold_data.columns = gold_data.columns.droplevel(1)
if not usd_data.empty and isinstance(usd_data.columns, pd.MultiIndex):
    usd_data.columns = usd_data.columns.droplevel(1)
if not vnd_data.empty and isinstance(vnd_data.columns, pd.MultiIndex):
    vnd_data.columns = vnd_data.columns.droplevel(1)

print(f"Gold data shape: {gold_data.shape}")
print(f"USD data shape: {usd_data.shape if not usd_data.empty else 'Empty'}")
print(f"VND data shape: {vnd_data.shape if not vnd_data.empty else 'Empty'}")

# Check if data was retrieved
if gold_data.empty:
    print("Error: No gold data retrieved")
    exit()

# Create a base dataframe with gold data (most reliable)
combined_data = pd.DataFrame({
    'Date': gold_data.index,
    'Gold_USD_per_ounce': gold_data['Close'].values,
    'Gold_Open': gold_data['Open'].values,
    'Gold_High': gold_data['High'].values,
    'Gold_Low': gold_data['Low'].values,
    'Gold_Volume': gold_data['Volume'].values
})

# Add USD Index data (align with gold data dates)
if not usd_data.empty:
    combined_data['USD_Index'] = usd_data['Close'].reindex(gold_data.index, method='ffill').values
    print(f"USD Index data points added: {combined_data['USD_Index'].notna().sum()}")
else:
    print("Warning: No USD Index data available, filling with NaN")
    combined_data['USD_Index'] = None

# Add VND exchange rate data (align with gold data dates)
if not vnd_data.empty:
    combined_data['USD_to_VND_Rate'] = vnd_data['Close'].reindex(gold_data.index, method='ffill').values
    print(f"VND rate data points added: {combined_data['USD_to_VND_Rate'].notna().sum()}")
else:
    print("Warning: No VND exchange rate data available, filling with NaN")
    combined_data['USD_to_VND_Rate'] = None

# Calculate additional columns
combined_data['Gold_VND_per_ounce'] = combined_data['Gold_USD_per_ounce'] * combined_data['USD_to_VND_Rate']
combined_data['Gold_VND_per_tael'] = combined_data['Gold_VND_per_ounce'] / TROY_OUNCE_TO_TAEL

# Reset index to make Date a regular column
combined_data.reset_index(drop=True, inplace=True)
# Format date as DD-MM-YYYY instead of MM-DD-YYYY
combined_data['Date'] = combined_data['Date'].dt.strftime('%d-%m-%Y')

# Generate filename with timestamp
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
filename = f"data/raw/gold_data_{timestamp}.csv"

# Save the combined data to a CSV file
combined_data.to_csv(filename, index=False)

print("Data fetching complete.")
print(f"Data saved to {filename}")
print(f"📊 Records: {len(combined_data)}")
print(f"📅 Date range: {combined_data['Date'].min()} to {combined_data['Date'].max()}")

# Show latest prices
latest = combined_data.iloc[-1]
print(f"\n💰 Latest prices:")
print(f"Gold: ${latest['Gold_USD_per_ounce']:,.2f} USD/ounce")
if pd.notna(latest['Gold_VND_per_tael']):
    print(f"Gold: {latest['Gold_VND_per_tael']:,.0f} VND/tael")
if pd.notna(latest['USD_Index']):
    print(f"USD Index: {latest['USD_Index']:.2f}")

# Show data info
print(f"\n📋 Data summary:")
print(f"Gold data points: {combined_data['Gold_USD_per_ounce'].notna().sum()}")
print(f"USD Index data points: {combined_data['USD_Index'].notna().sum()}")
print(f"VND rate data points: {combined_data['USD_to_VND_Rate'].notna().sum()}")