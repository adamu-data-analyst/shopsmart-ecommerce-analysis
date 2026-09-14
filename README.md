# ShopSmart E-commerce Revenue & Customer Retention Analysis

## Business Overview

This project analyzes revenue performance, transaction cancellations, customer purchasing behavior, and customer retention for an e-commerce business.

The analysis was designed to answer a core business question:

> **What is driving the decline in revenue, and what actions could help reverse the negative revenue trajectory?**

Using MySQL and Power BI, I transformed raw transaction data into an analytical dataset and investigated revenue trends, cancellations, customer purchasing behavior, and November-to-December retention.

---

## Business Questions

The analysis focuses on five key questions:

1. How is revenue performing over time?
2. How much revenue is being lost through cancellations?
3. What is driving the November-to-December revenue decline?
4. Are fewer customers purchasing, or are existing customers spending less?
5. How well are November customers being retained in December?

---

## Key Findings

### 1. Revenue declined sharply in December

Net revenue declined by **74.18% from November to December 2019**.

The decline was accompanied by a **70.32% reduction in sales transaction volume** and a substantial decline in the number of purchasing customers.

This indicates that the revenue decline was primarily associated with reduced purchasing activity and customer volume.

### 2. Customer retention was weak

Only **22.26% of November purchasing customers returned to purchase in December**.

This suggests that customer retention was a significant contributor to the December revenue decline.

### 3. Returning customers also purchased less frequently

Among customers who returned in December, transactions per customer declined from approximately **1.58 to 1.25**.

Therefore, the decline was not only caused by fewer customers returning. Even returning customers made fewer purchases.

### 4. Average order value moved in the opposite direction

Average revenue per transaction increased from approximately:

- **£2,843.62 in November**
- **£3,074.75 in December**

This is an important business signal.

Although overall revenue declined sharply, customers were generating slightly more revenue per transaction. Therefore, the main issue was **purchasing volume and customer engagement rather than declining transaction value**.

### 5. Cancellations require attention

The analysis identified significant cancellation activity, particularly within the UK.

This suggests that cancellation behavior should be investigated further to determine whether operational issues, product availability, pricing, delivery, or other factors are contributing to lost revenue.

---

## Business Recommendations

Based on the analysis, I recommend:

### 1. Re-engage November customers

Target customers who purchased in November but did not return in December with personalized, time-limited offers.

Where possible, promotions should be based on products customers previously purchased or showed repeated interest in.

### 2. Investigate UK cancellations

The high level of UK cancellations warrants deeper investigation.

Management should examine whether cancellations are associated with:

- Product availability
- Pricing
- Delivery issues
- Order processing
- Specific products or customer segments

### 3. Use customer purchasing behavior to design promotions

Rather than applying broad discounts, identify customers with higher purchase frequency or repeated product behavior and use targeted promotions to encourage additional purchases.

### 4. Monitor customer frequency alongside revenue

Revenue and average order value alone can hide customer engagement problems.

Management should monitor:

- Purchasing customers
- Transactions per customer
- Customer retention
- Average order value
- Cancellation rate

together to identify changes in revenue performance earlier.

---

## Data & Methodology

The project started with approximately **345,000 raw transaction records**.

The data preparation process included:

- Null-value checks
- Duplicate investigation
- Transaction validation
- Quantity and price validation
- Date conversion
- Cancellation analysis
- Revenue calculation
- Customer and product dimension creation
- Data deduplication
- Analytical data modeling

The cleaned dataset was then structured for analysis using a dimensional model containing:

- `FactSales`
- `DimCustomer`
- `DimProduct`
- `DimDate`

---

## Tools Used

- **MySQL** — data cleaning, transformation and analytical SQL
- **Power BI** — dashboard development and business analysis
- **DAX** — analytical measures and KPIs
- **Power Query** — data transformation
- **Excel** — supporting data inspection

---

## Project Structure

```text
shopsmart-ecommerce-analysis/
│
├── data/
│   └── ecommerce_data.csv
│
├── images/
│   └── shop-smart-dashboard.png
│
├── powerbi/
│   └── shop-smart-project.pbix
│
├── sql/
│   ├── data_cleaning.sql
│   ├── revenue_analysis.sql
│   └── customer_retention_analysis.sql
│
└── README.md
