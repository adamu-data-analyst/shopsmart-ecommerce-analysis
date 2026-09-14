    WHERE TransactionNo NOT LIKE 'C%'
      AND DATE_FORMAT(OrderDate, '%Y-%m') = '2019-12'
)

SELECT
    COUNT(*) AS november_customers,

    COUNT(d.CustomerNo) AS retained_customers,

    COUNT(*) - COUNT(d.CustomerNo) AS customers_not_returned,

    ROUND(
        COUNT(d.CustomerNo) / COUNT(*) * 100,
        2
    ) AS retention_rate_pct,

    ROUND(
        (COUNT(*) - COUNT(d.CustomerNo)) / COUNT(*) * 100,
        2
    ) AS non_return_rate_pct

FROM november_customers n
LEFT JOIN december_customers d
    ON n.CustomerNo = d.CustomerNo;
-- November, december customers
WITH november_customers AS (
    SELECT DISTINCT CustomerNo
    FROM ecommerce_clean
    WHERE TransactionNo NOT LIKE 'C%'
      AND DATE_FORMAT(OrderDate, '%Y-%m') = '2019-11'
),

december_customers AS (
    SELECT DISTINCT CustomerNo
    FROM ecommerce_clean
    WHERE TransactionNo NOT LIKE 'C%'
      AND DATE_FORMAT(OrderDate, '%Y-%m') = '2019-12'
)

SELECT
    COUNT(*) AS december_customers,

    SUM(
        CASE
            WHEN n.CustomerNo IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS retained_customers,

    SUM(
        CASE
            WHEN n.CustomerNo IS NULL THEN 1
            ELSE 0
        END
    ) AS non_november_customers,

    ROUND(
        SUM(
            CASE
                WHEN n.CustomerNo IS NOT NULL THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS retained_customer_pct,

    ROUND(
        SUM(
            CASE
                WHEN n.CustomerNo IS NULL THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS non_november_customer_pct

FROM december_customers d
LEFT JOIN november_customers n
    ON d.CustomerNo = n.CustomerNo;
-- Retained customers purchases
WITH november_customers AS (
    SELECT DISTINCT CustomerNo
    FROM ecommerce_clean
    WHERE TransactionNo NOT LIKE 'C%'
      AND DATE_FORMAT(OrderDate, '%Y-%m') = '2019-11'
),

december_customers AS (
    SELECT DISTINCT CustomerNo
    FROM ecommerce_clean
    WHERE TransactionNo NOT LIKE 'C%'
      AND DATE_FORMAT(OrderDate, '%Y-%m') = '2019-12'
),

retained_customers AS (
    SELECT n.CustomerNo
    FROM november_customers n
    INNER JOIN december_customers d
        ON n.CustomerNo = d.CustomerNo
)

SELECT
    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(e.OrderDate, '%Y-%m') = '2019-11'
        THEN e.CustomerNo
    END) AS retained_customers,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(e.OrderDate, '%Y-%m') = '2019-11'
        THEN e.TransactionNo
    END) AS nov_transactions,

    COUNT(DISTINCT CASE
        WHEN DATE_FORMAT(e.OrderDate, '%Y-%m') = '2019-12'
        THEN e.TransactionNo
    END) AS dec_transactions,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN DATE_FORMAT(e.OrderDate, '%Y-%m') = '2019-11'
            THEN e.TransactionNo
        END)
        /
        COUNT(DISTINCT CASE
            WHEN DATE_FORMAT(e.OrderDate, '%Y-%m') = '2019-11'
            THEN e.CustomerNo
        END),
        2
    ) AS nov_transactions_per_customer,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN DATE_FORMAT(e.OrderDate, '%Y-%m') = '2019-12'
            THEN e.TransactionNo
        END)
        /
        COUNT(DISTINCT CASE
            WHEN DATE_FORMAT(e.OrderDate, '%Y-%m') = '2019-12'
            THEN e.CustomerNo
        END),
        2
    ) AS dec_transactions_per_customer

FROM ecommerce_clean e
INNER JOIN retained_customers r
    ON e.CustomerNo = r.CustomerNo

WHERE e.TransactionNo NOT LIKE 'C%'
  AND DATE_FORMAT(e.OrderDate, '%Y-%m') IN ('2019-11', '2019-12');
-- other countries retention rate
WITH november_customers AS (
    SELECT DISTINCT
        Country,
        CustomerNo
    FROM ecommerce_clean
    WHERE OrderDate >= '2019-11-01'
      AND OrderDate < '2019-12-01'
      AND TransactionNo NOT LIKE 'C%'
),
december_customers AS (
    SELECT DISTINCT
        CustomerNo
    FROM ecommerce_clean
    WHERE OrderDate >= '2019-12-01'
      AND OrderDate < '2020-01-01'
      AND TransactionNo NOT LIKE 'C%'
)
SELECT
    n.Country,
    COUNT(DISTINCT n.CustomerNo) AS november_customers,
    COUNT(DISTINCT d.CustomerNo) AS retained_customers,
    ROUND(
        COUNT(DISTINCT d.CustomerNo) * 100.0
        / COUNT(DISTINCT n.CustomerNo),
        2
    ) AS retention_rate_pct
FROM november_customers n
LEFT JOIN december_customers d
    ON n.CustomerNo = d.CustomerNo
GROUP BY
    n.Country
ORDER BY
    november_customers DESC;
SELECT
    Country,
    SUM(CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN 1 ELSE 0
    END) AS november_transactions,

    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN CustomerNo
    END) AS november_customers,

    ROUND(
        SUM(CASE
            WHEN OrderDate >= '2019-11-01'
             AND OrderDate < '2019-12-01'
            THEN 1 ELSE 0
        END) * 1.0
        / COUNT(DISTINCT CASE
            WHEN OrderDate >= '2019-11-01'
             AND OrderDate < '2019-12-01'
            THEN CustomerNo
        END),
        2
    ) AS november_transactions_per_customer,

    SUM(CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN 1 ELSE 0
    END) AS december_transactions,

    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN CustomerNo
    END) AS december_customers,

    ROUND(
        SUM(CASE
            WHEN OrderDate >= '2019-12-01'
             AND OrderDate < '2020-01-01'
            THEN 1 ELSE 0
        END) * 1.0
        / COUNT(DISTINCT CASE
            WHEN OrderDate >= '2019-12-01'
             AND OrderDate < '2020-01-01'
            THEN CustomerNo
        END),
        2
    ) AS december_transactions_per_customer

FROM ecommerce_clean
WHERE TransactionNo NOT LIKE 'C%'
  AND OrderDate >= '2019-11-01'
  AND OrderDate < '2020-01-01'
GROUP BY Country
ORDER BY november_transactions DESC;
SELECT
    ProductNo,
    ProductName,

    SUM(CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN 1 ELSE 0
    END) AS november_transactions,

    SUM(CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN 1 ELSE 0
    END) AS december_transactions,

    SUM(CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN 1 ELSE 0
    END)
    -
    SUM(CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN 1 ELSE 0
    END) AS transaction_decline

FROM ecommerce_clean
WHERE Country = 'United Kingdom'
  AND TransactionNo NOT LIKE 'C%'
  AND OrderDate >= '2019-11-01'
  AND OrderDate < '2020-01-01'

GROUP BY
    ProductNo,
    ProductName

HAVING
    SUM(CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN 1 ELSE 0
    END)
    -
    SUM(CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN 1 ELSE 0
    END) > 0

ORDER BY
    transaction_decline DESC
LIMIT 20;
SELECT
    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN TransactionNo
    END) AS november_christmas_transactions,

    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN TransactionNo
    END) AS december_christmas_transactions,

    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN TransactionNo
    END)
    -
    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN TransactionNo
    END) AS transaction_decline

FROM ecommerce_clean
WHERE Country = 'United Kingdom'
  AND TransactionNo NOT LIKE 'C%'
  AND ProductName LIKE '%CHRISTMAS%'
  AND OrderDate >= '2019-11-01'
  AND OrderDate < '2020-01-01';
  SELECT
    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN TransactionNo
    END) AS november_non_christmas_transactions,

    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN TransactionNo
    END) AS december_non_christmas_transactions,

    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN TransactionNo
    END)
    -
    COUNT(DISTINCT CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN TransactionNo
    END) AS transaction_decline

FROM ecommerce_clean
WHERE Country = 'United Kingdom'
  AND TransactionNo NOT LIKE 'C%'
  AND ProductName NOT LIKE '%CHRISTMAS%'
  AND OrderDate >= '2019-11-01'
  AND OrderDate < '2020-01-01';
  WITH transaction_type AS (
    SELECT
        TransactionNo,
        OrderDate,
        MAX(
            CASE
                WHEN ProductName LIKE '%CHRISTMAS%'
                THEN 1
                ELSE 0
            END
        ) AS has_christmas,
        MAX(
            CASE
                WHEN ProductName NOT LIKE '%CHRISTMAS%'
                THEN 1
                ELSE 0
            END
        ) AS has_non_christmas
    FROM ecommerce_clean
    WHERE Country = 'United Kingdom'
      AND TransactionNo NOT LIKE 'C%'
      AND OrderDate >= '2019-11-01'
      AND OrderDate < '2020-01-01'
    GROUP BY
        TransactionNo,
        OrderDate
)
SELECT
    CASE
        WHEN has_christmas = 1 AND has_non_christmas = 1
            THEN 'Mixed'
        WHEN has_christmas = 1
            THEN 'Christmas Only'
        ELSE 'Non-Christmas Only'
    END AS transaction_type,

    COUNT(CASE
        WHEN OrderDate >= '2019-11-01'
         AND OrderDate < '2019-12-01'
        THEN 1
    END) AS november_transactions,

    COUNT(CASE
        WHEN OrderDate >= '2019-12-01'
         AND OrderDate < '2020-01-01'
        THEN 1
    END) AS december_transactions

FROM transaction_type
GROUP BY
    CASE
        WHEN has_christmas = 1 AND has_non_christmas = 1
            THEN 'Mixed'
        WHEN has_christmas = 1
            THEN 'Christmas Only'
        ELSE 'Non-Christmas Only'
    END
ORDER BY
    november_transactions DESC;