-- ============================================
-- SAMPLE DATA INSERTION
-- E-Commerce Database
-- ============================================

USE ecommerce_db;

-- Insert Categories
INSERT INTO categories (category_name, description, parent_category_id) VALUES
('Electronics', 'Electronic devices and accessories', NULL),
('Clothing', 'Apparel and fashion items', NULL),
('Home & Kitchen', 'Home improvement and kitchen items', NULL),
('Books', 'Physical and digital books', NULL),
('Sports', 'Sports equipment and accessories', NULL),
('Laptops', 'Laptop computers', 1),
('Smartphones', 'Mobile phones and accessories', 1),
('Men''s Clothing', 'Clothing for men', 2),
('Women''s Clothing', 'Clothing for women', 2),
('Kitchen Appliances', 'Kitchen tools and appliances', 3);

-- Insert Suppliers
INSERT INTO suppliers (supplier_name, contact_person, email, phone, city, country, rating) VALUES
('TechWorld Inc', 'John Smith', 'john@techworld.com', '555-0101', 'New York', 'USA', 4.5),
('Fashion Hub Ltd', 'Sarah Johnson', 'sarah@fashionhub.com', '555-0102', 'Los Angeles', 'USA', 4.2),
('Home Essentials Co', 'Mike Brown', 'mike@homeessentials.com', '555-0103', 'Chicago', 'USA', 4.7),
('Book Masters', 'Emily Davis', 'emily@bookmasters.com', '555-0104', 'Boston', 'USA', 4.3),
('Sports Gear Pro', 'David Wilson', 'david@sportsgear.com', '555-0105', 'Seattle', 'USA', 4.6);

-- Insert Products
INSERT INTO products (product_name, category_id, brand, description, unit_price, cost_price, stock_quantity, reorder_level, supplier_id) VALUES
-- Electronics
('Dell XPS 15 Laptop', 6, 'Dell', 'High-performance laptop with 16GB RAM', 1299.99, 950.00, 25, 5, 1),
('MacBook Pro 14"', 6, 'Apple', 'M2 chip with 512GB SSD', 1999.99, 1500.00, 15, 5, 1),
('HP Pavilion', 6, 'HP', 'Budget-friendly laptop for everyday use', 699.99, 500.00, 40, 10, 1),
('iPhone 14 Pro', 7, 'Apple', 'Latest iPhone with advanced camera', 999.99, 750.00, 50, 10, 1),
('Samsung Galaxy S23', 7, 'Samsung', 'Android smartphone with great display', 899.99, 650.00, 45, 10, 1),
('Google Pixel 7', 7, 'Google', 'Stock Android experience', 699.99, 500.00, 30, 8, 1),

-- Clothing
('Men''s Casual Shirt', 8, 'Levi''s', 'Cotton casual shirt', 39.99, 20.00, 100, 20, 2),
('Men''s Jeans', 8, 'Wrangler', 'Classic fit jeans', 59.99, 30.00, 80, 15, 2),
('Men''s Jacket', 8, 'North Face', 'Waterproof winter jacket', 129.99, 75.00, 40, 10, 2),
('Women''s Dress', 9, 'Zara', 'Elegant evening dress', 89.99, 45.00, 60, 12, 2),
('Women''s Blouse', 9, 'H&M', 'Professional work blouse', 34.99, 18.00, 90, 18, 2),

-- Home & Kitchen
('Coffee Maker', 10, 'Keurig', 'Single-serve coffee maker', 89.99, 55.00, 50, 10, 3),
('Blender', 10, 'Ninja', 'High-speed blender', 69.99, 40.00, 60, 12, 3),
('Air Fryer', 10, 'Philips', 'Healthy air fryer', 119.99, 70.00, 35, 8, 3),
('Cookware Set', 10, 'Cuisinart', '10-piece cookware set', 199.99, 120.00, 25, 5, 3),

-- Books
('The Great Gatsby', 4, 'Penguin', 'Classic American novel', 14.99, 8.00, 150, 30, 4),
('1984', 4, 'Signet', 'Dystopian fiction', 13.99, 7.50, 200, 40, 4),
('To Kill a Mockingbird', 4, 'Harper', 'Pulitzer Prize winner', 15.99, 9.00, 120, 25, 4),

-- Sports
('Yoga Mat', 5, 'Manduka', 'Premium yoga mat', 49.99, 25.00, 70, 15, 5),
('Dumbbells Set', 5, 'Bowflex', 'Adjustable dumbbells', 299.99, 180.00, 30, 8, 5),
('Running Shoes', 5, 'Nike', 'Comfortable running shoes', 129.99, 75.00, 55, 12, 5);

-- Insert Customers
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, zip_code, registration_date, customer_segment) VALUES
('James', 'Anderson', 'james.anderson@email.com', '555-1001', '123 Main St', 'New York', 'NY', '10001', '2023-01-15', 'Premium'),
('Maria', 'Garcia', 'maria.garcia@email.com', '555-1002', '456 Oak Ave', 'Los Angeles', 'CA', '90001', '2023-02-20', 'Regular'),
('Robert', 'Martinez', 'robert.martinez@email.com', '555-1003', '789 Pine Rd', 'Chicago', 'IL', '60601', '2023-03-10', 'Premium'),
('Jennifer', 'Lopez', 'jennifer.lopez@email.com', '555-1004', '321 Elm St', 'Houston', 'TX', '77001', '2023-04-05', 'Regular'),
('Michael', 'Brown', 'michael.brown@email.com', '555-1005', '654 Maple Dr', 'Phoenix', 'AZ', '85001', '2023-05-12', 'VIP'),
('Sarah', 'Davis', 'sarah.davis@email.com', '555-1006', '987 Cedar Ln', 'Philadelphia', 'PA', '19101', '2023-06-18', 'Regular'),
('David', 'Wilson', 'david.wilson@email.com', '555-1007', '147 Birch Way', 'San Antonio', 'TX', '78201', '2023-07-22', 'Premium'),
('Lisa', 'Taylor', 'lisa.taylor@email.com', '555-1008', '258 Spruce Ct', 'San Diego', 'CA', '92101', '2023-08-30', 'Regular'),
('William', 'Thomas', 'william.thomas@email.com', '555-1009', '369 Ash Blvd', 'Dallas', 'TX', '75201', '2023-09-14', 'VIP'),
('Emma', 'Johnson', 'emma.johnson@email.com', '555-1010', '741 Walnut St', 'San Jose', 'CA', '95101', '2023-10-08', 'Premium');

-- Insert Promotions
INSERT INTO promotions (promotion_name, promotion_type, discount_percentage, start_date, end_date, is_active, minimum_purchase) VALUES
('Summer Sale 2024', 'Seasonal', 15.00, '2024-06-01', '2024-08-31', TRUE, 50.00),
('Black Friday Deal', 'Holiday', 25.00, '2024-11-25', '2024-11-30', TRUE, 100.00),
('New Customer Discount', 'Welcome', 10.00, '2024-01-01', '2024-12-31', TRUE, 0.00),
('Clearance Sale', 'Clearance', 30.00, '2024-12-01', '2024-12-31', TRUE, 75.00);

-- Insert Orders
INSERT INTO orders (customer_id, order_date, ship_date, delivery_date, order_status, payment_method, shipping_address, shipping_city, shipping_state, shipping_zip, discount_amount, tax_amount, shipping_cost) VALUES
(1, '2024-01-10 10:30:00', '2024-01-11', '2024-01-15', 'Delivered', 'Credit Card', '123 Main St', 'New York', 'NY', '10001', 0, 120.50, 10.00),
(2, '2024-01-12 14:20:00', '2024-01-13', '2024-01-17', 'Delivered', 'PayPal', '456 Oak Ave', 'Los Angeles', 'CA', '90001', 15.00, 85.30, 8.00),
(3, '2024-01-15 09:45:00', '2024-01-16', '2024-01-20', 'Delivered', 'Credit Card', '789 Pine Rd', 'Chicago', 'IL', '60601', 0, 95.20, 12.00),
(1, '2024-02-05 11:15:00', '2024-02-06', '2024-02-10', 'Delivered', 'Credit Card', '123 Main St', 'New York', 'NY', '10001', 25.00, 45.80, 10.00),
(4, '2024-02-08 16:30:00', '2024-02-09', NULL, 'Shipped', 'Debit Card', '321 Elm St', 'Houston', 'TX', '77001', 0, 32.50, 8.00),
(5, '2024-02-10 13:00:00', '2024-02-11', '2024-02-15', 'Delivered', 'Credit Card', '654 Maple Dr', 'Phoenix', 'AZ', '85001', 50.00, 180.00, 15.00),
(6, '2024-02-12 10:20:00', NULL, NULL, 'Processing', 'PayPal', '987 Cedar Ln', 'Philadelphia', 'PA', '19101', 0, 28.60, 8.00),
(7, '2024-02-14 15:45:00', '2024-02-15', '2024-02-19', 'Delivered', 'Credit Card', '147 Birch Way', 'San Antonio', 'TX', '78201', 10.00, 65.50, 10.00),
(8, '2024-02-18 12:30:00', '2024-02-19', NULL, 'Shipped', 'Debit Card', '258 Spruce Ct', 'San Diego', 'CA', '92101', 0, 42.30, 8.00),
(9, '2024-02-20 09:00:00', '2024-02-21', '2024-02-25', 'Delivered', 'Credit Card', '369 Ash Blvd', 'Dallas', 'TX', '75201', 75.00, 220.00, 15.00),
(10, '2024-02-22 14:15:00', NULL, NULL, 'Pending', 'PayPal', '741 Walnut St', 'San Jose', 'CA', '95101', 0, 38.90, 8.00),
(2, '2024-03-01 11:45:00', '2024-03-02', '2024-03-06', 'Delivered', 'Credit Card', '456 Oak Ave', 'Los Angeles', 'CA', '90001', 20.00, 52.40, 10.00),
(3, '2024-03-05 16:20:00', '2024-03-06', NULL, 'Shipped', 'PayPal', '789 Pine Rd', 'Chicago', 'IL', '60601', 0, 78.50, 12.00),
(5, '2024-03-08 13:30:00', NULL, NULL, 'Cancelled', 'Credit Card', '654 Maple Dr', 'Phoenix', 'AZ', '85001', 0, 0, 0),
(7, '2024-03-10 10:00:00', '2024-03-11', '2024-03-15', 'Delivered', 'Debit Card', '147 Birch Way', 'San Antonio', 'TX', '78201', 15.00, 48.20, 8.00);

-- Insert Order Details
INSERT INTO order_details (order_id, product_id, quantity, unit_price, discount) VALUES
-- Order 1
(1, 1, 1, 1299.99, 0),
(1, 12, 1, 89.99, 0),

-- Order 2
(2, 7, 2, 39.99, 5),
(2, 16, 1, 14.99, 0),

-- Order 3
(3, 4, 1, 999.99, 0),

-- Order 4
(4, 11, 2, 34.99, 10),
(4, 19, 1, 49.99, 0),

-- Order 5
(5, 8, 1, 59.99, 0),
(5, 16, 2, 14.99, 0),

-- Order 6
(6, 2, 1, 1999.99, 0),
(6, 15, 1, 199.99, 0),

-- Order 7
(7, 12, 1, 89.99, 0),
(7, 13, 1, 69.99, 0),

-- Order 8
(8, 9, 1, 129.99, 0),
(8, 18, 1, 15.99, 0),

-- Order 9
(9, 20, 2, 299.99, 0),

-- Order 10
(10, 5, 1, 899.99, 0),

-- Order 11
(11, 10, 1, 89.99, 15),
(11, 17, 1, 13.99, 0),

-- Order 12
(12, 14, 1, 119.99, 0),
(12, 21, 1, 129.99, 0),

-- Order 13
(13, 3, 1, 699.99, 0),
(13, 19, 2, 49.99, 0),

-- Order 14 (Cancelled)
(14, 6, 1, 699.99, 0),

-- Order 15
(15, 7, 3, 39.99, 10),
(15, 11, 2, 34.99, 5);

-- Insert Reviews
INSERT INTO reviews (product_id, customer_id, rating, review_title, review_text, verified_purchase, helpful_count) VALUES
(1, 1, 5, 'Excellent Laptop!', 'This laptop exceeded my expectations. Fast and reliable.', TRUE, 15),
(1, 3, 4, 'Great Performance', 'Very good laptop but a bit pricey.', TRUE, 8),
(4, 2, 5, 'Best Phone Ever', 'Amazing camera quality and battery life.', TRUE, 22),
(4, 9, 5, 'Worth Every Penny', 'Switched from Android and loving it!', TRUE, 18),
(7, 2, 4, 'Good Quality Shirt', 'Fits well and comfortable material.', TRUE, 5),
(8, 4, 5, 'Perfect Fit', 'These jeans are comfortable and durable.', TRUE, 7),
(12, 1, 5, 'Morning Essential', 'Makes perfect coffee every time!', TRUE, 12),
(12, 7, 4, 'Good Coffee Maker', 'Works well but cleaning could be easier.', TRUE, 6),
(2, 6, 5, 'MacBook Excellence', 'Best laptop for creative work!', TRUE, 25),
(5, 5, 4, 'Solid Android Phone', 'Great features at a good price point.', TRUE, 10);

-- Insert Wishlist Items
INSERT INTO wishlist (customer_id, product_id, priority) VALUES
(1, 2, 1),
(1, 14, 2),
(2, 4, 1),
(3, 20, 1),
(3, 21, 2),
(4, 9, 1),
(5, 15, 1),
(6, 1, 1),
(7, 13, 2),
(8, 10, 1);

-- Insert Inventory Transactions
INSERT INTO inventory_transactions (product_id, transaction_type, quantity, transaction_date, notes) VALUES
(1, 'Purchase', 50, '2024-01-01', 'Initial stock'),
(2, 'Purchase', 30, '2024-01-01', 'Initial stock'),
(3, 'Purchase', 60, '2024-01-01', 'Initial stock'),
(4, 'Purchase', 100, '2024-01-01', 'Initial stock'),
(5, 'Purchase', 80, '2024-01-01', 'Initial stock'),
(1, 'Adjustment', -5, '2024-02-15', 'Damaged in warehouse'),
(4, 'Return', 2, '2024-02-20', 'Customer returns'),
(12, 'Purchase', 25, '2024-03-01', 'Restocking'),
(15, 'Adjustment', -3, '2024-03-05', 'Display units');

-- ============================================
-- DATA VERIFICATION QUERIES
-- ============================================

SELECT 'Categories Created:' AS Info, COUNT(*) AS Count FROM categories
UNION ALL
SELECT 'Products Created:', COUNT(*) FROM products
UNION ALL
SELECT 'Customers Created:', COUNT(*) FROM customers
UNION ALL
SELECT 'Orders Created:', COUNT(*) FROM orders
UNION ALL
SELECT 'Order Details Created:', COUNT(*) FROM order_details
UNION ALL
SELECT 'Reviews Created:', COUNT(*) FROM reviews
UNION ALL
SELECT 'Promotions Created:', COUNT(*) FROM promotions
UNION ALL
SELECT 'Suppliers Created:', COUNT(*) FROM suppliers;
