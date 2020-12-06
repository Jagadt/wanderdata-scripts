import matplotlib.pyplot as plt
import pandas as pd
from joblib import dump
from sklearn import tree
from sklearn.metrics import classification_report
from sklearn.preprocessing import OneHotEncoder

df = pd.read_csv('subcategories.csv')
X = df.drop('subcategory', axis=1)
y = df.subcategory

enc = OneHotEncoder(handle_unknown='ignore').fit(X)
X = enc.transform(X)

# To see the features
enc.get_feature_names()

clf = tree.DecisionTreeClassifier().fit(X, y)
dump(clf, 'decision_tree_051220.joblib')
y_pred = clf.predict(X)
print(classification_report(y, y_pred))

#tree.plot_tree(clf, filled=True)


fig, ax = plt.subplots(figsize=(50, 24))
tree.plot_tree(clf, fontsize=6)
plt.savefig('whole_tree_high_dpi', dpi=100)


fig, ax = plt.subplots(figsize=(30, 20))
tree.plot_tree(clf, fontsize=14, max_depth=3,
               feature_names=enc.get_feature_names(),
               class_names=sorted(y.unique()),
               impurity=False)
plt.savefig('tree_high_dpi_max_depth_3', dpi=100)
