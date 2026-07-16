SELECT * FROM customers


-- Return products that cost more than $100.
SELECT Product_name, price
FROM products
WHERE price > 100

-- Return all products ordered by price descending.
SELECT product_name, price
FROM products
ORDER BY price DESC

-- Return customers from the USA.
SELECT first_name, last_name, city
FROM customers
WHERE country = 'USA'

-- Count the total number of products.
SELECT COUNT(*) FROM products

-- Calculate the average price across all products.
SELECT AVG(price) AS average_price
FROM products

-- Return products that belong to the Electronics category.
SELECT product_name, price
FROM products
WHERE category_id = 1

-- Return orders with a delivered status.
SELECT ORDER_id, customer_id, total_amount
FROM orders
WHERE status = 'delivered'
ORDER BY ORDER_ID ASC

-- Return products with stock quantities greater than 50.
SELECT product_name, stock_quantity
FROM products
WHERE stock_quantity > 50
ORDER BY stock_quantity DESC

-- Return June 2023 orders and calculate how many days ago each order was placed as of 2023-07-01.
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount,
    status,
    CAST(
        julianday('2023-07-01') - julianday(order_date)
        AS INTEGER
    ) AS days_ago
FROM orders
WHERE strftime('%Y-%m', order_date) = '2023-06'   -- only June 2023
ORDER BY order_date;

-- Return each unique country with at least one registered customer.
SELECT DISTINCT(COUNTry)
FROM customers
ORDER BY COUNTry DESC

-- Return customers who registered between January 1 and March 31, 2023.
SELECT first_name, last_name, registration_date, country
FROM customers
WHERE registration_date >= '2023-01-01' AND registration_date <= '2023-03-31'
ORDER BY registration_date ASC

-- Return customers who have not provided their city.
SELECT first_name, last_name, email, registration_date
FROM customers
WHERE city IS NULL
ORDER BY registration_date

-- Return customer names together with their order information.
SELECT c.first_name, c.last_name, o.ORDER_id, o.total_amount, o.status
FROM customers c
JOIN ORDERs o
ON c.customer_id = o.customer_id
ORDER BY ORDER_id DESC

-- Count the number of orders per customer.
SELECT c.first_name, c.last_name, count(o.order_id) ORDER_count
FROM customers c
Left JOIN ORDERs O
ON c.customer_id = o.customer_id
GROUP BY c.customer_ID
ORDER BY ORDER_count DESC

-- Return products together with their category names.
SELECT p.product_name, c.category_name, p.price
FROM products p
JOIN categories c
ON p.category_id = c.category_id

-- Return categories with more than $200 in revenue.
SELECT c.category_name, SUM(o.quantity * o.unit_price) AS total_revenue
FROM categories c
JOIN products p
ON p.category_id = c.category_id
JOIN order_items o
on o.product_id = p.product_id
GROUP BY c.category_name
HAVING SUM(o.quantity * o.Unit_price) > 200
ORDER BY c.category_name;

-- Return products that have never appeared in any order.
SELECT p.product_name, p.price, p.stock_quantity
FROM products p
LEFT JOIN order_items O
ON o.product_id = p.product_ID
WHERE o.product_id IS NULL
ORDER BY p.price DESC;

-- Return non-Electronics products priced below the most expensive Electronics item.
SELECT p.product_name, p.price, c.category_name
FROM products p
JOIN categories c
ON p.category_id = c.category_id
WHERE c.category_name <> 'Electronics'
AND p.price < (
  SELECT MAX(p2.price)
  FROM products p2 
  JOIN categories c2 
  ON p2.category_id = c2.category_id 
  WHERE c2.category_name = 'Electronics'
  )
ORDER By p.price 

-- Return every order item with the customer name, category name, product name, quantity, and unit price.
SELECT cu.first_name, cu.last_name, ca.category_name, p.product_name, oi.quantity, oi.unit_price
FROM customers cu
JOIN ORDERs o
ON cu.customer_id = o.customer_id
JOIN ORDER_items oi
ON o.ORDER_id = oi.ORDER_id
JOIN Products p
ON p.product_id = oi.product_id
JOIN categories ca
ON ca.category_id = p.category_id
ORDER BY cu.last_name ASC, ca.category_name ASC;

-- Return all customers with their order status, replacing missing order status values with a readable label.
SELECT c.first_name, c.last_name, c.country, COALESCE(o.status, 'No Orders') ORDER_Status, o.total_amount
FROM customers c
LEFT JOIN ORDERs O
ON c.customer_id = o.customer_id
ORDER BY c.last_name

-- Combine fulfilled and pending orders into one labeled result set.
SELECT
    order_id,
    customer_id,
    status,
    total_amount,
    'Fulfilled' AS urgency
FROM orders
WHERE status IN ('delivered', 'shipped')

UNION ALL

SELECT
    order_id,
    customer_id,
    status,
    total_amount,
    'Action Required' AS urgency
FROM orders
WHERE status = 'pending'   -- match actual status text
ORDER BY urgency, order_id;

-- Rank all products by price across the entire catalog.
SELECT product_name, price, RANK() OVER(ORDER BY price DESC) AS Price_rank
FROM products
ORDER BY price_rank

-- Return the top customer by total spending using a subquery.
SELECT
    c.first_name,
    c.last_name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING SUM(o.total_amount) = (
    SELECT MAX(total_spent)
    FROM (
        SELECT
            customer_id,
            SUM(total_amount) AS total_spent
        FROM orders
        GROUP BY customer_id
    ) AS x
)
ORDER BY total_spent DESC;

-- For every customer, calculate order count, total spend, delivered spend, and assign a customer tier.
With cust_stats
AS
(SELECT  c.first_name
      , c.last_name
      , c.country
      , COUNT(o.ORDER_id) AS total_orders
      , SUM(o.total_amount) AS total_spent
      , SUM (CASE WHEN o.status = 'delivered' THEN o.total_amount 
            ELSE 0 
        END )AS delivered_value
FROM customers c
LEFT JOIN Orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT first_name
      , last_name 
      , country
      , total_orders
      , total_spent
      , CASE WHEN total_spent >= 1000 THEN 'VIP'
          WHEN total_spent >= 100 THEN 'Regular'
          ELSE 'Regular'
        END customer_tier
      , delivered_value 
FROM cust_stats
ORDER BY total_spent DESC

-- Rank customers by total spending and assign percentile-style tiers.
SELECT
    c.first_name,
    c.last_name,
    c.country,
    Coalesce(SUM(o.total_amount), 0) AS total_spent,
    CASE
        WHEN SUM(o.total_amount) >= 1000 THEN 1
        WHEN SUM(o.total_amount) >= 100 THEN 2
        WHEN SUM(o.total_amount) <  100 THEN 3
        ELSE 3
    END AS Spending_Tier,
    PERCENT_RANK() OVER (
        ORDER BY Coalesce(SUM(o.total_amount),0) ASC
    ) AS percentile_rank
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country
ORDER BY total_spent DESC;

-- Use a CTE to find the highest-priced product in each category.
WITH High_Price
AS(
  SELECT category_id, MAX(price) hprice
  FROM products
  GROUP BY category_id
)
SELECT p.product_name, c.category_name, h.hprice  AS price
FROM products p
JOIN categories c
ON p.category_id = c.category_id
JOIN High_price h
ON h.category_id = c.category_id
WHERE p.price = h.hprice
ORDER BY price DESC

-- Rank products by price within their own category.
SELECT  p.product_name
      , c.category_name
      , p.price
      , RANK() OVER(PARTITION BY c.category_name ORDER BY p.price DESC) AS price_rank
FROM products p
JOIN categories c
ON p.category_id = c.category_id
ORDER BY category_name ,  price_rank

-- Return products priced above the average price of their own category.
SELECT  p.product_name
      , c.category_name
      , p.price
FROM products p
JOIN categories c
ON p.category_id = c.category_id
WHERE p.price > (
      SELECT AVG(p2.price)
      FROM products p2
      WHERE p2.category_id = p.category_id
)
ORDER BY c.category_name, p.price DESC

-- Return the top 5 products by total revenue.
SELECT  p.product_name
      , c.category_name
      , SUM(oi.quantity) AS total_qty_sold
      , SUM(oi.quantity * p.price) AS total_revenue
FROM products p
JOIN categories c
ON p.category_id = c.category_id
JOIN order_items oi
ON oi.product_id = p.product_id
GROUP BY  p.product_id
        , c.category_id
ORDER BY total_revenue DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;


