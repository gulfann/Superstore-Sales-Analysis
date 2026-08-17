-- ============================================================
-- Superstore Sales Analysis — Time Trends & Cohort Analysis
-- ============================================================

-- 4.1 Monthly sales & profit trend
-- Uses the order_month column already present in the table (e.g. '2016-11')
SELECT
    order_month,
    SUM(sales)   AS total_sales,
    SUM(profit)  AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 4.2 Year-over-year growth by category
-- Uses window function LAG() to compare each year to the prior year
WITH yearly AS (
    SELECT
        category,
        order_year,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY category, order_year
)
SELECT
    category,
    order_year,
    total_sales,
    LAG(total_sales) OVER (PARTITION BY category ORDER BY order_year) AS prior_year_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY order_year))
        / NULLIF(LAG(total_sales) OVER (PARTITION BY category ORDER BY order_year), 0) * 100,
    1) AS yoy_growth_pct
FROM yearly
ORDER BY category, order_year;

-- 4.3 Seasonality check — average sales by calendar month, across all years
SELECT
    EXTRACT(MONTH FROM order_date)::INT AS calendar_month,
    TO_CHAR(order_date, 'Month')        AS month_name,
    ROUND(AVG(monthly_total), 2)        AS avg_monthly_sales
FROM (
    SELECT
        DATE_TRUNC('month', order_date) AS order_date,
        SUM(sales) AS monthly_total
    FROM orders
    GROUP BY DATE_TRUNC('month', order_date)
) monthly_sums
GROUP BY calendar_month, month_name
ORDER BY calendar_month;

-- 4.4 Customer acquisition cohorts by first purchase month
WITH first_order AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date))::DATE AS cohort_month
    FROM orders
    GROUP BY customer_id
),
customer_activity AS (
    SELECT
        o.customer_id,
        f.cohort_month,
        DATE_TRUNC('month', o.order_date)::DATE AS activity_month
    FROM orders o
    JOIN first_order f ON o.customer_id = f.customer_id
)
SELECT
    cohort_month,
    activity_month,
    (EXTRACT(YEAR FROM activity_month) - EXTRACT(YEAR FROM cohort_month)) * 12
        + (EXTRACT(MONTH FROM activity_month) - EXTRACT(MONTH FROM cohort_month)) AS months_since_first_purchase,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_activity
GROUP BY cohort_month, activity_month
ORDER BY cohort_month, activity_month;

-- 4.5 Average shipping delay by ship mode, over time
SELECT
    order_year,
    ship_mode,
    ROUND(AVG(shipping_days), 2) AS avg_shipping_days,
    COUNT(*) AS order_lines
FROM orders
GROUP BY order_year, ship_mode
ORDER BY order_year, ship_mode;