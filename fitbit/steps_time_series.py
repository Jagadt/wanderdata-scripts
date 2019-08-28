"""
This script fits a time series model using my Fitbit steps data.
"""
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from fbprophet import Prophet

# setting the Seaborn aesthetics.
sns.set()

df = pd.read_csv('hourly_values_R.csv')

# the trend line is a bit underfit, so I'll increase changepoint_prior_scale
# to 0.06 (from 0.05).
m = Prophet(changepoint_prior_scale=0.06)
m.fit(df)
forecast = m.predict(df)
fig = m.plot_components(forecast)
# this plot shows the trend, weekly and daily seasonality.
plt.show()
