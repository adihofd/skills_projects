import pandas as pd
import matplotlib.pyplot as plt

df=pd.read_csv("telecalling_performance.csv")

def plot(x,y,title,xlab,ylab,p_name):
    p_name(x,y)
    plt.title(title)
    plt.xlabel(xlab)
    plt.ylabel(ylab)
    plt.show()

#1
plot(df["day"],df["calls_made"],"call_activity","day","calls",plt.plot)

#2
plot(df["avg_call_duration"],df["conversions"],"Duration impact on conversions","avg_duration","coversions",plt.scatter)

