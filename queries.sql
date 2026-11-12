-- Olist E-Commerce SQL Analysis
-- Database: SQLite | Dataset: Brazilian E-Commerce Public Dataset by Olist

-- Q1: How many orders are in each status?
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Q2: How many delivered orders per year?
SELECT strftime('%Y', order_purchase_timestamp) AS year, COUNT(*) AS order_count
FROM orders
WHERE order_status = 'delivered'
GROUP BY year
ORDER BY year;

-- Q3: Top 5 states by number of delivered orders
SELECT c.customer_state, COUNT(*) AS order_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY order_count DESC
LIMIT 5;

-- Q4: Top 10 product categories by revenue
SELECT t.product_category_name_english, SUM(oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY revenue DESC
LIMIT 10;

-- Q5: Highest average price categories (min. 100 items sold)
SELECT t.product_category_name_english,
       COUNT(*) AS items_sold,
       ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
HAVING COUNT(*) >= 100
ORDER BY avg_price DESC
LIMIT 10;

-- Q6: On-time vs late deliveries
SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'on_time'
        ELSE 'late'
    END AS delivery_status,
    COUNT(*) AS orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date != ''
GROUP BY delivery_status;

-- Q7: Average review score: on-time vs late deliveries
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN 'on_time'
        ELSE 'late'
    END AS delivery_status,
    COUNT(*) AS orders,
    ROUND(AVG(r.review_score), 2) AS avg_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date != ''
GROUP BY delivery_status;

-- Q8: Top 5 sellers by revenue (CTE)
WITH seller_revenue AS (
    SELECT seller_id,
           SUM(price) AS revenue,
           COUNT(DISTINCT order_id) AS orders
    FROM order_items
    GROUP BY seller_id
)
SELECT seller_id, ROUND(revenue, 2) AS revenue, orders
FROM seller_revenue
ORDER BY revenue DESC
LIMIT 5;

-- Q9: Top revenue category in each state (window function)
WITH state_category AS (
    SELECT c.customer_state,
           t.product_category_name_english AS category,
           SUM(oi.price) AS revenue
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN category_translation t ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state, t.product_category_name_english
),
ranked AS (
    SELECT customer_state, category, revenue,
           ROW_NUMBER() OVER (PARTITION BY customer_state ORDER BY revenue DESC) AS rn
    FROM state_category
)
SELECT customer_state, category, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rn = 1
ORDER BY revenue DESC;

-- Q10: Monthly revenue and month-over-month growth (LAG)
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_purchase_timestamp) AS month,
           SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND strftime('%Y', o.order_purchase_timestamp) IN ('2017', '2018')
    GROUP BY month
),
with_prev AS (
    SELECT month, revenue,
           LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(prev_revenue, 2) AS prev_revenue,
       ROUND((revenue - prev_revenue) * 100.0 / prev_revenue, 1) AS growth_pct
FROM with_prev
ORDER BY month;