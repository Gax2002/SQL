CREATE DATABASE PROJECT_01;

DROP TABLE IF EXISTS RETAIL_SALES_DATA;
CREATE TABLE IF NOT EXISTS RETAIL_SALES_DATA (
	"transactions_id" INT,
	"sale_date" DATE,
	"sale_time" TIME,
	"customer_id" INT,
	"gender" VARCHAR(15),
	"age" INT,
	"category" VARCHAR(15),
	"quantity" INT,
	"price_per_unit" FLOAT,
	"cogs" FLOAT,
	"total_sale" FLOAT,
	CONSTRAINT "pk_retail" PRIMARY KEY ("transactions_id")
);

COPY RETAIL_SALES_DATA
FROM
	'D:\DS_Analytics\SQL_files\project_01\SQL - Retail Sales Analysis_utf .csv' DELIMITER ',' CSV HEADER;

SELECT
	*
FROM
	RETAIL_SALES_DATA;

-- Data cleaning
-- Null records : Age(10), Quantity(3), Price_per_unit(3), Cogs(3), Total_sale(3)
SELECT
	*
FROM
	RETAIL_SALES_DATA
WHERE
	"transactions_id" IS NULL
	OR "sale_date" IS NULL
	OR "sale_time" IS NULL
	OR "customer_id" IS NULL
	OR "gender" IS NULL
	OR "age" IS NULL
	OR "category" IS NULL
	OR "quantity" IS NULL
	OR "price_per_unit" IS NULL
	OR "cogs" IS NULL
	OR "total_sale" IS NULL;

-- Removing Null records :
DELETE FROM RETAIL_SALES_DATA
WHERE
	"transactions_id" IS NULL
	OR "sale_date" IS NULL
	OR "sale_time" IS NULL
	OR "customer_id" IS NULL
	OR "gender" IS NULL
	OR "age" IS NULL
	OR "category" IS NULL
	OR "quantity" IS NULL
	OR "price_per_unit" IS NULL
	OR "cogs" IS NULL
	OR "total_sale" IS NULL;

-- Data exploration
-- How many sales ? - 1987 (After cleaning)
SELECT
	COUNT(*)
FROM
	RETAIL_SALES_DATA;

-- How many distinct categories ? - 3 = Electronics, Clothing, Beauty
SELECT DISTINCT
	("category")
FROM
	RETAIL_SALES_DATA;

-- How many unique customers ? - 155
SELECT
	COUNT(DISTINCT ("customer_id"))
FROM
	RETAIL_SALES_DATA;

-- Analysis :
-- Q : Retrieve all transactions where the category is 'Clothing' 
-- and the quantity sold is no less than 4 in the month of Nov-2022
SELECT
	*
FROM
	RETAIL_SALES_DATA
WHERE
	"quantity" >= 4
	AND "category" = 'Clothing'
	AND TO_CHAR("sale_date", 'YYYY-MM') = '2022-11';

-- Q : Calculate the total sales (total_sale) for each category
SELECT
	"category",
	SUM("total_sale") AS "Net Sales",
	COUNT(*) AS "total_orders"
FROM
	RETAIL_SALES_DATA
GROUP BY
	1;

-- Q : Find the average age of customers who purchased items 
-- from the 'Beauty' category 
SELECT
	ROUND(AVG("age"), 2) AS "average_age"
FROM
	RETAIL_SALES_DATA
WHERE
	"category" = 'Beauty';

-- Q : Find all transactions where the total_sale is greater 
-- than 1000
SELECT
	*
FROM
	RETAIL_SALES_DATA
WHERE
	"total_sale" > 1000;

-- Q : Find the total number of transactions (transaction_id) 
-- made by each gender in each category
SELECT
	"category",
	"gender",
	COUNT("transactions_id") AS "total_transactions"
FROM
	RETAIL_SALES_DATA
GROUP BY
	"category",
	"gender"
ORDER BY
	1;

-- Q : Calculate the average sale for each month. Find out best 
-- selling month in each year
SELECT
	X."year",
	X."month",
	X."avg_sales"
FROM
	(
		SELECT
			EXTRACT(
				YEAR
				FROM
					"sale_date"
			) AS "year",
			TO_CHAR("sale_date", 'Mon') AS "month",
			AVG("total_sale") AS "avg_sales",
			RANK() OVER (
				PARTITION BY
					EXTRACT(
						YEAR
						FROM
							"sale_date"
					)
				ORDER BY
					AVG("total_sale") DESC
			) AS "rank"
		FROM
			RETAIL_SALES_DATA
		GROUP BY
			1,
			2
	) AS X
WHERE
	X."rank" = 1;

-- Q : Find the top 5 customers based on the highest total sales
SELECT
	"customer_id",
	SUM(TOTAL_SALE) AS "total_sales"
FROM
	RETAIL_SALES_DATA
GROUP BY
	1
ORDER BY
	2 DESC
LIMIT
	5;

-- Q : Find the number of unique customers who purchased items 
-- from each category
SELECT
	"category",
	COUNT(DISTINCT ("customer_id"))
FROM
	RETAIL_SALES_DATA
GROUP BY
	1;

-- Q : Create shifts and number of orders in each shift (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH
	HOURLY_SALES AS (
		SELECT
			*,
			CASE
				WHEN EXTRACT(
					HOUR
					FROM
						"sale_time"
				) < 12 THEN 'Morning'
				WHEN EXTRACT(
					HOUR
					FROM
						"sale_time"
				) BETWEEN 12 AND 17  THEN 'Afternoon'
				ELSE 'Evening'
			END AS "shift"
		FROM
			RETAIL_SALES_DATA
	)
SELECT
	"shift",
	COUNT("transactions_id") AS "orders_placed"
FROM
	HOURLY_SALES
GROUP BY
	"shift"
ORDER BY
	1;