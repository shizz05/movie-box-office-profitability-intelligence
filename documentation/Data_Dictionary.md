# Data Dictionary – Cleaned Movie Dataset

| Field | Description |
|---|---|
| id | TMDB movie identifier; unique movie key |
| title | Movie title |
| original_title | Original-language title |
| release_date | Parsed release date formatted YYYY-MM-DD; null if missing/invalid |
| release_year / release_month / release_quarter | Date attributes derived from release_date |
| budget / revenue | Source financial values in USD; zero values preserved |
| financially_eligible | True only when budget and revenue are both positive |
| profit | Revenue minus budget for eligible movies; otherwise null |
| roi_percentage | Profit / budget * 100 for eligible movies; otherwise null |
| genre_names | Pipe-delimited genre names; use bridge_movie_genre for normalized analysis |
| production_company_names | Pipe-delimited company names; use bridge_movie_production_company for normalized analysis |
| director_names | Pipe-delimited directors extracted from crew where job = Director |
| top_5_cast | Pipe-delimited first five cast names in source ordering |
| cast_count / crew_count | Number of cast and crew JSON objects |
| budget_category / revenue_category | Fixed USD bands; zero remains in the lowest band |
| runtime_category | Runtime band; null for missing runtime |
| rating_clean | vote_average only when vote_count > 0; otherwise null |
| rating_status | Rated or No votes |

## Financial caveat
Profit and ROI are simplified estimates based on gross revenue and production budget. They do not include marketing, distribution, taxes, participations, financing costs or other expenses.
