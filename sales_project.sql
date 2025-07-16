--
SHOW DATABASES;
USE shop;
CREATE TABLE sales (
    order_id INT PRIMARY KEY,
    order_date DATETIME,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code INT,
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(30),
    cost_price INT,
    quantity INT,
    discount DECIMAL(7,2),
    selling_price DECIMAL(10,2),
    profit DECIMAL(10,2)
);
SELECT * FROM sales LIMIT 10;

-- Total revenue generated

SELECT 
	SUM(selling_price*quantity) AS total_revenue
FROM sales;

-- Total Revenue by Product / Sub-Category

SELECT 
	category,
    sub_category,
    SUM(selling_price*quantity) AS total_revenue
FROM sales
GROUP BY category,sub_category;

-- Month-over-Month Revenue Growth

WITH monthly_revenue AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(selling_price * quantity) AS revenue
    FROM sales
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    year, 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY year, month) AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY year, month)) / 
        LAG(revenue) OVER (ORDER BY year, month) * 100, 2
    ) AS mom_growth_percentage
FROM monthly_revenue;

-- TOP 10 HIGHEST REVENUE GENERATING PRODUCTS

SELECT sub_category,SUM(selling_price*quantity )AS revenue
FROM sales
GROUP BY sub_category
ORDER BY revenue DESC
LIMIT 10;

-- Highest selling products 

SELECT * FROM sales LIMIT 10;
WITH region_sales AS 
(
    SELECT 
        region,
        SUM(selling_price*quantity) AS revenue
    FROM sales
    GROUP BY region
),
ranked_regions AS (
    SELECT 
        region,
        revenue,
        RANK() OVER (ORDER BY revenue DESC) AS region_rank
    FROM region_sales
)
SELECT * 
FROM ranked_regions;

SELECT * FROM sales LIMIT 10;
SELECT year(order_date) AS date_year FROM sales
GROUP BY date_year;

-- Month over month growth comparison  

WITH monthly_sales AS
(
	SELECT 
		MONTH(order_date) AS sales_month,
        YEAR(order_date) AS sales_year,
        SUM(selling_price*quantity) AS revenue
        FROM sales
        GROUP BY sales_month,sales_year
)
SELECT 
    sales_year,
    sales_month,
    revenue,
    LAG(revenue) OVER (ORDER BY sales_month,sales_year) AS previous_month_sales
FROM monthly_sales;

-- Highest monthly sales by category

SELECT * FROM sales
LIMIT 10;

WITH cte AS (
    SELECT 
        MONTH(order_date) AS order_month,
        category,
        SUM(selling_price*quantity) AS revenue
    FROM sales
    GROUP BY MONTH(order_date), category
),
ranked_sales AS (
    SELECT
        category,
        order_month,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY order_month) AS monthly_rank
    FROM cte
)
SELECT *
FROM ranked_sales
WHERE monthly_rank = 1;

-- Which Sub-Category had the highest profit in 2023 when compared to 2022
SELECT * FROM sales LIMIT 10;

WITH CTE AS (
    SELECT 
        YEAR(order_date) AS order_year,
        sub_category,
        SUM(selling_price * quantity) AS revenue
    FROM sales
    GROUP BY YEAR(order_date), sub_category
)

SELECT 
    sub_category,
    order_year,
    revenue AS current_year_revenue,
    LAG(revenue) OVER (PARTITION BY sub_category ORDER BY order_year) AS previous_year_revenue,
    (revenue - LAG(revenue) OVER (PARTITION BY sub_category ORDER BY order_year)) AS revenue_difference
FROM CTE
GROUP BY sub_category,order_year
ORDER BY revenue_difference DESC;









