"""
Reproducible cleaning pipeline for Movie Box Office & Profitability Intelligence.
Run from repository root: python python/data_cleaning.py
"""
from pathlib import Path
import json
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
OUT = ROOT / "data" / "cleaned"
REPORTS = ROOT / "data" / "reports"
OUT.mkdir(parents=True, exist_ok=True)
REPORTS.mkdir(parents=True, exist_ok=True)

def parse_list(value):
    if pd.isna(value) or value == "":
        return []
    try:
        result = json.loads(value)
        return result if isinstance(result, list) else []
    except (ValueError, TypeError):
        return []

def names(items, key="name"):
    return [str(x[key]) for x in items if isinstance(x, dict) and x.get(key) not in (None, "")]

def directors(items):
    return [str(x["name"]) for x in items if isinstance(x, dict)
            and x.get("job") == "Director" and x.get("name")]

movies = pd.read_csv(RAW / "tmdb_5000_movies.csv")
credits = pd.read_csv(RAW / "tmdb_5000_credits.csv")
if movies["id"].duplicated().any() or credits["movie_id"].duplicated().any():
    raise ValueError("Duplicate keys found; resolve before merging.")
if set(movies["id"]) != set(credits["movie_id"]):
    raise ValueError("Movie and credits IDs do not match.")
for col in ["genres", "keywords", "production_companies", "production_countries", "spoken_languages"]:
    movies[col + "_parsed"] = movies[col].map(parse_list)
credits["cast_parsed"] = credits["cast"].map(parse_list)
credits["crew_parsed"] = credits["crew"].map(parse_list)
df = movies.merge(credits, left_on="id", right_on="movie_id", how="left",
                  validate="one_to_one", suffixes=("", "_credits"))
df["release_date_clean"] = pd.to_datetime(df["release_date"], errors="coerce")
df["release_year"] = df["release_date_clean"].dt.year.astype("Int64")
df["release_month"] = df["release_date_clean"].dt.month.astype("Int64")
df["release_quarter"] = df["release_date_clean"].dt.quarter.astype("Int64")
df["genre_names"] = df["genres_parsed"].map(names)
df["production_company_names"] = df["production_companies_parsed"].map(names)
df["production_country_names"] = df["production_countries_parsed"].map(names)
df["spoken_language_names"] = df["spoken_languages_parsed"].map(names)
df["keyword_names"] = df["keywords_parsed"].map(names)
df["director_names"] = df["crew_parsed"].map(directors)
df["top_5_cast"] = df["cast_parsed"].map(lambda x: names(x)[:5])
df["cast_count"] = df["cast_parsed"].map(len)
df["crew_count"] = df["crew_parsed"].map(len)
df["financially_eligible"] = (df["budget"] > 0) & (df["revenue"] > 0)
df["profit"] = np.where(df["financially_eligible"], df["revenue"] - df["budget"], np.nan)
df["roi_percentage"] = np.where(df["financially_eligible"],
                                (df["revenue"] - df["budget"]) / df["budget"] * 100, np.nan)
df["budget_category"] = pd.cut(df["budget"], [-np.inf, 1e7, 5e7, 1e8, np.inf],
                               labels=["Under $10M", "$10M–$50M", "$50M–$100M", "Over $100M"],
                               right=False).astype("string")
df["revenue_category"] = pd.cut(df["revenue"], [-np.inf, 1e7, 5e7, 1e8, 5e8, np.inf],
                                labels=["Under $10M", "$10M–$50M", "$50M–$100M", "$100M–$500M", "Over $500M"],
                                right=False).astype("string")
df["runtime_category"] = pd.cut(df["runtime"], [-np.inf, 90, 120, 150, np.inf],
                                labels=["Under 90 min", "90–119 min", "120–149 min", "150+ min"],
                                right=False).astype("string")
df["rating_status"] = np.where(df["vote_count"] > 0, "Rated", "No votes")
df["rating_clean"] = df["vote_average"].where(df["vote_count"] > 0, np.nan)
for col in ["genre_names", "production_company_names", "production_country_names",
            "spoken_language_names", "keyword_names", "director_names", "top_5_cast"]:
    df[col] = df[col].map(lambda x: " | ".join(x) if x else None)
df["release_date"] = df["release_date_clean"].dt.strftime("%Y-%m-%d")
drop_cols = [c for c in df.columns if c.endswith("_parsed")] + ["movie_id", "cast", "crew", "release_date_clean"]
df.drop(columns=drop_cols, inplace=True)
df.to_csv(OUT / "movies_cleaned.csv", index=False)
print(f"Exported {len(df):,} movie rows to {OUT / 'movies_cleaned.csv'}")
