import sys, pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_score, recall_score, f1_score
base = sys.argv[1]
for f in ["row","col","bank","server"]:
    d = pd.read_csv(f"{base}/data_for_{f}-level_prediction.csv")
    y = d.iloc[:, -1]; X = d.iloc[:, :-1]
    Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.3, stratify=y, random_state=0)
    m = RandomForestClassifier(n_estimators=200, class_weight="balanced", n_jobs=-1, random_state=0).fit(Xtr, ytr)
    p = (m.predict_proba(Xte)[:, 1] > 0.5).astype(int)
    print(f"{f:6s} rows={len(d):6d} pos={int(y.sum()):4d} ({y.mean():.2%})  P={precision_score(yte,p):.2f} R={recall_score(yte,p):.2f} F1={f1_score(yte,p):.2f}  label_col={d.columns[-1]}")
