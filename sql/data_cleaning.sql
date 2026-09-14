CREATE database shopsmart;
USE shopsmart;
CREATE TABLE ecommerce_raw(
	TransactionNo VARCHAR (20),
    Date VARCHAR (30),
    ProductNo VARCHAR (30),
    ProductName VARCHAR (255),
    Quantity INT,
    Price DECIMAL(10, 2),
    CustomerNo VARCHAR (20),
    Country VARCHAR (100)
    );
SELECT 
	COUNT(*) AS total_rows
FROM
	ecommerce_raw;
SELECT
	COUNT(*) AS total_transaction_no_is_null
FROM
	ecommerce_raw
WHERE
	TransactionNo IS NULL;
SELECT
	COUNT(*) AS total_transaction_no_is_null
FROM
	ecommerce_raw
WHERE
	TRIM(TransactionNo) = '';
SELECT
	COUNT(*) AS total_customer_no_is_null
FROM
	ecommerce_raw
WHERE
	CustomerNo IS NULL OR TRIM(CustomerNo) = '';
SELECT
	COUNT(*) AS total_price_is_null
FROM
	ecommerce_raw
WHERE
	Price IS NULL;
SELECT
	COUNT(*) AS total_country_is_null
FROM
	ecommerce_raw
WHERE
	Country IS NULL OR TRIM(Country) = '';
SELECT
	COUNT(*) AS total_product_no_is_null
FROM
	ecommerce_raw
WHERE
	ProductNo IS NULL;
SELECT
	COUNT(ProductNo) AS total_product_no_is_null
FROM
	ecommerce_raw;
SELECT
	COUNT(*) AS total_quantity_is_null
FROM
	ecommerce_raw
WHERE
	Quantity IS NULL;
SELECT
	COUNT(*) AS total_date_is_null
FROM
	ecommerce_raw
WHERE
	Date IS NULL;
SELECT
	COUNT(*) AS total_productname_is_null
FROM
	ecommerce_raw
WHERE
	ProductName IS NULL OR TRIM(ProductName) = '';
SELECT
	TransactionNo, COUNT(*) AS total_duplicate_count 
FROM
	ecommerce_raw
GROUP BY
	TransactionNo
HAVING COUNT(*) > 1;
SELECT SUM(DuplicateCount) AS TotalDuplicateRows
FROM (
    SELECT 
        COUNT(*) AS DuplicateCount
    FROM ecommerce_raw
    GROUP BY 
        TransactionNo, Date, ProductNo, ProductName, 
        Quantity, Price, CustomerNo, Country
    HAVING COUNT(*) > 1
) AS Duplicates;

SET SESSION max_execution_time = 60000;  -- 60 seconds
SET SESSION wait_timeout = 600;
SET SESSION interactive_timeout = 600;
WITH duplicate_count AS (SELECT 
    TransactionNo, 
    Date, 
    ProductNo, 
    ProductName, 
    Quantity, 
    Price, 
    CustomerNo, 
    Country,
    COUNT(*) AS DuplicateCount
FROM ecommerce_raw
GROUP BY 
    TransactionNo, 
    Date, 
    ProductNo, 
    ProductName, 
    Quantity, 
    Price, 
    CustomerNo, 
    Country
HAVING COUNT(*) > 1
ORDER BY DuplicateCount DESC) 
SELECT
	SUM(DuplicateCount) AS total_duplicate_row
FROM 
	duplicate_count;
SELECT COUNT(*) AS total_rows
FROM ecommerce_raw;
SELECT
    COUNT(*) AS negative_quantity_rows
FROM ecommerce_raw
WHERE Quantity < 0;
SELECT
    COUNT(*) AS zero_quantity_rows
FROM 
	ecommerce_raw
WHERE 
	Quantity = 0;
SELECT
    COUNT(*) AS negative_rows,
    COUNT(DISTINCT TransactionNo) AS negative_transactions,
    SUM(Quantity) AS total_negative_quantity,
    SUM(Quantity * Price) AS negative_value
FROM 
	ecommerce_raw
WHERE 
	Quantity < 0;
SELECT
    TransactionNo,
    COUNT(*) AS line_items,
    SUM(Quantity) AS total_quantity,
    SUM(Quantity * Price) AS transaction_value
FROM 
	ecommerce_raw
WHERE 
	Quantity < 0
GROUP BY 
	TransactionNo
ORDER BY 
	transaction_value ASC
LIMIT 20;
-------------------------
SELECT
    LEFT(TransactionNo, 1) AS transaction_prefix,
    COUNT(*) AS rows_number,
    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END) AS negative_rows
FROM 
	ecommerce_raw
GROUP BY 
	LEFT(TransactionNo, 1)
ORDER BY rows_number DESC;
----------------------------
SELECT
    COUNT(*) AS zero_or_negative_price_rows
FROM 
	ecommerce_raw
WHERE 
	Price <= 0;
-- Date values inspection
SELECT
    Date,
    COUNT(*) AS row_count
FROM 
	ecommerce_raw
GROUP BY 
	Date
ORDER 
	BY Date
LIMIT 10;
-- String Date Conversion
SELECT
    COUNT(*) AS invalid_dates
FROM 
	ecommerce_raw
WHERE 
	STR_TO_DATE(Date, '%m/%d/%Y') IS NULL;
-- Add Column with proper Date as Datatype
ALTER TABLE 
	ecommerce_raw
ADD COLUMN OrderDate DATE;
SET SQL_SAFE_UPDATES = 0;

UPDATE 
	ecommerce_raw
SET OrderDate = STR_TO_DATE(Date, '%m/%d/%Y');
SET SQL_SAFE_UPDATES = 1;
SELECT
    MIN(OrderDate) AS first_order_date,
    MAX(OrderDate) AS last_order_date
FROM 
	ecommerce_raw;

SET SQL_SAFE_UPDATES = 1;
-- Number of Customers
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CustomerNo) AS distinct_customers
FROM 
	ecommerce_raw;
SELECT
    COUNT(DISTINCT ProductNo) AS distinct_products,
    COUNT(DISTINCT ProductName) AS distinct_product_names
FROM 
	ecommerce_raw;
SELECT
    CustomerNo,
    COUNT(DISTINCT Country) AS country_count
FROM 
	ecommerce_raw
WHERE 
	CustomerNo IS NOT NULL
GROUP BY 
	CustomerNo
HAVING 
	COUNT(DISTINCT Country) > 1
ORDER BY 
	country_count DESC;
SELECT
	TransactionNo, ProductNo,
    COUNT(*) AS count_of_duplicate
FROM
	ecommerce_raw
GROUP BY
	TransactionNo, ProductNo
HAVING
	COUNT(*) > 1
ORDER BY
	count_of_duplicate DESC;
SELECT
    TransactionNo,
    Date,
    ProductNo,
    ProductName,
    Quantity,
    Price,
    CustomerNo,
    Country
FROM 
	ecommerce_raw
WHERE 
	TransactionNo = 555524
	AND ProductNo = 22698;
SELECT
    TransactionNo,
    ProductNo,
    COUNT(*) AS row_count,
    COUNT(DISTINCT Quantity) AS quantity_variations,
    COUNT(DISTINCT Price) AS price_variations,
    COUNT(DISTINCT CustomerNo) AS customer_variations,
    COUNT(DISTINCT Country) AS country_variations,
    COUNT(DISTINCT Date) AS date_variations
FROM 
	ecommerce_raw
GROUP BY
    TransactionNo,
    ProductNo
HAVING 
	COUNT(*) > 1
ORDER BY 
	row_count DESC;
SELECT
    TransactionNo,
    Date,
    ProductNo,
    ProductName,
    Quantity,
    Price,
    CustomerNo,
    Country,
    Quantity * Price AS LineValue
FROM 
	ecommerce_raw
WHERE 
	TransactionNo = '578289'
	AND ProductNo = '23395'
ORDER BY 
	Price, Quantity;
SELECT
    COUNT(*) AS exact_duplicate_groups,
    SUM(row_count - 1) AS excess_duplicate_rows
FROM (
    SELECT
        TransactionNo,
        ProductNo,
        COUNT(*) AS row_count,
        COUNT(DISTINCT Date) AS date_variations,
        COUNT(DISTINCT ProductName) AS product_variations,
        COUNT(DISTINCT Quantity) AS quantity_variations,
        COUNT(DISTINCT Price) AS price_variations,
        COUNT(DISTINCT CustomerNo) AS customer_variations,
        COUNT(DISTINCT Country) AS country_variations
    FROM ecommerce_raw
    GROUP BY
        TransactionNo,
        ProductNo
    HAVING
        COUNT(*) > 1
        AND COUNT(DISTINCT Date) = 1
        AND COUNT(DISTINCT ProductName) = 1
        AND COUNT(DISTINCT Quantity) = 1
        AND COUNT(DISTINCT Price) = 1
        AND COUNT(DISTINCT CustomerNo) = 1
        AND COUNT(DISTINCT Country) = 1
) AS duplicate_groups;
-- New Table created
CREATE TABLE ecommerce_clean AS
SELECT DISTINCT
    TransactionNo,
    Date,
    ProductNo,
    ProductName,
    Quantity,
    Price,
    CustomerNo,
    Country,
    OrderDate
FROM 
	ecommerce_raw;
SELECT 
	COUNT(*) AS clean_rows
FROM 
	ecommerce_clean;
SELECT COUNT(*) AS clean_rows
FROM ecommerce_clean;
-- highest duplicate removed
SELECT
    TransactionNo,
    ProductNo,
    COUNT(*) AS row_count
FROM 
	ecommerce_clean
WHERE 
	TransactionNo = '555524'
	AND ProductNo = '22698'
GROUP BY
    TransactionNo,
    ProductNo;
-- Data validation 
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT TransactionNo) AS transactions,
    COUNT(DISTINCT CustomerNo) AS customers,
    COUNT(DISTINCT ProductNo) AS products,
    MIN(OrderDate) AS first_date,
    MAX(OrderDate) AS last_date
FROM 
	ecommerce_clean;
ALTER TABLE ecommerce_clean
ADD COLUMN Revenue DECIMAL(12,2);
UPDATE ecommerce_clean
SET Revenue = Quantity * Price;
SET SQL_SAFE_UPDATES = 0;

UPDATE ecommerce_clean
SET Revenue = Quantity * Price;

SET SQL_SAFE_UPDATES = 1;
SELECT
    TransactionNo,
    ProductNo,
    Quantity,
    Price,
    Revenue
FROM 
	ecommerce_clean
LIMIT 10;
SHOW TABLES LIKE 'FactSales';
SELECT
    COUNT(*) AS fact_rows,
    COUNT(DISTINCT TransactionNo) AS transactions,
    COUNT(DISTINCT CustomerNo) AS customers,
    COUNT(DISTINCT ProductNo) AS products,
    MIN(OrderDate) AS first_date,
    MAX(OrderDate) AS last_date
FROM 
	FactSales;
SELECT DATABASE();
SHOW TABLES;
DESCRIBE ecommerce_clean;
CREATE TABLE DimCustomer AS
SELECT DISTINCT
    CustomerNo,
    Country
FROM 
	ecommerce_clean
WHERE 
	CustomerNo IS NOT NULL;
CREATE TABLE DimProduct AS
SELECT DISTINCT
    ProductNo,
    ProductName
FROM 
	ecommerce_clean
WHERE 
	ProductNo IS NOT NULL;
CREATE TABLE DimDate (
    Date DATE PRIMARY KEY,
    Year INT,
    MonthNumber INT,
    MonthName VARCHAR(20),
    YearMonth VARCHAR(10)
);
INSERT INTO DimDate (Date, Year, MonthNumber, MonthName, YearMonth)
WITH RECURSIVE DateSeries AS (
    SELECT '2019-05-17' AS Date
    
    UNION ALL
    
    SELECT DATE_ADD(Date, INTERVAL 1 DAY)
    FROM DateSeries
    WHERE Date < '2019-12-09'
)
SELECT
    Date,
    YEAR(Date),
    MONTH(Date),
    MONTHNAME(Date),
    DATE_FORMAT(Date, '%Y-%m')
FROM DateSeries;
SELECT
    COUNT(*) AS date_rows,
    MIN(Date) AS first_date,
    MAX(Date) AS last_date
FROM DimDate;
SELECT
    CASE
        WHEN TransactionNo LIKE 'C%' THEN 'Cancellation'
        ELSE 'Sale'
    END AS transaction_type,
    COUNT(*) AS line_items,
    COUNT(DISTINCT TransactionNo) AS transactions,
    SUM(Quantity) AS total_quantity,
    SUM(Revenue) AS total_revenue
FROM ecommerce_clean
