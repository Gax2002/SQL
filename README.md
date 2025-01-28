# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Database**: `project_01`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. 

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `project_01`.
- **Table Creation**: A table named `retail_sales_data` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE project_01;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
-- How many sales ? - 1987 (post cleaning)
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
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**
```sql
SELECT
	*
FROM
	RETAIL_SALES_DATA
WHERE
	"quantity" >= 4
	AND "category" = 'Clothing'
	AND TO_CHAR("sale_date", 'YYYY-MM') = '2022-11';
```

2. **Calculate the total sales (total_sale) for each category**
```sql
SELECT
	"category",
	SUM("total_sale") AS "Net Sales",
	COUNT(*) AS "total_orders"
FROM
	RETAIL_SALES_DATA
GROUP BY
	1;
```

3. **Find the average age of customers who purchased items from the 'Beauty' category**
```sql
SELECT
	ROUND(AVG("age"), 2) AS "average_age"
FROM
	RETAIL_SALES_DATA
WHERE
	"category" = 'Beauty';
```

4. **Find all transactions where the total_sale is greater than 1000**
```sql
SELECT
	*
FROM
	RETAIL_SALES_DATA
WHERE
	"total_sale" > 1000;
```

5. **Find the total number of transactions (transaction_id) made by each gender in each category**
```sql
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
```

6. **Calculate the average sale for each month. Find out best selling month in each year**
```sql
SELECT
	X."year",
	X."month",
	X."avg_sales"
FROM
	(
		SELECT
			EXTRACT(YEAR FROM "sale_date") AS "year",
			TO_CHAR("sale_date", 'Mon') AS "month",
			AVG("total_sale") AS "avg_sales",
			RANK() OVER (
				PARTITION BY
					EXTRACT(YEAR FROM "sale_date")
				ORDER BY
					AVG("total_sale") DESC
			) AS "rank"
		FROM
			RETAIL_SALES_DATA
		GROUP BY
			1,2
	) AS X
WHERE
	X."rank" = 1;
```

7. **Find the top 5 customers based on the highest total sales**
```sql
SELECT
	"customer_id",
	SUM(TOTAL_SALE) AS "total_sales"
FROM
	RETAIL_SALES_DATA
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```
8. **Find the number of unique customers who purchased items from each category**
```sql
SELECT
	"category",
	COUNT(DISTINCT ("customer_id"))
FROM
	RETAIL_SALES_DATA 
GROUP BY 1;
```
9. **Create shifts and number of orders in each shift(Example Morning <12, Afternoon Between 12 & 17, Evening >17)**
```sql
WITH
	HOURLY_SALES AS (
		SELECT	*, CASE
				WHEN EXTRACT(HOUR FROM "sale_time") < 12 THEN 'Morning'
				WHEN EXTRACT(HOUR FROM "sale_time") BETWEEN 12 AND 17  THEN 'Afternoon'
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
GROUP BY"shift"
ORDER BY 1;
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive solution for data analysis, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.
