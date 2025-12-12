-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- Window Functions Practice
-- ----------------------------------------------

USE adv;

-- 1. Calculate Running Total of Sales:
-- Use the `SUM()` window function to calculate a running total of sales for
-- each year.
SELECT
    OrderDate,
    SalesOrderID,
    TotalDue,
    YEAR(OrderDate) AS SalesYear,
    SUM(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate)
        ORDER BY OrderDate ASC, SalesOrderID ASC
    ) AS RunningTotal
FROM sales_salesorderheader
ORDER BY SalesYear ASC, OrderDate ASC;

-- 2. Rank Sales by Year:
-- Use the `RANK()` window function to rank sales by the total amount each year
-- within each product category.
WITH CategoryYearlySales AS (
    SELECT
        c.Name AS CategoryName,
        YEAR(h.OrderDate) AS SalesYear,
        SUM(d.LineTotal) AS TotalSales
    FROM sales_salesorderheader AS h
    INNER JOIN sales_salesorderdetail AS d
        ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN production_product AS p
        ON d.ProductID = p.ProductID
    INNER JOIN production_productsubcategory AS sc
        ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    INNER JOIN production_productcategory AS c
        ON sc.ProductCategoryID = c.ProductCategoryID
    GROUP BY c.Name, YEAR(h.OrderDate)
)

SELECT
    CategoryName,
    SalesYear,
    TotalSales,
    RANK() OVER (
        PARTITION BY CategoryName
        ORDER BY TotalSales DESC
    ) AS RankBySales
FROM CategoryYearlySales
ORDER BY CategoryName ASC, RankBySales ASC;

-- 3. Find the Top 3 Products by Sales in Each Category:
-- Use the `ROW_NUMBER()` window function to identify the top 3 products by
-- sales amount within each category.
WITH ProductSales AS (
    SELECT
        c.Name AS CategoryName,
        p.Name AS ProductName,
        SUM(d.LineTotal) AS TotalSales
    FROM sales_salesorderdetail AS d
    INNER JOIN production_product AS p
        ON d.ProductID = p.ProductID
    INNER JOIN production_productsubcategory AS sc
        ON p.ProductSubcategoryID = sc.ProductSubcategoryID
    INNER JOIN production_productcategory AS c
        ON sc.ProductCategoryID = c.ProductCategoryID
    GROUP BY c.Name, p.Name
),

RankedProducts AS (
    SELECT
        CategoryName,
        ProductName,
        TotalSales,
        ROW_NUMBER() OVER (
            PARTITION BY CategoryName
            ORDER BY TotalSales DESC
        ) AS rn
    FROM ProductSales
)

SELECT
    CategoryName,
    ProductName,
    TotalSales
FROM RankedProducts
WHERE rn <= 3
ORDER BY CategoryName ASC, TotalSales DESC;

-- 4. Calculate the Moving Average of Monthly Sales:
-- Use the `AVG()` window function to calculate a 3-month moving average of
-- sales.
WITH MonthlySales AS (
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalDue) AS TotalMonthlySales
    FROM sales_salesorderheader
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
)

SELECT
    SalesYear,
    SalesMonth,
    TotalMonthlySales,
    AVG(TotalMonthlySales) OVER (
        ORDER BY SalesYear ASC, SalesMonth ASC
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS MovingAvg3Months
FROM MonthlySales
ORDER BY SalesYear ASC, SalesMonth ASC;

-- 5. Compare Individual Sales to Average Sales:
-- Use the `AVG()` window function to compare individual sales amounts to the
-- average sales of the respective year.
SELECT
    SalesOrderID,
    OrderDate,
    TotalDue,
    AVG(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate)
    ) AS YearlyAverage,
    (TotalDue - AVG(TotalDue) OVER (PARTITION BY YEAR(OrderDate)))
        AS DiffFromAvg
FROM sales_salesorderheader
ORDER BY OrderDate ASC;

-- 6. Partition Sales by Territory and Rank:
-- Use the `DENSE_RANK()` window function to rank sales orders by amount within
-- each sales territory.
SELECT
    TerritoryID,
    SalesOrderID,
    TotalDue,
    DENSE_RANK() OVER (
        PARTITION BY TerritoryID
        ORDER BY TotalDue DESC
    ) AS RankInTerritory
FROM sales_salesorderheader
WHERE TerritoryID IS NOT NULL
ORDER BY TerritoryID ASC, RankInTerritory ASC;

-- 7. Calculate Percentile Sales:
-- Use the `PERCENT_RANK()` window function to calculate the percentile rank of
-- sales orders by amount within each year.
SELECT
    SalesOrderID,
    TotalDue,
    YEAR(OrderDate) AS SalesYear,
    PERCENT_RANK() OVER (
        PARTITION BY YEAR(OrderDate)
        ORDER BY TotalDue ASC
    ) AS PercentileRank
FROM sales_salesorderheader
ORDER BY SalesYear ASC, PercentileRank DESC;

-- 8. Identify First and Last Sale Date for Each Product:
-- Use the `FIRST_VALUE()` and `LAST_VALUE()` window functions to find the
-- first and last sale date for each product.
SELECT DISTINCT
    p.ProductID,
    p.Name,
    FIRST_VALUE(h.OrderDate) OVER (
        PARTITION BY p.ProductID
        ORDER BY h.OrderDate ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS FirstSaleDate,
    LAST_VALUE(h.OrderDate) OVER (
        PARTITION BY p.ProductID
        ORDER BY h.OrderDate ASC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS LastSaleDate
FROM sales_salesorderdetail AS d
INNER JOIN sales_salesorderheader AS h
    ON d.SalesOrderID = h.SalesOrderID
INNER JOIN production_product AS p
    ON d.ProductID = p.ProductID
ORDER BY p.Name ASC;

-- 9. Calculate Cumulative Quantity Sold:
-- Use the `SUM()` window function to calculate the cumulative quantity sold
-- for each product over time.
SELECT
    d.ProductID,
    h.OrderDate,
    d.SalesOrderDetailID,
    d.OrderQty,
    SUM(d.OrderQty) OVER (
        PARTITION BY d.ProductID
        ORDER BY h.OrderDate ASC, d.SalesOrderDetailID ASC
    ) AS CumulativeQty
FROM sales_salesorderdetail AS d
INNER JOIN sales_salesorderheader AS h
    ON d.SalesOrderID = h.SalesOrderID
ORDER BY d.ProductID ASC, h.OrderDate ASC;

-- 10. Compare Sales Growth by Quarter:
-- Use the `LAG()` window function to compare sales amounts between consecutive
-- quarters to calculate quarter-over-quarter growth.
WITH QuarterlySales AS (
    SELECT
        YEAR(OrderDate) AS SalesYear,
        QUARTER(OrderDate) AS SalesQuarter,
        SUM(TotalDue) AS TotalSales
    FROM sales_salesorderheader
    GROUP BY YEAR(OrderDate), QUARTER(OrderDate)
)

SELECT
    SalesYear,
    SalesQuarter,
    TotalSales,
    LAG(TotalSales) OVER (
        ORDER BY SalesYear ASC, SalesQuarter ASC
    ) AS PreviousQuarterSales,
    (
        TotalSales
        - LAG(TotalSales) OVER (ORDER BY SalesYear ASC, SalesQuarter ASC)
    )
    / LAG(TotalSales)
        OVER (ORDER BY SalesYear ASC, SalesQuarter ASC)
        AS GrowthRate
FROM QuarterlySales
ORDER BY SalesYear ASC, SalesQuarter ASC;

-- 11. Determine Employee Ranking by Sales:
-- Use the `RANK()` window function to rank employees by the total sales they
-- generated.
WITH EmployeeSales AS (
    SELECT
        SalesPersonID,
        SUM(TotalDue) AS TotalSales
    FROM sales_salesorderheader
    WHERE SalesPersonID IS NOT NULL
    GROUP BY SalesPersonID
)

SELECT
    SalesPersonID,
    TotalSales,
    RANK() OVER (ORDER BY TotalSales DESC) AS SalesRank
FROM EmployeeSales
ORDER BY SalesRank ASC;

-- 12. Segment Customers Based on Total Purchases:
-- Use the `NTILE()` window function to divide customers into quartiles based
-- on their total purchase amount.
WITH CustomerPurchases AS (
    SELECT
        CustomerID,
        SUM(TotalDue) AS TotalSpent
    FROM sales_salesorderheader
    GROUP BY CustomerID
)

SELECT
    CustomerID,
    TotalSpent,
    NTILE(4) OVER (ORDER BY TotalSpent DESC) AS Quartile
FROM CustomerPurchases
ORDER BY Quartile ASC, TotalSpent DESC;

-- 13. Calculate YTD (Year-to-Date) Sales:
-- Use the `SUM()` window function with a specific range to calculate
-- year-to-date sales for each product.
SELECT
    d.ProductID,
    p.Name,
    h.OrderDate,
    d.LineTotal,
    YEAR(h.OrderDate) AS SalesYear,
    SUM(d.LineTotal) OVER (
        PARTITION BY d.ProductID, YEAR(h.OrderDate)
        ORDER BY h.OrderDate ASC, d.SalesOrderDetailID ASC
    ) AS YTD_Product_Sales
FROM sales_salesorderdetail AS d
INNER JOIN sales_salesorderheader AS h
    ON d.SalesOrderID = h.SalesOrderID
INNER JOIN production_product AS p
    ON d.ProductID = p.ProductID
ORDER BY d.ProductID ASC, h.OrderDate ASC;

-- 14. Analyze Variance in Monthly Sales:
-- Use the `STDDEV()` window function to calculate the standard deviation of
-- sales amounts for each month to analyze volatility.
SELECT DISTINCT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    STDDEV(TotalDue) OVER (
        PARTITION BY YEAR(OrderDate), MONTH(OrderDate)
    ) AS MonthlySalesStdDev
FROM sales_salesorderheader
ORDER BY SalesYear ASC, SalesMonth ASC;
