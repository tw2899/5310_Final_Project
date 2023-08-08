--Total Sales by Location: Calculate the total sales made at each store location to identify the most profitable and least performing stores.
SELECT
    s.location_id,
    s.store_name,
    SUM(ist.transaction_amount) AS total_in_store_sales
FROM Stores AS s
LEFT JOIN In_store_transactions AS ist ON s.location_id = ist.location_id
GROUP BY s.location_id, s.store_name
ORDER BY total_in_store_sales DESC;

SELECT store_location, SUM(CAST(total_price AS NUMERIC)) AS total_sales
FROM customer
GROUP BY store_location;

--Identifies products that have expired or are about to expire.
SELECT
    i.product_name,
    i.expiration_date,
    CASE WHEN i.expiration_date < CURRENT_DATE THEN 'Expired'
         WHEN i.expiration_date >= CURRENT_DATE AND i.expiration_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'Expiring Soon'
         ELSE 'Not Expired' END AS expiration_status
FROM Inventories AS i;

--Which product categories have the highest stock levels?
SELECT product_category, SUM(stock_level) AS total_stock
FROM Inventories
GROUP BY product_category
ORDER BY total_stock DESC;

SELECT product_category, MAX(stock_level) AS highest_stock_level
FROM vendor
GROUP BY product_category;
--How many products have been sold in each store location?
SELECT s.store_name, COUNT(*) AS total_products_sold
FROM stores s
JOIN In_store_transactions ist ON s.location_id = ist.location_id
GROUP BY s.store_name;

--What is the average loyalty points for each membership status?
SELECT membership_status, AVG(loyalty_points) AS avg_loyalty_points
FROM Customer_Membership_Status
GROUP BY membership_status;

--How many deliveries were made on each day?
SELECT delivery_date, COUNT(*) AS total_deliveries
FROM Sup_deliveries
GROUP BY delivery_date;

--Average Transaction Amount by Store Location and Membership Status:
--What is the average transaction amount for each membership status at each store location?
SELECT
    s.location_id,
    s.store_name,
    c.membership_status,
    AVG(ist.transaction_amount) AS avg_transaction_amount
FROM
    stores AS s
JOIN
    In_store_transactions AS ist ON s.location_id = ist.location_id
JOIN
    Customers AS c ON ist.customer_id = c.customer_id
GROUP BY
    s.location_id, s.store_name, c.membership_status
ORDER BY
    s.location_id, s.store_name, c.membership_status;
	
--Monthly Sales Trend:
SELECT EXTRACT(MONTH FROM it.transaction_date) AS transaction_month,
       EXTRACT(YEAR FROM it.transaction_date) AS transaction_year,
       SUM(it.transaction_amount) AS total_sales
FROM In_store_transactions AS it
GROUP BY transaction_month, transaction_year
ORDER BY transaction_year, transaction_month;

--Monthly Customer Spending:
SELECT EXTRACT(MONTH FROM it.transaction_date) AS transaction_month,
       EXTRACT(YEAR FROM it.transaction_date) AS transaction_year,
       c.cus_first_name, c.cus_last_name, SUM(it.transaction_amount) AS total_spent
FROM Customers AS c
JOIN In_store_transactions AS it ON c.customer_id = it.customer_id
GROUP BY transaction_month, transaction_year, c.cus_first_name, c.cus_last_name
ORDER BY transaction_year, transaction_month, total_spent DESC;

--Customer Lifetime Value (CLV):
WITH customer_lifetime_value AS (
    SELECT c.customer_id, c.cus_first_name, c.cus_last_name,
           SUM(it.transaction_amount) AS total_spent
    FROM Customers AS c
    JOIN In_store_transactions AS it ON c.customer_id = it.customer_id
    GROUP BY c.customer_id
)
SELECT cus_first_name, cus_last_name, total_spent,
       total_spent / (SELECT AVG(total_spent) FROM customer_lifetime_value) AS clv_multiplier
FROM customer_lifetime_value
ORDER BY total_spent DESC;

--Customer Churn Analysis:
WITH customer_churn AS (
    SELECT c.customer_id, c.cus_first_name, c.cus_last_name,
           COUNT(it.transaction_id) AS total_transactions
    FROM Customers AS c
    LEFT JOIN In_store_transactions AS it ON c.customer_id = it.customer_id
    GROUP BY c.customer_id
)
SELECT cus_first_name, cus_last_name, total_transactions,
       CASE
           WHEN total_transactions <= 5 THEN 'Low'
           WHEN total_transactions <= 10 THEN 'Medium'
           ELSE 'High'
       END AS churn_risk
FROM customer_churn
ORDER BY total_transactions DESC;

--Store Performance Over Time
SELECT s.store_name, DATE_PART('year', it.transaction_date) AS transaction_year,
       SUM(it.transaction_amount) AS total_sales
FROM stores AS s
JOIN In_store_transactions AS it ON s.location_id = it.location_id
GROUP BY s.store_name, transaction_year
ORDER BY transaction_year, total_sales DESC;

--How many deliveries were made on each day
SELECT delivery_date, COUNT(*) AS number_of_deliveries
FROM vendor
GROUP BY delivery_date;

--The goal of the query is to find the customers with the highest sales
SELECT CONCAT(c.cus_first_name, ' ', c.cus_last_name) AS customer_name,
       SUM(CAST(c.total_price AS NUMERIC)) AS total_sales
FROM customer AS c
GROUP BY c.cus_first_name, c.cus_last_name
ORDER BY total_sales DESC
LIMIT 1;

--Trading products with a trading date in 2022 and the vendor information associated with them.
SELECT c.transaction_product, v.vendor_name, v.vendor_email, v.vendor_phone
FROM customer c
JOIN vendor v ON c.transaction_product = v.product_name
WHERE EXTRACT(YEAR FROM CAST(c.transaction_date AS DATE)) = 2022;

--Find the suppliers with the name 'CASA FORCELLO' and count the number of sales orders for each of their products. The query results will include the product name, the supplier name, and the corresponding sales order quantity.SELECT v.product_name, v.vendor_name, COUNT(c.transaction_product) AS order_count
FROM vendor v
LEFT JOIN customer c ON c.transaction_product = v.product_name
WHERE v.vendor_name = 'CASA FORCELLO'
GROUP BY v.product_name, v.vendor_name;