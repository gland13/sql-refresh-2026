-- Day 2 SQL Practice
-- Source: https://www.sql-practice.online
-- Focus: SELECT, JOIN, GROUP BY

-- Example 1: customers and orders
SELECT c.customer_id,
       c.customer_name,
       o.order_id,
       o.order_date
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id;

-- Example 2: total orders per customer
SELECT c.customer_id,
       c.customer_name,
       COUNT(*) AS order_count
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Add a couple more examples here later as you practice
