-- ============================================================
-- Superstore Sales Analysis — RFM Customer Segmentation
-- Recency, Frequency, Monetary analysis to segment customers
-- into actionable tiers (Champions, At Risk, Lost, etc.)
-- ============================================================

-- 5.1 Base RFM metrics per customer
-- Recency  = days since their last order, measured from the dataset's max order date
--            (using max order date as "today" since this is historical data, not live)
-- Frequency = number of distinct orders placed
-- Monetary  = total sales value across all orders
WITH rfm_base AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        MAX(order_date) AS last_order_date,
        (SELECT MAX(order_date) FROM orders) - MAX(order_date) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(sales), 2) AS monetary
    FROM orders
    GROUP BY customer_id, customer_name, segment
),

-- 5.2 Score each dimension 1-5 using quintiles (NTILE)
-- Recency: lower days = better = higher score, so we invert the tile order
-- Frequency & Monetary: higher = better = higher score
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,   -- most recent = tile 5
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM rfm_base
)

-- 5.3 Combine scores into a segment label
SELECT
    customer_id,
    customer_name,
    segment,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'New / Promising'
        WHEN r_score = 3                                    THEN 'Needs Attention'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4  THEN 'At Risk (high value)'
        WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost / Churned'
        ELSE 'Other'
    END AS rfm_segment
FROM rfm_scored
ORDER BY rfm_total DESC;

-- ============================================================
-- 5.4 Reusable view — same RFM logic, saved so it can be queried repeatedly
-- without rebuilding the CTEs each time (used by 5.5 and by Power BI/other tools)
-- ============================================================
CREATE OR REPLACE VIEW customer_rfm AS
WITH rfm_base AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        MAX(order_date) AS last_order_date,
        (SELECT MAX(order_date) FROM orders) - MAX(order_date) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        ROUND(SUM(sales), 2) AS monetary
    FROM orders
    GROUP BY customer_id, customer_name, segment
),
rfm_scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC)       AS m_score
    FROM rfm_base
)
SELECT
    customer_id,
    customer_name,
    segment,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 3                  THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2                  THEN 'New / Promising'
        WHEN r_score = 3                                    THEN 'Needs Attention'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4  THEN 'At Risk (high value)'
        WHEN r_score <= 2 AND f_score <= 2                  THEN 'Lost / Churned'
        ELSE 'Other'
    END AS rfm_segment
FROM rfm_scored;

-- 5.5 Segment summary — count and value of customers per RFM tier
SELECT
    rfm_segment,
    COUNT(*)                AS num_customers,
    ROUND(AVG(monetary),2)  AS avg_lifetime_sales,
    ROUND(SUM(monetary),2)  AS total_segment_sales
FROM customer_rfm
GROUP BY rfm_segment
ORDER BY total_segment_sales DESC;