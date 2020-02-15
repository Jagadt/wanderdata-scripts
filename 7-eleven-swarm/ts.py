import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from fbprophet import Prophet

# setting the Seaborn aesthetics.
sns.set(font_scale=1.3)

df = pd.read_csv('ts_df.csv')

m = Prophet(changepoint_prior_scale=0.5)
m.fit(df)
forecast = m.predict(df)
fig = m.plot_components(forecast)
# this plot shows the trend, weekly and daily seasonality
# but for this case, the daily doesn't make any sense
plt.show()