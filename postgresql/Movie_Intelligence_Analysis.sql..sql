
/* =====================================================
   MOVIE BOX OFFICE & PROFITABILITY INTELLIGENCE
   BUSINESS ANALYSIS - 20 SQL QUERIES
   Database: movie_intelligence
   ===================================================== */


/* 1. OVERALL INDUSTRY PERFORMANCE */

SELECT
    COUNT(*) AS total_movies,
    COUNT(*) FILTER (WHERE financially_eligible) AS eligible_movies,
    ROUND(AVG(rating), 2) AS average_rating,
    ROUND(AVG(popularity), 2) AS average_popularity,
    SUM(budget) AS total_recorded_budget,
    SUM(revenue) AS total_recorded_revenue
FROM fact_movie_performance;


/* 2. TOP 10 HIGHEST-GROSSING MOVIES */

SELECT
    m.title,
    f.revenue,
    f.budget,
    f.profit,
    ROUND(f.roi_percentage, 2) AS roi_percentage
FROM fact_movie_performance f
JOIN dim_movie m ON f.movie_id = m.movie_id
WHERE f.financially_eligible = TRUE
ORDER BY f.revenue DESC
LIMIT 10;


/* 3. TOP 10 MOST PROFITABLE MOVIES */

SELECT
    m.title,
    f.budget,
    f.revenue,
    f.profit
FROM fact_movie_performance f
JOIN dim_movie m ON f.movie_id = m.movie_id
WHERE f.financially_eligible = TRUE
ORDER BY f.profit DESC
LIMIT 10;


/* 4. TOP 10 MOVIES BY ROI */

SELECT
    m.title,
    f.budget,
    f.revenue,
    f.profit,
    ROUND(f.roi_percentage, 2) AS roi_percentage
FROM fact_movie_performance f
JOIN dim_movie m ON f.movie_id = m.movie_id
WHERE f.financially_eligible = TRUE
ORDER BY f.roi_percentage DESC
LIMIT 10;


/* 5. TOP 10 HIGHEST-RATED MOVIES */

SELECT
    m.title,
    f.rating,
    f.vote_count,
    f.popularity
FROM fact_movie_performance f
JOIN dim_movie m ON f.movie_id = m.movie_id
WHERE f.rating IS NOT NULL
ORDER BY f.rating DESC, f.vote_count DESC
LIMIT 10;


/* 6. GENRE-WISE MOVIE PERFORMANCE */

SELECT
    g.genre_name,
    COUNT(DISTINCT f.movie_id) AS total_movies,
    ROUND(AVG(f.revenue), 2) AS average_revenue,
    ROUND(AVG(f.rating), 2) AS average_rating
FROM bridge_movie_genre_model b
JOIN dim_genre g ON b.genre_id = g.genre_id
JOIN fact_movie_performance f ON b.movie_id = f.movie_id
WHERE f.financially_eligible = TRUE
GROUP BY g.genre_name
ORDER BY average_revenue DESC;


/* 7. GENRE-WISE PROFITABILITY */

SELECT
    g.genre_name,
    COUNT(DISTINCT f.movie_id) AS movie_count,
    SUM(f.budget) AS total_budget,
    SUM(f.revenue) AS total_revenue,
    SUM(f.profit) AS total_profit
FROM bridge_movie_genre_model b
JOIN dim_genre g ON b.genre_id = g.genre_id
JOIN fact_movie_performance f ON b.movie_id = f.movie_id
WHERE f.financially_eligible = TRUE
GROUP BY g.genre_name
ORDER BY total_profit DESC;


/* 8. TOP PRODUCTION COMPANIES BY REVENUE */

SELECT
    c.company_name,
    COUNT(DISTINCT f.movie_id) AS total_movies,
    SUM(f.revenue) AS total_revenue,
    SUM(f.profit) AS total_profit,
    ROUND(AVG(f.rating), 2) AS average_rating
FROM bridge_movie_company_model b
JOIN dim_production_company c ON b.company_id = c.company_id
JOIN fact_movie_performance f ON b.movie_id = f.movie_id
WHERE f.financially_eligible = TRUE
GROUP BY c.company_name
HAVING COUNT(DISTINCT f.movie_id) >= 5
ORDER BY total_revenue DESC
LIMIT 10;


/* 9. PRODUCTION COMPANIES BY WEIGHTED ROI */

SELECT
    c.company_name,
    COUNT(DISTINCT f.movie_id) AS total_movies,
    SUM(f.budget) AS total_budget,
    SUM(f.revenue) AS total_revenue,
    ROUND(
        SUM(f.profit)::NUMERIC /
        NULLIF(SUM(f.budget), 0) * 100, 2
    ) AS weighted_roi_percentage
FROM bridge_movie_company_model b
JOIN dim_production_company c ON b.company_id = c.company_id
JOIN fact_movie_performance f ON b.movie_id = f.movie_id
WHERE f.financially_eligible = TRUE
GROUP BY c.company_name
HAVING COUNT(DISTINCT f.movie_id) >= 5
ORDER BY weighted_roi_percentage DESC
LIMIT 10;


/* 10. GENRE-WISE AUDIENCE POPULARITY */

SELECT
    g.genre_name,
    COUNT(DISTINCT f.movie_id) AS total_movies,
    ROUND(AVG(f.popularity), 2) AS average_popularity,
    ROUND(AVG(f.rating), 2) AS average_rating,
    SUM(f.vote_count) AS total_votes
FROM bridge_movie_genre_model b
JOIN dim_genre g ON b.genre_id = g.genre_id
JOIN fact_movie_performance f ON b.movie_id = f.movie_id
GROUP BY g.genre_name
ORDER BY average_popularity DESC;


/* 11. YEAR-WISE MOVIE PRODUCTION TRENDS */

SELECT
    d.release_year,
    COUNT(f.movie_id) AS total_movies
FROM fact_movie_performance f
JOIN dim_date d ON f.release_date = d.release_date
GROUP BY d.release_year
ORDER BY d.release_year;


/* 12. YEAR-WISE BOX OFFICE PERFORMANCE */

SELECT
    d.release_year,
    COUNT(f.movie_id) AS total_movies,
    SUM(f.budget) AS total_budget,
    SUM(f.revenue) AS total_revenue,
    SUM(f.profit) AS total_profit,
    ROUND(AVG(f.rating), 2) AS average_rating
FROM fact_movie_performance f
JOIN dim_date d ON f.release_date = d.release_date
WHERE f.financially_eligible = TRUE
GROUP BY d.release_year
ORDER BY total_revenue DESC;


/* 13. QUARTERLY MOVIE PERFORMANCE */

SELECT
    d.release_quarter,
    COUNT(f.movie_id) AS total_movies,
    ROUND(AVG(f.revenue), 2) AS average_revenue,
    ROUND(AVG(f.profit), 2) AS average_profit,
    ROUND(AVG(f.rating), 2) AS average_rating
FROM fact_movie_performance f
JOIN dim_date d ON f.release_date = d.release_date
WHERE f.financially_eligible = TRUE
GROUP BY d.release_quarter
ORDER BY d.release_quarter;


/* 14. MONTHLY RELEASE AND REVENUE TRENDS */

SELECT
    d.release_month,
    COUNT(f.movie_id) AS total_movies,
    ROUND(AVG(f.revenue), 2) AS average_revenue,
    SUM(f.revenue) AS total_revenue
FROM fact_movie_performance f
JOIN dim_date d ON f.release_date = d.release_date
WHERE f.financially_eligible = TRUE
GROUP BY d.release_month
ORDER BY total_revenue DESC;


/* 15. YEAR-OVER-YEAR REVENUE GROWTH */

WITH yearly_revenue AS (
    SELECT
        d.release_year,
        SUM(f.revenue) AS total_revenue
    FROM fact_movie_performance f
    JOIN dim_date d ON f.release_date = d.release_date
    WHERE f.financially_eligible = TRUE
    GROUP BY d.release_year
),
comparison AS (
    SELECT
        release_year,
        total_revenue,
        LAG(total_revenue) OVER (
            ORDER BY release_year
        ) AS previous_year_revenue
    FROM yearly_revenue
)
SELECT
    release_year,
    total_revenue,
    previous_year_revenue,
    ROUND(
        (total_revenue - previous_year_revenue) /
        NULLIF(previous_year_revenue, 0) * 100, 2
    ) AS yoy_growth_percentage
FROM comparison
ORDER BY release_year;


/* 16. BUDGET CATEGORY PERFORMANCE */

SELECT
    m.budget_category,
    COUNT(*) AS total_movies,
    ROUND(AVG(f.revenue), 2) AS average_revenue,
    ROUND(AVG(f.profit), 2) AS average_profit,
    ROUND(AVG(f.roi_percentage), 2) AS average_roi
FROM movies_staging m
JOIN fact_movie_performance f ON m.id = f.movie_id
WHERE f.financially_eligible = TRUE
GROUP BY m.budget_category
ORDER BY average_revenue DESC;


/* 17. RUNTIME CATEGORY PERFORMANCE */

SELECT
    m.runtime_category,
    COUNT(*) AS total_movies,
    ROUND(AVG(f.rating), 2) AS average_rating,
    ROUND(AVG(f.revenue), 2) AS average_revenue,
    ROUND(AVG(f.popularity), 2) AS average_popularity
FROM movies_staging m
JOIN fact_movie_performance f ON m.id = f.movie_id
WHERE m.runtime_category IS NOT NULL
GROUP BY m.runtime_category
ORDER BY average_rating DESC;


/* 18. AUDIENCE RATING SEGMENTATION */

SELECT
    CASE
        WHEN rating >= 8 THEN 'Excellent (8-10)'
        WHEN rating >= 7 THEN 'Good (7-7.9)'
        WHEN rating >= 5 THEN 'Average (5-6.9)'
        WHEN rating >= 3 THEN 'Below Average (3-4.9)'
        ELSE 'Poor (0-2.9)'
    END AS rating_segment,
    COUNT(*) AS total_movies,
    ROUND(AVG(popularity), 2) AS average_popularity,
    ROUND(AVG(revenue), 2) AS average_revenue
FROM fact_movie_performance
WHERE rating IS NOT NULL
GROUP BY rating_segment
ORDER BY average_revenue DESC;


/* 19. HIGH-REVENUE MOVIES WITH LOW RATINGS */

SELECT
    m.title,
    f.revenue,
    f.rating,
    f.vote_count,
    f.popularity
FROM fact_movie_performance f
JOIN dim_movie m ON f.movie_id = m.movie_id
WHERE f.financially_eligible = TRUE
  AND f.rating < 6
ORDER BY f.revenue DESC
LIMIT 20;


/* 20. HIGH-RATED MOVIES WITH LOW REVENUE */

SELECT
    m.title,
    f.revenue,
    f.rating,
    f.vote_count,
    f.budget
FROM fact_movie_performance f
JOIN dim_movie m ON f.movie_id = m.movie_id
WHERE f.financially_eligible = TRUE
  AND f.rating >= 8
ORDER BY f.revenue ASC
LIMIT 20;


/* =====================================================
   END OF BUSINESS ANALYSIS
   ===================================================== */
