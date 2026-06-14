-- =====================================================================
-- RetailPulse BI  |  DDL + Sample Data
-- Target: Microsoft SQL Server 2019+
-- Run order: 1) Create DB  2) Run this file  3) Run 02_analytics.sql
-- =====================================================================

USE RetailPulse;
GO

-- Drop in dependency order (idempotent re-runs)
IF OBJECT_ID('dbo.FactSales',  'U') IS NOT NULL DROP TABLE dbo.FactSales;
IF OBJECT_ID('dbo.DimProduct', 'U') IS NOT NULL DROP TABLE dbo.DimProduct;
IF OBJECT_ID('dbo.DimCustomer','U') IS NOT NULL DROP TABLE dbo.DimCustomer;
IF OBJECT_ID('dbo.DimRegion',  'U') IS NOT NULL DROP TABLE dbo.DimRegion;
IF OBJECT_ID('dbo.DimDate',    'U') IS NOT NULL DROP TABLE dbo.DimDate;
GO

CREATE TABLE dbo.DimDate (
    DateKey      INT         NOT NULL PRIMARY KEY,
    FullDate     DATE        NOT NULL,
    [Day]        TINYINT     NOT NULL,
    [Month]      TINYINT     NOT NULL,
    [Year]       SMALLINT    NOT NULL,
    DayName      VARCHAR(10) NOT NULL,
    MonthName    VARCHAR(10) NOT NULL,
    [Quarter]    CHAR(2)     NOT NULL,
    [Half]       CHAR(2)     NOT NULL,
    YearMonth    VARCHAR(8)  NOT NULL,
    IsWeekend    BIT         NOT NULL
);
GO

CREATE TABLE dbo.DimRegion (
    RegionKey    INT          NOT NULL PRIMARY KEY,
    RegionGroup  VARCHAR(20)  NOT NULL,
    Country      VARCHAR(50)  NOT NULL,
    City         VARCHAR(50)  NOT NULL,
    ChannelMix   VARCHAR(30)  NOT NULL
);
GO

CREATE TABLE dbo.DimProduct (
    ProductKey   INT           NOT NULL PRIMARY KEY,
    ProductName  VARCHAR(80)   NOT NULL,
    Category     VARCHAR(40)   NOT NULL,
    Subcategory  VARCHAR(40)   NOT NULL,
    UnitPrice    DECIMAL(10,2) NOT NULL,
    UnitCost     DECIMAL(10,2) NOT NULL
);
GO

CREATE TABLE dbo.DimCustomer (
    CustomerKey  INT          NOT NULL PRIMARY KEY,
    CustomerName VARCHAR(80)  NOT NULL,
    Segment      VARCHAR(20)  NOT NULL,
    RegionKey    INT          NOT NULL,
    SignupDate   DATE         NOT NULL,
    CONSTRAINT FK_Customer_Region FOREIGN KEY (RegionKey) REFERENCES dbo.DimRegion(RegionKey)
);
GO

-- Grain: one row per order line (OrderID + ProductKey)
CREATE TABLE dbo.FactSales (
    SalesKey      INT           NOT NULL PRIMARY KEY,
    OrderID       INT           NOT NULL,
    DateKey       INT           NOT NULL,
    CustomerKey   INT           NOT NULL,
    ProductKey    INT           NOT NULL,
    RegionKey     INT           NOT NULL,
    Quantity      INT           NOT NULL,
    UnitPrice     DECIMAL(10,2) NOT NULL,
    UnitCost      DECIMAL(10,2) NOT NULL,
    DiscountPct   DECIMAL(5,2)  NOT NULL,
    SalesAmount   DECIMAL(12,2) NOT NULL,
    CostAmount    DECIMAL(12,2) NOT NULL,
    ProfitAmount  DECIMAL(12,2) NOT NULL,
    Channel       VARCHAR(20)   NOT NULL,
    CONSTRAINT FK_Fact_Date     FOREIGN KEY (DateKey)     REFERENCES dbo.DimDate(DateKey),
    CONSTRAINT FK_Fact_Customer FOREIGN KEY (CustomerKey) REFERENCES dbo.DimCustomer(CustomerKey),
    CONSTRAINT FK_Fact_Product  FOREIGN KEY (ProductKey)  REFERENCES dbo.DimProduct(ProductKey),
    CONSTRAINT FK_Fact_Region   FOREIGN KEY (RegionKey)   REFERENCES dbo.DimRegion(RegionKey)
);
CREATE INDEX IX_Fact_Date     ON dbo.FactSales(DateKey);
CREATE INDEX IX_Fact_Customer ON dbo.FactSales(CustomerKey);
CREATE INDEX IX_Fact_Product  ON dbo.FactSales(ProductKey);
GO

-- Sample data is loaded from CSVs in /data via Python generator or BULK INSERT:
--   BULK INSERT dbo.DimRegion FROM 'C:\data\DimRegion.csv'
--   WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);

-- Quick validation
SELECT 'DimDate' AS Tbl, COUNT(*) AS Rows FROM dbo.DimDate
UNION ALL SELECT 'DimRegion',   COUNT(*) FROM dbo.DimRegion
UNION ALL SELECT 'DimProduct',  COUNT(*) FROM dbo.DimProduct
UNION ALL SELECT 'DimCustomer', COUNT(*) FROM dbo.DimCustomer
UNION ALL SELECT 'FactSales',   COUNT(*) FROM dbo.FactSales;
