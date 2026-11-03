# Exploratory Data Analysis Summary

## Scope
- Source records: 4,803
- Financially eligible records (budget > 0 and revenue > 0): 3,229
- Eligible-record share: 67.23%
- Aggregate budget: $131,273,202,176
- Aggregate revenue: $391,493,508,997
- Aggregate budget-based profit: $260,220,306,821
- Aggregate budget-based ROI: 198.23%

## Key findings
1. The source contains 4,803 movies; 3,229 (67.2%) have both positive budget and revenue and are eligible for the project's simplified profit/ROI calculations.
2. Among financially eligible movies, 2,438 (75.5%) have revenue greater than recorded production budget. This is not equivalent to studio net profitability.
3. Aggregate budget-based ROI across eligible movies is 198.2% (total profit divided by total eligible budget). This is a portfolio-weighted measure, not the average of individual ROI percentages.
4. Median individual movie ROI is 130.0%. Individual ROI has extreme outliers, so median and aggregate ROI should be interpreted alongside distributions.
5. Budget and revenue have a Pearson correlation of 0.71 among eligible movies. This is an association, not evidence that budget causes revenue.
6. Audience rating and revenue have a Pearson correlation of 0.19 among eligible movies with votes. Rating is not a direct measure of commercial performance.
7. TMDB popularity and revenue have a Pearson correlation of 0.60 among financially eligible movies. Popularity is a platform metric and should not be interpreted as causal.
8. Highest-revenue eligible title in this extract: Avatar (revenue $2,787,965,087).
9. Highest-profit eligible title in this extract: Avatar (budget-based profit $2,550,965,087).
10. Highest individual ROI title in this extract: Modern Times (ROI 849,999,900.0%). The extreme result should be investigated because unusually small recorded budgets can inflate ROI.

## Interpretation cautions
1. Profit = recorded revenue minus recorded production budget. It is not studio net profit.
2. ROI = profit divided by positive recorded budget. Zero or missing financial information is not imputed.
3. Individual ROI has extreme outliers; use medians, percentiles and weighted aggregate ROI together.
4. Multi-genre and multi-company movies appear in each associated category. Category averages are valid per association, but summing category totals will double-count multi-associated movies.
5. TMDB popularity and vote metrics are platform-specific audience signals, not causal drivers.
6. Historical and recent years may have incomplete coverage in this dataset; interpret annual trends carefully.
