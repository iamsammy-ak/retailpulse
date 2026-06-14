# RetailPulse BI - DAX Measures

All measures follow Power BI best practices:
- A dedicated **Date** table marked as a date table is required.
- All time intelligence measures use that date table.
- Measures are written against `FactSales` joined to `DimDate`, `DimProduct`, `DimCustomer`, `DimRegion`.

## Base measures

### Total Sales
```dax
Total Sales = SUM ( FactSales[SalesAmount] )
```
What it does: Sum of all order-line sales.
Used in: KPI cards, trend lines, every revenue visual.

### Total Cost
```dax
Total Cost = SUM ( FactSales[CostAmount] )
```
What it does: Total cost of goods sold.
Used in: Cost vs Sales chart, margin calculations.

### Total Profit
```dax
Total Profit = SUM ( FactSales[ProfitAmount] )
```
What it does: Sales minus cost across the filter context.
Used in: KPI card, profit-by-region chart.

### Profit Margin %
```dax
Profit Margin % =
DIVIDE ( [Total Profit], [Total Sales], 0 )
```
What it does: Profit as a % of sales; safe-divide protects against blanks.
Used in: KPI card, conditional formatting on tables.

### Total Orders
```dax
Total Orders = DISTINCTCOUNT ( FactSales[OrderID] )
```
What it does: Unique orders (fact grain is order-line, so we count distinct).
Used in: KPI card, AOV denominator.

### Average Order Value
```dax
Average Order Value =
DIVIDE ( [Total Sales], [Total Orders], 0 )
```
What it does: Revenue per order. Tied to `Total Orders` to stay consistent under filters.
Used in: KPI card, segment comparison.

### Total Units Sold
```dax
Total Units = SUM ( FactSales[Quantity] )
```
What it does: Units sold (handy alongside revenue).
Used in: Top products chart, channel comparison.

## Time intelligence

### Sales YTD
```dax
Sales YTD =
TOTALYTD ( [Total Sales], 'Date'[Date] )
```
What it does: Running total of sales within the current year.
Used in: YTD trend line, headline KPI with date slicer.

### Sales Previous Year
```dax
Sales PY =
CALCULATE (
    [Total Sales],
    SAMEPERIODLASTYEAR ( 'Date'[Date] )
)
```
What it does: Sales in the equivalent period one year earlier.
Used in: YoY comparison, variance columns.

### YoY Growth %
```dax
YoY Growth % =
DIVIDE ( [Total Sales] - [Sales PY], [Sales PY], 0 )
```
What it does: Year-over-year change as a %.
Used in: KPI card with arrow indicator, monthly comparison chart.

### YoY Growth (absolute)
```dax
YoY Growth = [Total Sales] - [Sales PY]
```

## Ranking & analytics

### Top Product Rank
```dax
Top Product Rank =
RANKX (
    ALL ( DimProduct[ProductName] ),
    [Total Sales],
    ,
    DESC,
    DENSE
)
```
What it does: Dense rank of each product by sales. `1` = top seller.
Used in: Conditional formatting in a Top-N product table; also a slicer-driving measure.

### Top N Sales (parameter-driven)
```dax
Top N Sales =
VAR N = [Top N Value]   -- disconnected parameter, default 5
RETURN
    CALCULATE (
        [Total Sales],
        TOPN ( N, ALL ( DimProduct[ProductName] ), [Total Sales], DESC )
    )
```
What it does: Sales of only the top N products. Use with a What-if parameter `Top N Value`.
Used in: "Top 5 products" bar chart.

### Discount Impact (%)
```dax
Discount Impact % =
AVERAGEX ( FactSales, FactSales[DiscountPct] )
```
What it does: Average discount across the filter context.
Used in: Tooltip on profit charts, discount band bar.

## KPI card formatting expressions

### Sales arrow (up/down)
```dax
Sales Trend =
IF (
    [YoY Growth %] >= 0, 1, -1
)
```
Format the KPI card with conditional icon: up = green, down = red.

## Notes on best practice
- Prefer **measures over calculated columns** for any aggregation (sales, profit, AOV, YoY).
- Keep numeric formatting in the model: `Total Sales`, `Total Profit` -> Currency; `Profit Margin %` -> Percentage; `Total Orders` -> Whole number.
- Mark the `Date` table as a date table: Table tools -> Mark as date table -> column `Date`.
- Hide helper columns (`DateKey`, FK columns) from report view.
