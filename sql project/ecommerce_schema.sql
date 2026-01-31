-- ============================================
-- E-COMMERCE DATABASE ANALYTICS PROJECT
-- Project: Online Retail Store Database System
-- Author: [Your Name]
-- Purpose: Resume Portfolio Project
-- ============================================

-- Database Creation
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- ============================================
-- TABLE CREATION
-- ============================================

-- 1. Customers Table
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'USA',
    registration_date DATE NOT NULL,
    last_login DATETIME,
    customer_segment VARCHAR(20) DEFAULT 'Regular',
    INDEX idx_email (email),
    INDEX idx_registration (registration_date)
);

-- 2. Categories Table
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- 3. Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    brand VARCHAR(100),
    description TEXT,
    unit_price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2),
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    supplier_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_category (category_id),
    INDEX idx_price (unit_price),
    CHECK (unit_price > 0),
    CHECK (stock_quantity >= 0)
);

-- 4. Orders Table
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ship_date DATE,
    delivery_date DATE,
    order_status VARCHAR(20) DEFAULT 'Pending',
    payment_method VARCHAR(50),
    shipping_address VARCHAR(255),
    shipping_city VARCHAR(50),
    shipping_state VARCHAR(50),
    shipping_zip VARCHAR(10),
    total_amount DECIMAL(12, 2),
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(8, 2) DEFAULT 0,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_customer (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_status (order_status),
    CHECK (order_status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned'))
);

-- 5. Order Details Table
CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(5, 2) DEFAULT 0,
    line_total DECIMAL(12, 2) GENERATED ALWAYS AS (quantity * unit_price * (1 - discount/100)) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id),
    CHECK (quantity > 0)
);

-- 6. Reviews Table
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    review_title VARCHAR(200),
    review_text TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    helpful_count INT DEFAULT 0,
    verified_purchase BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_product (product_id),
    INDEX idx_rating (rating),
    CHECK (rating BETWEEN 1 AND 5)
);

-- 7. Promotions Table
CREATE TABLE promotions (
    promotion_id INT PRIMARY KEY AUTO_INCREMENT,
    promotion_name VARCHAR(100) NOT NULL,
    promotion_type VARCHAR(50),
    discount_percentage DECIMAL(5, 2),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    minimum_purchase DECIMAL(10, 2) DEFAULT 0,
    usage_count INT DEFAULT 0,
    CHECK (discount_percentage BETWEEN 0 AND 100),
    CHECK (end_date >= start_date)
);

-- 8. Suppliers Table
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(255),
    city VARCHAR(50),
    country VARCHAR(50),
    rating DECIMAL(3, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. Inventory Transactions Table
CREATE TABLE inventory_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    quantity INT NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    reference_id INT,
    notes TEXT,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_product (product_id),
    INDEX idx_date (transaction_date),
    CHECK (transaction_type IN ('Purchase', 'Sale', 'Return', 'Adjustment', 'Damaged'))
);

-- 10. Wish List Table
CREATE TABLE wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    added_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    priority INT DEFAULT 1,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_wishlist (customer_id, product_id)
);

-- ============================================
-- VIEWS FOR ANALYTICS
-- ============================================

-- View 1: Customer Purchase Summary
CREATE OR REPLACE VIEW customer_purchase_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.customer_segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status != 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.customer_segment;

-- View 2: Product Performance
CREATE OR REPLACE VIEW product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    p.unit_price,
    p.stock_quantity,
    COUNT(DISTINCT od.order_id) AS times_ordered,
    SUM(od.quantity) AS total_units_sold,
    SUM(od.line_total) AS total_revenue,
    AVG(r.rating) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS review_count
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.product_name, c.category_name, p.unit_price, p.stock_quantity;

-- View 3: Monthly Sales Summary
CREATE OR REPLACE VIEW monthly_sales_summary AS
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS year_month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value,
    SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(CASE WHEN order_status = 'Returned' THEN 1 ELSE 0 END) AS returned_orders
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY year_month DESC;

-- View 4: Category Performance
CREATE OR REPLACE VIEW category_performance AS
SELECT 
    c.category_id,
    c.category_name,
    COUNT(DISTINCT p.product_id) AS product_count,
    COUNT(DISTINCT od.order_id) AS total_orders,
    SUM(od.quantity) AS units_sold,
    SUM(od.line_total) AS total_revenue,
    AVG(od.unit_price) AS avg_product_price
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN order_details od ON p.product_id = od.product_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

-- ============================================
-- STORED PROCEDURES
-- ============================================

-- Procedure 1: Add New Order
DELIMITER //
CREATE PROCEDURE add_new_order(
    IN p_customer_id INT,
    IN p_shipping_address VARCHAR(255),
    IN p_payment_method VARCHAR(50)
)
BEGIN
    DECLARE v_order_id INT;
    
    INSERT INTO orders (customer_id, order_date, shipping_address, payment_method, order_status)
    VALUES (p_customer_id, NOW(), p_shipping_address, p_payment_method, 'Pending');
    
    SET v_order_id = LAST_INSERT_ID();
    SELECT v_order_id AS new_order_id;
END //
DELIMITER ;

-- Procedure 2: Update Order Status
DELIMITER //
CREATE PROCEDURE update_order_status(
    IN p_order_id INT,
    IN p_new_status VARCHAR(20)
)
BEGIN
    UPDATE orders 
    SET order_status = p_new_status,
        ship_date = CASE WHEN p_new_status = 'Shipped' THEN CURDATE() ELSE ship_date END,
        delivery_date = CASE WHEN p_new_status = 'Delivered' THEN CURDATE() ELSE delivery_date END
    WHERE order_id = p_order_id;
    
    SELECT CONCAT('Order ', p_order_id, ' status updated to ', p_new_status) AS message;
END //
DELIMITER ;

-- Procedure 3: Get Customer Statistics
DELIMITER //
CREATE PROCEDURE get_customer_stats(IN p_customer_id INT)
BEGIN
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS lifetime_value,
        AVG(o.total_amount) AS avg_order_value,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE c.customer_id = p_customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name;
END //
DELIMITER ;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger 1: Update product stock after order
DELIMITER //
CREATE TRIGGER after_order_detail_insert
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    INSERT INTO inventory_transactions (product_id, transaction_type, quantity, reference_id)
    VALUES (NEW.product_id, 'Sale', -NEW.quantity, NEW.order_id);
END //
DELIMITER ;

-- Trigger 2: Update order total
DELIMITER //
CREATE TRIGGER after_order_detail_update
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT SUM(line_total)
        FROM order_details
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END //
DELIMITER ;

-- Trigger 3: Prevent deletion of products with orders
DELIMITER //
CREATE TRIGGER before_product_delete
BEFORE DELETE ON products
FOR EACH ROW
BEGIN
    DECLARE order_count INT;
    
    SELECT COUNT(*) INTO order_count
    FROM order_details
    WHERE product_id = OLD.product_id;
    
    IF order_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete product with existing orders';
    END IF;
END //
DELIMITER ;

-- ============================================
-- INDEXES FOR OPTIMIZATION
-- ============================================

CREATE INDEX idx_customer_name ON customers(last_name, first_name);
CREATE INDEX idx_product_name ON products(product_name);
CREATE INDEX idx_order_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_review_product_rating ON reviews(product_id, rating);

-- ============================================
-- NOTES
-- ============================================
-- This database schema supports:
-- 1. Customer management and segmentation
-- 2. Product catalog with categories
-- 3. Order processing and tracking
-- 4. Inventory management
-- 5. Customer reviews and ratings
-- 6. Promotions and discounts
-- 7. Sales analytics and reporting
-- ============================================
