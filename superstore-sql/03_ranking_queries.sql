-- ============================================================
-- Superstore Sales Analysis — Ranking Queries
-- ============================================================

-- 3.1 Top 10 products by total profit
SELECT
    product_name,
    category,
    sub_category,
    SUM(sales)   AS total_sales,
    SUM(profit)  AS total_profit,
    COUNT(*)     AS order_lines
FROM orders
GROUP BY product_name, category, sub_category
ORDER BY total_profit DESC
LIMIT 10;

-- 3.2 Bottom 10 products by total profit (biggest losses)
SELECT
    product_name,
    category,
    sub_category,
    SUM(sales)   AS total_sales,
    SUM(profit)  AS total_profit,
    COUNT(*)     AS order_lines
FROM orders
GROUP BY product_name, category, sub_category
ORDER BY total_profit ASC
LIMIT 10;

-- 3.3 Sub-category ranking by profit margin (not just raw profit)
-- Reveals sub-categories that are small but efficient, vs big but thin-margin
SELECT
    sub_category,
    SUM(sales)                                   AS total_sales,
    SUM(profit)                                  AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales),0) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(discount) * 100, 1)                AS avg_discount_pct
FROM orders
GROUP BY sub_category
ORDER BY profit_margin_pct DESC;

-- 3.4 Top 10 customers by lifetime sales, with rank via window function
SELECT
    customer_id,
    customer_name,
    segment,
    SUM(sales)  AS lifetime_sales,
    SUM(profit) AS lifetime_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS sales_rank
FROM orders
GROUP BY customer_id, customer_name, segment
ORDER BY lifetime_sales DESC
LIMIT 10;

-- 3.5 Rank sub-categories within each region by total sales (window function, partitioned)
-- Useful for: "what's the #1 selling sub-category in each region?"
SELECT *
FROM (
    SELECT
        region,
        sub_category,
        SUM(sales) AS region_subcat_sales,
        RANK() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rank_in_region
    FROM orders
    GROUP BY region, sub_category
) ranked
WHERE rank_in_region <= 3
ORDER BY region, rank_in_region;

-- 3.6 States ranked by profit, flagging any with negative total profit
SELECT
    state,
    region,
    SUM(sales)  AS total_sales,
    SUM(profit) AS total_profit,
    CASE WHEN SUM(profit) < 0 THEN 'LOSS' ELSE 'PROFIT' END AS status
FROM orders
GROUP BY state, region
ORDER BY total_profit ASC
LIMIT 15;
