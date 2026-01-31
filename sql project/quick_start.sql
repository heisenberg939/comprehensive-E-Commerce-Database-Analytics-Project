-- ============================================
-- QUICK START GUIDE
-- E-Commerce Database Project
-- ============================================

-- Step 1: Create and Use Database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Step 2: Verify Installation
-- Run this query after loading schema and data
SELECT 
    'Database Check' AS check_type,
    'Success' AS status;

-- Show all tables
SHOW TABLES;

-- Count records in each table
SELECT 'customers' AS table_name, COUNT(*) AS record_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'promotions', COUNT(*) FROM promotions
UNION ALL
SELECT 'wishlist', COUNT(*) FROM wishlist
UNION ALL
SELECT 'inventory_transactions', COUNT(*) FROM inventory_transactions;

-- ============================================
-- QUICK SAMPLE QUERIES TO TEST
-- ============================================

-- 1. View all customers
SELECT * FROM customers LIMIT 5;

-- 2. View recent orders
SELECT 
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    o.order_date,
    o.total_amount,
    o.order_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC
LIMIT 10;

-- 3. Top 5 products by revenue
SELECT 
    p.product_name,
    SUM(od.line_total) AS revenue
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 5;

-- 4. Customer purchase summary
SELECT * FROM customer_purchase_summary
ORDER BY total_spent DESC
LIMIT 5;

-- 5. Monthly sales
SELECT * FROM monthly_sales_summary
ORDER BY year_month DESC;

-- ============================================
-- TEST STORED PROCEDURES
-- ============================================

-- Test: Get customer statistics
CALL get_customer_stats(1);

-- Test: Update order status
CALL update_order_status(1, 'Delivered');

-- ============================================
-- HELPFUL COMMANDS
-- ============================================

-- Show database structure
DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;

-- Show all views
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

-- Show all procedures
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce_db';

-- Show all triggers
SHOW TRIGGERS;

-- Check indexes
SHOW INDEX FROM orders;
SHOW INDEX FROM products;

-- ============================================
-- DATA QUALITY CHECKS
-- ============================================

-- Check for orders without customers (should be 0)
SELECT COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Check for products without categories (should be 0)
SELECT COUNT(*) AS orphan_products
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;

-- Check for negative stock (should be 0)
SELECT COUNT(*) AS negative_stock_products
FROM products
WHERE stock_quantity < 0;

-- Check for invalid ratings (should be 0)
SELECT COUNT(*) AS invalid_ratings
FROM reviews
WHERE rating < 1 OR rating > 5;

-- ============================================
-- PERFORMANCE TESTING
-- ============================================

-- Test query performance
EXPLAIN SELECT 
    c.customer_id,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- ============================================
-- CONGRATULATIONS!
-- Your e-commerce database is ready to use!
-- ============================================
