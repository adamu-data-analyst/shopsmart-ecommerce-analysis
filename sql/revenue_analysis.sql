GROUP BY
    CASE
        WHEN TransactionNo LIKE 'C%' THEN 'Cancellation'
        ELSE 'Sale'
    END;
-- cancellation rate
SELECT
    COUNT(DISTINCT CASE
        WHEN TransactionNo LIKE 'C%' THEN TransactionNo
    END) AS cancellation_transactions,
    
    COUNT(DISTINCT CASE
        WHEN TransactionNo NOT LIKE 'C%' THEN TransactionNo
    END) AS sales_transactions,
    
    ROUND(
        COUNT(DISTINCT CASE
            WHEN TransactionNo LIKE 'C%' THEN TransactionNo
        END)
        /
        COUNT(DISTINCT CASE
            WHEN TransactionNo NOT LIKE 'C%' THEN TransactionNo
        END)
        * 100,
        2
    ) AS cancellation_rate
FROM ecommerce_clean;
SELECT
    Country,
    COUNT(DISTINCT TransactionNo) AS cancellation_transactions,
    SUM(Quantity) AS cancelled_quantity,
    ROUND(SUM(Revenue), 2) AS cancellation_revenue
FROM ecommerce_clean
WHERE TransactionNo LIKE 'C%'
GROUP BY Country
ORDER BY cancellation_revenue ASC
LIMIT 10;
-- top cancelled product
SELECT
    ProductNo,
    MAX(ProductName) AS ProductName,
    SUM(Quantity) AS cancelled_quantity,
    ROUND(SUM(Revenue), 2) AS cancellation_revenue
FROM ecommerce_clean
WHERE TransactionNo LIKE 'C%'
  AND Country = 'United Kingdom'
GROUP BY ProductNo
ORDER BY cancellation_revenue ASC
LIMIT 10;
-- biggest cancellation order
SELECT
    TransactionNo,
    Date,
    ProductNo,
    ProductName,
    Quantity,
    Price,
    CustomerNo,
    Country,
    Revenue
FROM ecommerce_clean
WHERE TransactionNo = 'C581484'
  AND ProductNo = '23843';
-- excluding biggest cancellation
SELECT
    ROUND(SUM(Revenue), 2) AS cancellation_revenue_including_anomaly,
    ROUND(
        SUM(
            CASE
                WHEN TransactionNo <> 'C581484'
                THEN Revenue
                ELSE 0
            END
        ),
        2
    ) AS cancellation_revenue_excluding_anomaly
FROM ecommerce_clean
WHERE TransactionNo LIKE 'C%';
SELECT
    COUNT(DISTINCT CASE
        WHEN TransactionNo LIKE 'C%'
             AND TransactionNo <> 'C581484'
        THEN TransactionNo
    END) AS cancellation_transactions_excl_anomaly,

    COUNT(DISTINCT CASE
        WHEN TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS sales_transactions,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN TransactionNo LIKE 'C%'
                 AND TransactionNo <> 'C581484'
            THEN TransactionNo
        END)
        /
        COUNT(DISTINCT CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN TransactionNo
        END)
        * 100,
        2
    ) AS cancellation_ratio_excl_anomaly
FROM ecommerce_clean;
SELECT
    ROUND(SUM(CASE
        WHEN TransactionNo NOT LIKE 'C%'
        THEN Revenue
        ELSE 0
    END), 2) AS gross_revenue,

    ROUND(SUM(CASE
        WHEN TransactionNo LIKE 'C%'
        THEN Revenue
        ELSE 0
    END), 2) AS cancellation_impact,

    ROUND(SUM(Revenue), 2) AS net_revenue,

    ROUND(
        SUM(Revenue)
        /
        NULLIF(COUNT(DISTINCT CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN TransactionNo
        END), 0),
        2
    ) AS net_revenue_per_sale_transaction
FROM ecommerce_clean;
-- revenue trend
SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,

    ROUND(SUM(CASE
        WHEN TransactionNo NOT LIKE 'C%'
        THEN Revenue
        ELSE 0
    END), 2) AS gross_revenue,

    ROUND(SUM(CASE
        WHEN TransactionNo LIKE 'C%'
        THEN Revenue
        ELSE 0
    END), 2) AS cancellation_impact,

    ROUND(SUM(Revenue), 2) AS net_revenue

FROM ecommerce_clean
GROUP BY
    DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY
    YearMonth;
SELECT
    ROUND(
        (SUM(CASE WHEN OrderDate >= '2019-12-01'
                       AND TransactionNo NOT LIKE 'C%'
                  THEN Revenue ELSE 0 END)
        -
         SUM(CASE WHEN OrderDate >= '2019-11-01'
                       AND OrderDate < '2019-12-01'
                       AND TransactionNo NOT LIKE 'C%'
                  THEN Revenue ELSE 0 END))
        /
        SUM(CASE WHEN OrderDate >= '2019-11-01'
                      AND OrderDate < '2019-12-01'
                      AND TransactionNo NOT LIKE 'C%'
                 THEN Revenue ELSE 0 END)
        * 100, 2
    ) AS gross_revenue_change_pct,

    ROUND(
        (SUM(CASE WHEN OrderDate >= '2019-12-01'
                       AND TransactionNo LIKE 'C%'
                  THEN Revenue ELSE 0 END)
        -
         SUM(CASE WHEN OrderDate >= '2019-11-01'
                       AND OrderDate < '2019-12-01'
                       AND TransactionNo LIKE 'C%'
                  THEN Revenue ELSE 0 END))
        /
        ABS(SUM(CASE WHEN OrderDate >= '2019-11-01'
                          AND OrderDate < '2019-12-01'
                          AND TransactionNo LIKE 'C%'
                     THEN Revenue ELSE 0 END))
        * 100, 2
    ) AS cancellation_change_pct,

    ROUND(
        (SUM(CASE WHEN OrderDate >= '2019-12-01'
                  THEN Revenue ELSE 0 END)
        -
         SUM(CASE WHEN OrderDate >= '2019-11-01'
                       AND OrderDate < '2019-12-01'
                  THEN Revenue ELSE 0 END))
        /
        SUM(CASE WHEN OrderDate >= '2019-11-01'
                      AND OrderDate < '2019-12-01'
                 THEN Revenue ELSE 0 END)
        * 100, 2
    ) AS net_revenue_change_pct
FROM ecommerce_clean;
SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,

    COUNT(DISTINCT CASE
        WHEN TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS sales_transactions,

    ROUND(
        SUM(CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN Revenue
            ELSE 0
        END)
        /
        COUNT(DISTINCT CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN TransactionNo
        END),
        2
    ) AS avg_revenue_per_transaction,

    ROUND(
        SUM(CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN Revenue
            ELSE 0
        END),
        2
    ) AS gross_revenue

FROM ecommerce_clean
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY YearMonth;
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,

        COUNT(DISTINCT CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN TransactionNo
        END) AS sales_transactions,

        SUM(CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN Revenue
            ELSE 0
        END) /
        COUNT(DISTINCT CASE
            WHEN TransactionNo NOT LIKE 'C%'
            THEN TransactionNo
        END) AS avg_revenue_per_transaction

    FROM ecommerce_clean
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
)

SELECT
    ROUND(
        (MAX(CASE WHEN YearMonth = '2019-12'
                  THEN sales_transactions END)
        -
         MAX(CASE WHEN YearMonth = '2019-11'
                  THEN sales_transactions END))
        /
        MAX(CASE WHEN YearMonth = '2019-11'
                  THEN sales_transactions END)
        * 100,
        2
    ) AS transaction_volume_change_pct,

    ROUND(
        (MAX(CASE WHEN YearMonth = '2019-12'
                  THEN avg_revenue_per_transaction END)
        -
         MAX(CASE WHEN YearMonth = '2019-11'
                  THEN avg_revenue_per_transaction END))
        /
        MAX(CASE WHEN YearMonth = '2019-11'
                  THEN avg_revenue_per_transaction END)
        * 100,
        2
    ) AS avg_transaction_value_change_pct

FROM monthly_sales;
-- decline by country
SELECT
    Country,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-11'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS nov_sales_transactions,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-12'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS dec_sales_transactions,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-12'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END)
    -
    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-11'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS transaction_change

FROM ecommerce_clean
GROUP BY Country
ORDER BY transaction_change;
SELECT
    ProductNo,
    ProductName,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-11'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS nov_sales_transactions,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-12'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS dec_sales_transactions,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-12'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END)
    -
    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(OrderDate, '%Y-%m') = '2019-11'
         AND TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS transaction_change

FROM ecommerce_clean

WHERE Country = 'United Kingdom'

GROUP BY ProductNo, ProductName

HAVING nov_sales_transactions > 0
    OR dec_sales_transactions > 0

ORDER BY transaction_change
LIMIT 20;
SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,

    COUNT(DISTINCT CustomerNo) AS unique_purchasing_customers,

    COUNT(DISTINCT CASE
        WHEN TransactionNo NOT LIKE 'C%'
        THEN TransactionNo
    END) AS sales_transactions

FROM ecommerce_clean

WHERE DATE_FORMAT(OrderDate, '%Y-%m') IN ('2019-11', '2019-12')
  AND TransactionNo NOT LIKE 'C%'

GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')

ORDER BY YearMonth;
SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS YearMonth,

    COUNT(DISTINCT CustomerNo) AS unique_purchasing_customers,

    COUNT(DISTINCT TransactionNo) AS sales_transactions,

    ROUND(
        COUNT(DISTINCT TransactionNo)
        / COUNT(DISTINCT CustomerNo),
        2
    ) AS transactions_per_customer

FROM ecommerce_clean

WHERE TransactionNo NOT LIKE 'C%'
  AND DATE_FORMAT(OrderDate, '%Y-%m') IN ('2019-11', '2019-12')

GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')

ORDER BY YearMonth;
WITH november_customers AS (
    SELECT DISTINCT CustomerNo
    FROM ecommerce_clean
    WHERE TransactionNo NOT LIKE 'C%'
      AND DATE_FORMAT(OrderDate, '%Y-%m') = '2019-11'
),

december_customers AS (
    SELECT DISTINCT CustomerNo
    FROM ecommerce_clean
