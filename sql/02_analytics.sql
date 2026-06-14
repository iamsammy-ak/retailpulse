-- RetailPulse BI - Analytical queries

-- 1) Monthly sales trend
SELECT
    d.[Year],
    d.[Month],
    d.MonthName,
    d.YearMonth,
    SUM(f.SalesAmount)  AS TotalSales,
    SUM(f.ProfitAmount) AS TotalProfit,
    COUNT(DISTINCT f.OrderID) AS Orders
FROM dbo.FactSales f
JOIN dbo.DimDate d ON d.DateKey = f.DateKey
GROUP BY d.[Year], d.[Month], d.MonthName, d.YearMonth
ORDER BY d.[Year], d.[Month];
GO

-- 2) Top 5 products by revenue
SELECT TOP 5
    p.ProductName,
    p.Category,
    SUM(f.SalesAmount)  AS Revenue,
    SUM(f.ProfitAmount) AS Profit,
    SUM(f.Quantity)     AS Units
FROM dbo.FactSales f
JOIN dbo.DimProduct p ON p.ProductKey = f.ProductKey
GROUP BY p.ProductName, p.Category
ORDER BY Revenue DESC;
GO

-- 3) Region-wise profit
SELECT
    r.RegionGroup,
    r.Country,
    r.City,
    SUM(f.SalesAmount)  AS Sales,
    SUM(f.ProfitAmount) AS Profit,
    CAST(SUM(f.ProfitAmount) * 1.0 / NULLIF(SUM(f.SalesAmount),0) AS DECIMAL(6,4)) AS Margin
FROM dbo.FactSales f
JOIN dbo.DimRegion r ON r.RegionKey = f.RegionKey
GROUP BY r.RegionGroup, r.Country, r.City
ORDER BY Profit DESC;
GO

-- 4) Discount band impact on profit
SELECT
    CASE
        WHEN f.DiscountPct = 0     THEN '0%'
        WHEN f.DiscountPct <= 0.10 THEN '1-10%'
        WHEN f.DiscountPct <= 0.20 THEN '11-20%'
        ELSE '20%+'
    END AS DiscountBand,
    COUNT(*)                      AS OrderLines,
    SUM(f.SalesAmount)            AS Sales,
    SUM(f.ProfitAmount)           AS Profit,
    CAST(AVG(f.ProfitAmount) AS DECIMAL(10,2)) AS AvgProfitPerLine
FROM dbo.FactSales f
GROUP BY
    CASE
        WHEN f.DiscountPct = 0     THEN '0%'
        WHEN f.DiscountPct <= 0.10 THEN '1-10%'
        WHEN f.DiscountPct <= 0.20 THEN '11-20%'
        ELSE '20%+'
    END
ORDER BY DiscountBand;
GO

-- 5) Customer segment performance
SELECT
    c.Segment,
    COUNT(DISTINCT c.CustomerKey) AS Customers,
    COUNT(DISTINCT f.OrderID)     AS Orders,
    SUM(f.SalesAmount)            AS Sales,
    SUM(f.ProfitAmount)           AS Profit,
    CAST(SUM(f.SalesAmount) * 1.0 / NULLIF(COUNT(DISTINCT f.OrderID),0) AS DECIMAL(10,2)) AS AvgOrderValue
FROM dbo.FactSales f
JOIN dbo.DimCustomer c ON c.CustomerKey = f.CustomerKey
GROUP BY c.Segment
ORDER BY Sales DESC;
GO

-- 6) YoY comparison (window function)
WITH Yearly AS (
    SELECT d.[Year],
           SUM(f.SalesAmount)  AS Sales,
           SUM(f.ProfitAmount) AS Profit
    FROM dbo.FactSales f
    JOIN dbo.DimDate d ON d.DateKey = f.DateKey
    GROUP BY d.[Year]
)
SELECT [Year], Sales, Profit,
       LAG(Sales) OVER (ORDER BY [Year]) AS PrevYearSales,
       CAST( (Sales - LAG(Sales) OVER (ORDER BY [Year])) * 100.0
             / NULLIF(LAG(Sales) OVER (ORDER BY [Year]),0) AS DECIMAL(6,2)) AS YoYPct
FROM Yearly
ORDER BY [Year];
GO
