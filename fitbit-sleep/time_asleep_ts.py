"""
This script fits a time series model using my Fitbit steps data.
"""
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from fbprophet import Prophet

# setting the Seaborn aesthetics.
sns.set()

df = pd.read_csv('data/time_in_bed.csv')

m = Prophet(changepoint_prior_scale=0.5)
m.fit(df)
forecast = m.predict(df)
fig = m.plot_components(forecast)
# this plot shows the trend, weekly and daily seasonality
# but for this case, the daily doesn't make any sense
plt.show()
