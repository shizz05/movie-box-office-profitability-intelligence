"""Run from repository root: python python/eda.py"""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "cleaned" / "movies_cleaned.csv"
OUT = ROOT / "visualizations"
OUT.mkdir(exist_ok=True)
df = pd.read_csv(DATA)
fin = df.loc[(df["budget"] > 0) & (df["revenue"] > 0)].copy()
fin["profit"] = fin["revenue"] - fin["budget"]
fin["roi_percentage"] = fin["profit"] / fin["budget"] * 100

plt.figure(figsize=(8, 6))
plt.scatter(fin["budget"]/1e6, fin["revenue"]/1e6, alpha=.4, s=14)
plt.xlabel("Budget (USD millions)"); plt.ylabel("Revenue (USD millions)")
plt.title("Budget vs Revenue"); plt.tight_layout()
plt.savefig(OUT/"budget_vs_revenue.png", dpi=160); plt.close()

annual = fin.dropna(subset=["release_year"]).groupby("release_year").agg(
    revenue=("revenue","sum"), budget=("budget","sum"), profit=("profit","sum"))
plt.figure(figsize=(10, 5))
plt.plot(annual.index, annual["revenue"]/1e9, label="Revenue")
plt.plot(annual.index, annual["budget"]/1e9, label="Budget")
plt.xlabel("Release year"); plt.ylabel("USD billions")
plt.title("Annual Revenue and Budget"); plt.legend(); plt.tight_layout()
plt.savefig(OUT/"annual_revenue_budget.png", dpi=160); plt.close()
print("EDA charts exported to", OUT)
