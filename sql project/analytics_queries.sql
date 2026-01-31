-- ============================================
-- ADVANCED SQL QUERIES FOR ANALYTICS
-- E-Commerce Database - Portfolio Project
-- ============================================

USE ecommerce_db;

-- ============================================
-- SECTION 1: SALES ANALYSIS
-- ============================================

-- Query 1: Top 10 Best Selling Products
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(od.quantity) AS total_units_sold,
    SUM(od.line_total) AS total_revenue,
    COUNT(DISTINCT od.order_id) AS number_of_orders,
    AVG(od.unit_price) AS average_selling_price
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o ON od.order_id = o.order_id
WHERE o.order_status NOT IN ('Cancelled', 'Returned')
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 2: Monthly Revenue Trend
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value,
    SUM(total_amount) - LAG(SUM(total_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS revenue_growth
FROM orders
WHERE order_status NOT IN ('Cancelled')
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Query 3: Revenue by Category
SELECT 
    c.category_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(od.quantity) AS units_sold,
    SUM(od.line_total) AS total_revenue,
    ROUND(SUM(od.line_total) * 100.0 / SUM(SUM(od.line_total)) OVER (), 2) AS revenue_percentage,
    AVG(od.unit_price) AS avg_product_price
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
WHERE o.order_status NOT IN ('Cancelled')
GROUP BY c.category_name
ORDER BY total_revenue DESC;

-- Query 4: Daily Sales Performance
SELECT 
    DATE(order_date) AS order_day,
    COUNT(order_id) AS orders_count,
    SUM(total_amount) AS daily_revenue,
    AVG(total_amount) AS avg_order_value,
    MAX(total_amount) AS highest_order,
    MIN(total_amount) AS lowest_order
FROM orders
WHERE order_status NOT IN ('Cancelled')
  AND order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY DATE(order_date)
ORDER BY order_day DESC;

-- ============================================
-- SECTION 2: CUSTOMER ANALYSIS
-- ============================================

-- Query 5: Customer Lifetime Value (CLV)
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_value,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifespan_days,
    CASE 
        WHEN SUM(o.total_amount) > 2000 THEN 'High Value'
        WHEN SUM(o.total_amount) > 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status NOT IN ('Cancelled')
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment
ORDER BY lifetime_value DESC;

-- Query 6: Customer Retention Analysis
SELECT 
    DATE_FORMAT(first_order, '%Y-%m') AS cohort_month,
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT CASE WHEN months_since_first = 1 THEN customer_id END) AS month_1_retention,
    COUNT(DISTINCT CASE WHEN months_since_first = 2 THEN customer_id END) AS month_2_retention,
    COUNT(DISTINCT CASE WHEN months_since_first = 3 THEN customer_id END) AS month_3_retention,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first = 1 THEN customer_id END) * 100.0 / 
          COUNT(DISTINCT customer_id), 2) AS month_1_retention_rate
FROM (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order,
        order_date,
        TIMESTAMPDIFF(MONTH, MIN(order_date) OVER (PARTITION BY customer_id), order_date) AS months_since_first
    FROM orders
    WHERE order_status NOT IN ('Cancelled')
) AS cohort_data
GROUP BY DATE_FORMAT(first_order, '%Y-%m')
ORDER BY cohort_month;

-- Query 7: RFM Analysis (Recency, Frequency, Monetary)
SELECT 
    customer_id,
    customer_name,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_score,
    CASE 
        WHEN (recency_score + frequency_score + monetary_score) >= 12 THEN 'Champions'
        WHEN (recency_score + frequency_score + monetary_score) >= 9 THEN 'Loyal Customers'
        WHEN (recency_score + frequency_score + monetary_score) >= 6 THEN 'Potential Loyalists'
        WHEN recency_score >= 4 AND frequency_score <= 2 THEN 'New Customers'
        WHEN recency_score <= 2 THEN 'At Risk'
        ELSE 'Others'
    END AS customer_segment
FROM (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        NTILE(5) OVER (ORDER BY MAX(o.order_date) DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY COUNT(o.order_id)) AS frequency_score,
        NTILE(5) OVER (ORDER BY SUM(o.total_amount)) AS monetary_score
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('Cancelled')
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS rfm_calc
ORDER BY rfm_score DESC;

-- Query 8: Customer Purchase Patterns
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    AVG(DATEDIFF(
        LEAD(o.order_date) OVER (PARTITION BY c.customer_id ORDER BY o.order_date),
        o.order_date
    )) AS avg_days_between_orders,
    GROUP_CONCAT(DISTINCT cat.category_name ORDER BY cat.category_name SEPARATOR ', ') AS preferred_categories
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE o.order_status NOT IN ('Cancelled')
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;

-- ============================================
-- SECTION 3: PRODUCT ANALYSIS
-- ============================================

-- Query 9: Product Performance Dashboard
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.unit_price,
    p.stock_quantity,
    COALESCE(SUM(od.quantity), 0) AS total_sold,
    COALESCE(SUM(od.line_total), 0) AS total_revenue,
    COALESCE(AVG(r.rating), 0) AS avg_rating,
    COALESCE(COUNT(DISTINCT r.review_id), 0) AS review_count,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity <= p.reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status,
    ROUND((p.unit_price - p.cost_price) / p.unit_price * 100, 2) AS profit_margin_pct
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE p.is_active = TRUE
GROUP BY p.product_id, p.product_name, c.category_name, p.unit_price, p.stock_quantity, p.reorder_level, p.cost_price
ORDER BY total_revenue DESC;

-- Query 10: Products Needing Restock
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.stock_quantity,
    p.reorder_level,
    s.supplier_name,
    s.email AS supplier_email,
    (p.reorder_level - p.stock_quantity) AS quantity_to_order,
    COALESCE(AVG(od.quantity), 0) AS avg_monthly_sales
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN orders o ON od.order_id = o.order_id 
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE p.stock_quantity <= p.reorder_level
GROUP BY p.product_id, p.product_name, c.category_name, p.stock_quantity, p.reorder_level, s.supplier_name, s.email
ORDER BY (p.reorder_level - p.stock_quantity) DESC;

-- Query 11: Product Bundling Opportunities (Market Basket Analysis)
SELECT 
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_bought_together,
    SUM(od1.line_total + od2.line_total) AS combined_revenue
FROM order_details od1
JOIN order_details od2 ON od1.order_id = od2.order_id AND od1.product_id < od2.product_id
JOIN products p1 ON od1.product_id = p1.product_id
JOIN products p2 ON od2.product_id = p2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING times_bought_together >= 2
ORDER BY times_bought_together DESC, combined_revenue DESC
LIMIT 10;

-- ============================================
-- SECTION 4: INVENTORY MANAGEMENT
-- ============================================

-- Query 12: Inventory Turnover Analysis
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.stock_quantity AS current_stock,
    COALESCE(SUM(od.quantity), 0) AS units_sold_last_90_days,
    ROUND(COALESCE(SUM(od.quantity), 0) / 3, 2) AS avg_monthly_sales,
    CASE 
        WHEN COALESCE(SUM(od.quantity), 0) = 0 THEN NULL
        ELSE ROUND(p.stock_quantity / (COALESCE(SUM(od.quantity), 0) / 3), 2)
    END AS months_of_inventory,
    CASE 
        WHEN COALESCE(SUM(od.quantity), 0) = 0 THEN 'Slow Moving'
        WHEN p.stock_quantity / (COALESCE(SUM(od.quantity), 0) / 3) > 6 THEN 'Overstocked'
        WHEN p.stock_quantity / (COALESCE(SUM(od.quantity), 0) / 3) < 1 THEN 'Understocked'
        ELSE 'Optimal'
    END AS inventory_status
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN orders o ON od.order_id = o.order_id 
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    AND o.order_status NOT IN ('Cancelled')
GROUP BY p.product_id, p.product_name, c.category_name, p.stock_quantity
ORDER BY months_of_inventory DESC;

-- ============================================
-- SECTION 5: BUSINESS INSIGHTS
-- ============================================

-- Query 13: Order Fulfillment Performance
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    AVG(DATEDIFF(ship_date, order_date)) AS avg_days_to_ship,
    AVG(DATEDIFF(delivery_date, ship_date)) AS avg_days_to_deliver,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY order_status
ORDER BY order_count DESC;

-- Query 14: Payment Method Analysis
SELECT 
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_transaction_value,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS usage_percentage
FROM orders
WHERE order_status NOT IN ('Cancelled')
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Query 15: Geographic Sales Analysis
SELECT 
    shipping_state,
    shipping_city,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS revenue_rank
FROM orders
WHERE order_status NOT IN ('Cancelled')
GROUP BY shipping_state, shipping_city
ORDER BY total_revenue DESC
LIMIT 20;

-- Query 16: Customer Segmentation by Value
SELECT 
    value_tier,
    COUNT(*) AS customer_count,
    AVG(total_orders) AS avg_orders_per_customer,
    AVG(lifetime_value) AS avg_lifetime_value,
    SUM(lifetime_value) AS total_segment_value,
    ROUND(SUM(lifetime_value) * 100.0 / SUM(SUM(lifetime_value)) OVER (), 2) AS revenue_contribution_pct
FROM (
    SELECT 
        c.customer_id,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS lifetime_value,
        CASE 
            WHEN SUM(o.total_amount) >= 3000 THEN 'Platinum'
            WHEN SUM(o.total_amount) >= 2000 THEN 'Gold'
            WHEN SUM(o.total_amount) >= 1000 THEN 'Silver'
            ELSE 'Bronze'
        END AS value_tier
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status NOT IN ('Cancelled')
    GROUP BY c.customer_id
) AS customer_values
GROUP BY value_tier
ORDER BY avg_lifetime_value DESC;

-- Query 17: Product Review Analysis
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    COUNT(r.review_id) AS total_reviews,
    AVG(r.rating) AS avg_rating,
    SUM(CASE WHEN r.rating = 5 THEN 1 ELSE 0 END) AS five_star_count,
    SUM(CASE WHEN r.rating = 1 THEN 1 ELSE 0 END) AS one_star_count,
    SUM(r.helpful_count) AS total_helpful_votes,
    ROUND(SUM(CASE WHEN r.rating >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(r.review_id), 2) AS positive_review_pct
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, c.category_name
HAVING COUNT(r.review_id) > 0
ORDER BY avg_rating DESC, total_reviews DESC;

-- Query 18: Year-over-Year Growth Analysis
SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(order_id) AS orders,
    SUM(total_amount) AS revenue,
    LAG(SUM(total_amount)) OVER (PARTITION BY MONTH(order_date) ORDER BY YEAR(order_date)) AS prev_year_revenue,
    ROUND((SUM(total_amount) - LAG(SUM(total_amount)) OVER (PARTITION BY MONTH(order_date) ORDER BY YEAR(order_date))) / 
          LAG(SUM(total_amount)) OVER (PARTITION BY MONTH(order_date) ORDER BY YEAR(order_date)) * 100, 2) AS yoy_growth_pct
FROM orders
WHERE order_status NOT IN ('Cancelled')
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- ============================================
-- SECTION 6: ADVANCED ANALYTICS
-- ============================================

-- Query 19: Customer Churn Prediction
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS lifetime_value,
    CASE 
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 180 THEN 'High Churn Risk'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 90 THEN 'Medium Churn Risk'
        WHEN DATEDIFF(CURDATE(), MAX(o.order_date)) > 60 THEN 'Low Churn Risk'
        ELSE 'Active'
    END AS churn_risk
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status NOT IN ('Cancelled')
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 0
ORDER BY days_since_last_order DESC;

-- Query 20: Profitability Analysis
SELECT 
    c.category_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    SUM(od.quantity) AS units_sold,
    SUM(od.line_total) AS total_revenue,
    SUM(od.quantity * p.cost_price) AS total_cost,
    SUM(od.line_total) - SUM(od.quantity * p.cost_price) AS gross_profit,
    ROUND((SUM(od.line_total) - SUM(od.quantity * p.cost_price)) / SUM(od.line_total) * 100, 2) AS profit_margin_pct
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
WHERE o.order_status NOT IN ('Cancelled')
  AND p.cost_price IS NOT NULL
GROUP BY c.category_name
ORDER BY gross_profit DESC;

-- ============================================
-- END OF QUERIES
-- ============================================
