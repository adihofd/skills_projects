import pandas as pd
import numpy as np

df=pd.read_csv("customers_ultra_dirty_realistic.csv")
print(df.info())

#customer_id
df.rename(columns={"customer_id":"clean_customer_id"},inplace=True)
df['clean_customer_id']=np.arange(1,len(df)+1)
print(f"uniqueness ={df['clean_customer_id'].is_unique}\n\n")

#name
df['name']=df['name'].fillna('Unknown')
df['name']=df['name'].str.lower().str.strip()
df.rename(columns={"name":"name_clean"},inplace=True)



#email
df.rename(columns={"email":"clean_email"},inplace=True)
email_regex = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
valid=df["clean_email"].astype(str).str.match(email_regex)
df.loc[~valid, 'clean_email'] = np.nan
df['clean_email'] = df['clean_email'].fillna('unknown@unknown.com')

#age
df.rename(columns={"age":"clean_age"},inplace=True)
valid_age=df["clean_age"].between(1, 100)
df.loc[~valid_age,'clean_age']=np.nan
df['clean_age']=df['clean_age'].fillna(df['clean_age'].median())

#income
df.rename(columns={"income":"clean_income"},inplace=True)
valid_income = (df["clean_income"] >= 0)
df.loc[~valid_income,'clean_income']=np.nan
df['clean_income']=df['clean_income'].fillna(df['clean_income'].median())

#city,signup_date,purchases

df.rename(columns={"city":"clean_city"},inplace=True)
df['clean_city']=df['clean_city'].fillna('Unknown')
df['clean_city']=df['clean_city'].str.lower().str.strip()


df.rename(columns={"signup_date":"clean_signup_date"},inplace=True)
df['clean_signup_date'] = pd.to_datetime(df['clean_signup_date'],errors="coerce")
valid_date = df["clean_signup_date"].notna()
df.loc[~valid_date,'clean_signup_date']=pd.NaT
df['clean_signup_date']=df['clean_signup_date'].fillna(df['clean_signup_date'].median())

df.rename(columns={"purchases":"clean_purchases"},inplace=True)
valid_p= (df["clean_purchases"] >= 0)
df.loc[~valid_p,'clean_purchases']=np.nan
df['clean_purchases']=df['clean_purchases'].fillna(df['clean_purchases'].median())

x=df['clean_age']
x=x.astype(int)
y=df['clean_purchases']
y=y.astype(int)

df.to_csv("customers_ultra_dirty_realistic_cleaned.csv", index=False)
