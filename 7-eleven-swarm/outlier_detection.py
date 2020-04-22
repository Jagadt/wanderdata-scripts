"""
This script fits an Isolation Forest model
Code for plotting the decision function was taken from:
https://scikit-learn.org/stable/auto_examples/svm/plot_oneclass.html#sphx-glr-auto-examples-svm-plot-oneclass-py
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from sklearn.ensemble import IsolationForest

# setting the Seaborn aesthetics.
sns.set(font_scale=1.5)

df = pd.read_csv('data/start_times.csv', encoding='utf-8')
X_train = df[['weekday', 'hour']]

clf = IsolationForest()
clf.fit(X_train)

# plot of the decision frontier
xx, yy = np.meshgrid(np.linspace(-1, 7, 500), np.linspace(-2, 25, 500))
Z = clf.decision_function(np.c_[xx.ravel(), yy.ravel()])
Z = Z.reshape(xx.shape)
plt.title("\"Visiting hours\" Decision Boundary")
# comment out the next line to see the "ripples" of the boundary
plt.contourf(xx, yy, Z, levels=np.linspace(
    Z.min(), 0, 8), cmap=plt.cm.PuBu, alpha=0.5)
a = plt.contour(xx, yy, Z, levels=[0], linewidths=2, colors='darkred')
plt.contourf(xx, yy, Z, levels=[0, Z.max()], colors='palevioletred')
b1 = plt.scatter(X_train.iloc[:, 0],
                 X_train.iloc[:, 1], s=(df['n'] * 50).tolist(),
                 c='white', edgecolors='k')
plt.xlabel('Day of the week (as number)')
plt.ylabel('Time of the day')
plt.grid(True)
plt.show()
