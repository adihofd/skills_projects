import pandas as pd
import numpy as np

df=pd.read_csv("Online Retail.csv")

#cleaning columns
df.columns=df.columns.str.lower()

#date
df["invoicedate"] = pd.to_datetime(
    df["invoicedate"],
    errors="coerce",
    dayfirst=True
)
df=df.sort_values("invoicedate")
df=df.set_index("invoicedate")

# description
df["description"]=(df["description"]
                   .str.lower()
                   .str.strip()
                   .str.replace(" ","_")
                   )
df=df.dropna(subset=["description"])
df["description"] = df["description"].fillna("missing_desc")


#customerid

df=df.dropna(subset=["customerid"])
df["customerid"] = df["customerid"].fillna(np.nan).astype("Int64")



# country
df["country"]=(df["country"]
                   .str.lower()
                   .str.strip()
                   .str.replace(" ","_")
                   )




df['revenue']=(df['quantity']*df['unitprice']).round(2)





































































#diagnosis
print("_______Audit_________")
print("Empty index rows:",+df.index.isna().sum())
print(f"Empty row details:\n{df.isna().sum()}\nTotal Revenune={df['revenue'].sum().round(3)}")

print(df.groupby('country')['revenue'].sum())




df.to_csv("Online_Retail_clean.csv")
























