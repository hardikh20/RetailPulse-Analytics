CREATE DATABASE ecommerce_analysis;

USE ecommerce_analysis;

CREATE TABLE retail_transactions (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10,2),
    CustomerID INT,
    Country VARCHAR(100),
    Revenue DECIMAL(10,2)
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online retail clean.csv'
INTO TABLE retail_transactions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(InvoiceNo, StockCode, Description, Quantity, @InvoiceDate, UnitPrice, CustomerID, Country, Revenue)
SET InvoiceDate = STR_TO_DATE(@InvoiceDate,'%d-%m-%Y %H:%i');

SELECT COUNT(*) FROM retail_transactions;

SELECT * FROM retail_transactions
LIMIT 10;

-- Confirm no NULL CustomerIDs remain
SELECT COUNT(*) AS Null_Customers 
FROM retail_transactions 
WHERE CustomerID IS NULL;

-- Confirm no negative quantities remain
SELECT COUNT(*) AS Negative_Quantities 
FROM retail_transactions 
WHERE Quantity <= 0;

-- Revenue Analysis 
-- 1.Total Revenue Generated
SELECT SUM(Revenue) AS Total_Revenue
FROM retail_transactions;

-- 2.Monthly Revenue Trend
SELECT 
YEAR(InvoiceDate) AS Year,
MONTH(InvoiceDate) AS Month,
SUM(Revenue) AS Monthly_Revenue
FROM retail_transactions
GROUP BY Year, Month
ORDER BY Year, Month;

-- 3.Average Order Value
SELECT 
AVG(Revenue) AS Average_Order_Value
FROM retail_transactions;

-- Product Analysis
-- 4.Top 10 Best-Selling Products (by quantity)
SELECT 
Description,
SUM(Quantity) AS Total_Quantity_Sold
FROM retail_transactions
GROUP BY Description
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;

-- 5.Top 10 Products by Revenue
SELECT 
Description,
SUM(Revenue) AS Total_Revenue
FROM retail_transactions
GROUP BY Description
ORDER BY Total_Revenue DESC
LIMIT 10;

-- 6.Products with Highest Average Price
SELECT 
Description,
AVG(UnitPrice) AS Average_Price
FROM retail_transactions
GROUP BY Description
ORDER BY Average_Price DESC
LIMIT 10;

-- Customer Analysis
-- 7.Top 10 Customers by Revenue
SELECT 
CustomerID,
SUM(Revenue) AS Total_Spent
FROM retail_transactions
GROUP BY CustomerID
ORDER BY Total_Spent DESC
LIMIT 10;

-- 8.Average Spending per Customer
SELECT 
AVG(Customer_Revenue) AS Avg_Customer_Spending
FROM (
SELECT 
CustomerID,
SUM(Revenue) AS Customer_Revenue
FROM retail_transactions
GROUP BY CustomerID
) AS customer_totals;

-- Geographic Analysis
-- 9. Revenue by Country
SELECT 
Country,
SUM(Revenue) AS Total_Revenue
FROM retail_transactions
GROUP BY Country
ORDER BY Total_Revenue DESC;

-- 10.Top Countries by Number of Orders
SELECT 
Country,
COUNT(DISTINCT InvoiceNo) AS Total_Orders
FROM retail_transactions
GROUP BY Country
ORDER BY Total_Orders DESC;

-- Time-Based Customer Behavior
-- 11.Peak Shopping Hours
SELECT 
HOUR(InvoiceDate) AS Hour_of_Day,
COUNT(*) AS Total_Orders
FROM retail_transactions
GROUP BY Hour_of_Day
ORDER BY Total_Orders DESC;

-- 12.Best Sales Days
SELECT 
DAYNAME(InvoiceDate) AS Day_of_Week,
SUM(Revenue) AS Total_Revenue
FROM retail_transactions
GROUP BY Day_of_Week
ORDER BY Total_Revenue DESC;

-- Customer Lifetime Value (CLV)
-- Which customers generate the most long-term revenue?
SELECT 
CustomerID,
COUNT(DISTINCT InvoiceNo) AS Total_Orders,
SUM(Revenue) AS Total_Revenue,
AVG(Revenue) AS Avg_Order_Value
FROM retail_transactions
GROUP BY CustomerID
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Product Market Basket Insight (Product Pair Analysis)
-- Which products are frequently purchased together?
SELECT 
t1.Description AS Product_A,
t2.Description AS Product_B,
COUNT(*) AS Times_Bought_Together
FROM retail_transactions t1
JOIN retail_transactions t2
ON t1.InvoiceNo = t2.InvoiceNo
AND t1.StockCode < t2.StockCode
GROUP BY Product_A, Product_B
ORDER BY Times_Bought_Together DESC
LIMIT 10;

-- Customer Segmentation (High / Medium / Low Spenders)
-- How can customers be categorized based on spending?
SELECT 
CustomerID,
SUM(Revenue) AS Total_Spending,
CASE
WHEN SUM(Revenue) > 10000 THEN 'High Value Customer'
WHEN SUM(Revenue) BETWEEN 5000 AND 10000 THEN 'Medium Value Customer'
ELSE 'Low Value Customer'
END AS Customer_Segment
FROM retail_transactions
GROUP BY CustomerID
ORDER BY Total_Spending DESC;
