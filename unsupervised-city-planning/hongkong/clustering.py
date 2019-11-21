import hdbscan
import pandas as pd
import numpy as np

df = pd.read_csv('data/coordinates.csv')
rads = np.radians(df)
model = hdbscan.HDBSCAN(min_cluster_size=2, metric='haversine')
predictions = model.fit_predict(rads)
