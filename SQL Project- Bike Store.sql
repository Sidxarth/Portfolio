use BikeStore

-- Dataset obtained from www.sqlservertutorial.net.

-- 1. Retrieve All Products and Their Categories

SELECT p.product_name, c.category_name
FROM production.products p
JOIN production.categories c ON p.category_id = c.category_id;

-- 2. Aggregating Data: Total Sales by Product

SELECT p.product_name, SUM(oi.quantity * oi.list_price) AS total_sales
FROM sales.order_items oi
JOIN production.products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- 3. Filtering Data: Orders from a Specific Customer

SELECT o.order_id, o.order_date, o.order_status, SUM(oi.quantity * oi.list_price) AS order_total
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = 1204  
GROUP BY o.order_id, o.order_date, o.order_status;

-- 4. Joining Multiple Tables: Total Sales by Store

SELECT s.store_name, SUM(oi.quantity * oi.list_price) AS total_sales
FROM sales.stores s
JOIN sales.orders o ON s.store_id = o.store_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY s.store_name
ORDER BY total_sales DESC;

-- 5. Subquery: Products Not Sold

SELECT p.product_name
FROM production.products p
WHERE p.product_id NOT IN (SELECT product_id FROM order_items);

-- 6. Analytical Query: Staff Performance by Sales

SELECT st.first_name, st.last_name, SUM(oi.quantity * oi.list_price) AS total_sales
FROM sales.staffs st
JOIN sales.orders o ON st.staff_id = o.staff_id
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY st.first_name, st.last_name
ORDER BY total_sales DESC;

-- 7. Window Function: Cumulative Sales by Date (Most Recent first)

SELECT o.order_date,
       SUM(oi.quantity * oi.list_price) AS daily_sales,
       SUM(SUM(oi.quantity * oi.list_price)) OVER (ORDER BY o.order_date) AS cumulative_sales
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_date
ORDER BY o.order_date desc;

-- 8. Data Cleaning: Identify Duplicate Customers

SELECT c.first_name, c.last_name, COUNT(*) AS duplicate_count
FROM sales.customers c
GROUP BY c.first_name, c.last_name
HAVING COUNT(*) > 1;

-- 9. Adding Category Information to Products

SELECT p.product_name, p.model_year, p.list_price, c.category_name
FROM production.products p
LEFT JOIN production.categories c ON p.category_id = c.category_id;

-- 10. Inventory Valuation by Store

SELECT st.store_name, SUM(p.list_price * si.quantity) AS inventory_value
FROM stores st
JOIN stocks si ON st.store_id = si.store_id
JOIN products p ON si.product_id = p.product_id
GROUP BY st.store_name
ORDER BY inventory_value DESC;

-- 11. Date Function: Sales Growth Month-over-Month

SELECT 
    FORMAT(o.order_date, 'yyyy-MM') AS month,
    SUM(oi.quantity * oi.list_price) AS total_sales,
    LAG(SUM(oi.quantity * oi.list_price)) OVER (ORDER BY FORMAT(o.order_date, 'yyyy-MM')) AS previous_month_sales,
    (SUM(oi.quantity * oi.list_price) - LAG(SUM(oi.quantity * oi.list_price)) OVER (ORDER BY FORMAT(o.order_date, 'yyyy-MM'))) / 
    LAG(SUM(oi.quantity * oi.list_price)) OVER (ORDER BY FORMAT(o.order_date, 'yyyy-MM')) * 100 AS month_over_month_growth
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY FORMAT(o.order_date, 'yyyy-MM')
ORDER BY month;