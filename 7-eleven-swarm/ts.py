import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from fbprophet import Prophet

# setting the Seaborn aesthetics.
sns.set(font_scale=1.3)

df = pd.read_csv('ts_df.csv')

m = Prophet()
m.fit(df)
forecast = m.predict(df)
fig = m.plot_components(forecast)
plt.show()
