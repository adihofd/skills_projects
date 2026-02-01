import numpy as np
import pandas as pd

df=pd.read_csv("01-02-2025-TO-01-02-2026-NIFTYBEES-ALL-N.csv")

df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ","_")
    .str.replace("₹", "rs")
    .str.replace("%", "pct")
    .str.replace(".", "", regex=False)
)


df["date"]=pd.to_datetime(df["date"], errors="coerce")


df=df.sort_values("date")
df=df.set_index("date")

df["prev_close"]=df["close_price"].shift(1)
df["daily_return"]=(((df["close_price"]-df["prev_close"])/df["prev_close"])*100).round(3)
df.rename(columns={"daily_return":"daily_return_pct"},inplace=True)

df["log_return"]=np.log(df["close_price"]/df["prev_close"])

df.loc["2025-02-01", "log_return"] = df["log_return"].median()
df.loc["2025-02-01", "daily_return_pct"] = df["daily_return_pct"].median()

print(f"{(df['log_return'].agg(['mean','median']))}")

df["rolling_volatility_20"]=df["log_return"].rolling(20).std()

df['mov_avg_20']=df['close_price'].rolling(20).mean()
df['mov_avg_50']=df['close_price'].rolling(50).mean()

rolling_peak=df['close_price'].cummax()
df["drawdown"]=(df['close_price']-rolling_peak)/rolling_peak

df.to_csv("01-02-2025-TO-01-02-2026-NIFTYBEES-ALL-N_c.csv")
