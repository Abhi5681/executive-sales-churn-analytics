-- =======================================================
-- Executive Sales & Churn Analytics - Production SQL Queries
-- =======================================================

-- Query 1: Regional Revenue & Churn Breakdown
SELECT 
    region,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(mrr_usd)::NUMERIC, 2) AS total_mrr_usd,
    ROUND(AVG(mrr_usd)::NUMERIC, 2) AS average_mrr_per_account,
    ROUND(AVG(csat_score)::NUMERIC, 2) AS avg_csat_score,
    ROUND((SUM(is_churned)::DECIMAL / COUNT(*)) * 100.0, 2) AS churn_rate_pct
FROM customer_sales_and_churn
GROUP BY region
ORDER BY total_mrr_usd DESC;


-- Query 2: Customer Risk Stratification via Support & CSAT Windowing
WITH customer_aggregates AS (
    SELECT 
        customer_id,
        segment,
        region,
        AVG(mrr_usd) AS avg_mrr,
        AVG(csat_score) AS avg_csat,
        SUM(support_tickets_90d) AS total_tickets,
        MAX(is_churned) AS has_churned
    FROM customer_sales_and_churn
    GROUP BY customer_id, segment, region
)
SELECT 
    customer_id,
    segment,
    region,
    ROUND(avg_mrr::NUMERIC, 2) AS avg_mrr,
    ROUND(avg_csat::NUMERIC, 1) AS avg_csat,
    total_tickets,
    CASE 
        WHEN avg_csat <= 4 AND total_tickets >= 4 THEN 'Critical Risk (Immediate Outreach)'
        WHEN avg_csat <= 6 AND total_tickets >= 2 THEN 'Moderate Risk (Watchlist)'
        ELSE 'Healthy / Stable'
    END AS customer_health_status
FROM customer_aggregates
WHERE has_churned = 0
ORDER BY avg_mrr DESC
LIMIT 50;


-- Query 3: Segment Product Penetration and Churn Impact
SELECT 
    segment,
    product,
    COUNT(*) AS total_contracts,
    ROUND(SUM(mrr_usd)::NUMERIC, 2) AS total_segment_product_mrr,
    ROUND((SUM(is_churned)::DECIMAL / COUNT(*)) * 100.0, 2) AS product_churn_pct
FROM customer_sales_and_churn
GROUP BY segment, product
ORDER BY segment, total_segment_product_mrr DESC;
