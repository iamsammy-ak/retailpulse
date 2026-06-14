# RetailPulse BI - Testing & Validation Plan

## 1. SQL layer

| # | Test | Expected | Pass/Fail |
|---|------|----------|-----------|
| 1 | Row count per table matches CSV | 7 / 12 / 20 / 547 / 231 | |
| 2 | Primary key uniqueness on all dims and `FactSales.SalesKey` | 0 duplicates | |
| 3 | No NULL in `SalesAmount`, `ProfitAmount`, `CostAmount` | 0 NULLs | |
| 4 | All FK values in `FactSales` exist in parent dims | 0 orphans | |
| 5 | `SUM(SalesAmount) - SUM(CostAmount) = SUM(ProfitAmount)` | equality | |
| 6 | `SUM(Quantity * UnitPrice * (1 - DiscountPct)) ~ SUM(SalesAmount)` | equality (rounding) | |

Sample check queries:

```sql
-- Row counts
SELECT 'FactSales' AS Tbl, COUNT(*) AS n FROM dbo.FactSales;

-- Duplicate keys
SELECT SalesKey, COUNT(*) c
FROM dbo.FactSales
GROUP BY SalesKey HAVING COUNT(*) > 1;  -- should be empty

-- Orphan FKs
SELECT f.SalesKey
FROM dbo.FactSales f
LEFT JOIN dbo.DimProduct p ON p.ProductKey = f.ProductKey
WHERE p.ProductKey IS NULL;            -- should be empty

-- Profit identity
SELECT
   SUM(f.SalesAmount) - SUM(f.CostAmount) AS CalcProfit,
   SUM(f.ProfitAmount)                    AS StoredProfit
FROM dbo.FactSales f;
```

## 2. Model layer (Power BI / Tabular)

| # | Test | Expected |
|---|------|----------|
| 1 | One-to-many relationships from each dim to FactSales, single direction | OK |
| 2 | No bi-directional relationships unless justified | OK |
| 3 | `Date` table marked as a date table, has continuous dates | OK |
| 4 | Date key column hidden from report view | OK |
| 5 | All numeric columns typed correctly (Decimal, Whole) | OK |
| 6 | No calculated columns where a measure would do | OK |

## 3. DAX validation

| # | Measure | SQL cross-check | Tolerance |
|---|---------|------------------|-----------|
| 1 | `Total Sales` | `SUM(FactSales.SalesAmount)` | exact |
| 2 | `Total Profit` | `SUM(FactSales.ProfitAmount)` | exact |
| 3 | `Total Orders` | `COUNT(DISTINCT OrderID)` | exact |
| 4 | `Average Order Value` | `SUM(Sales)/COUNT(DISTINCT OrderID)` | exact |
| 5 | `Profit Margin %` | `SUM(Profit)/SUM(Sales)` | exact |
| 6 | `Sales YTD` (Dec 2024) | running total from Jan to selected date | exact |
| 7 | `Sales PY` (full 2023) | sales sum for same period last year | exact |
| 8 | `YoY Growth %` | `(CY - PY) / PY` | exact |

How to validate in Power BI:
1. Create a **card** for each measure and a **table** with the same number side by side.
2. Compare card value with SQL `SELECT SUM(...)`.
3. For YoY: build a small SQL query for the same period and confirm.

## 4. Filter / relationship behaviour

| # | Test | Action | Expected |
|---|------|--------|----------|
| 1 | Slicer on `Year` filters trend chart | select 2024 | 2023 values disappear |
| 2 | Slicer on `Region Group` filters map | select APAC | bars update |
| 3 | Cross-filter from a bar chart | click a category | cards and trend update |
| 4 | Drill-down Year > Quarter > Month | click a bar | hierarchy expands |
| 5 | Remove filter | Reset bookmark | visuals return to default |
| 6 | "Show as percent of grand total" | right-click on a bar | values sum to 100% |

## 5. Data quality

- Null check: no NULLs in mandatory columns.
- Duplicate check: surrogate keys are unique.
- Referential integrity: every fact FK resolves to a dim row.
- Range check: `DiscountPct BETWEEN 0 AND 1`, `Quantity > 0`.

## 6. Dashboard usability (UAT)

| # | Check | Pass |
|---|-------|------|
| 1 | Can a new user answer "What is total sales this year?" in <10 seconds? | |
| 2 | Are all KPI cards labelled and formatted? | |
| 3 | Are slicers clearly visible and reset-able? | |
| 4 | Does the report load in <5 seconds on a typical laptop? | |
| 5 | Are colours colour-blind friendly? | |
| 6 | Does mobile layout work? | |
| 7 | Is the data refresh date shown? | |

## 7. UAT validation log (business sign-off)

| Stakeholder | Question tested | Result | Sign-off |
|-------------|-----------------|--------|----------|
| Sales Director | Total sales by region, current year | Matches finance extract | |
| Finance | Profit margin by segment | Reconciles | |
| Marketing | Top 5 products list | Matches campaign report | |
| Ops | Monthly trend | Reconciles to ERP | |

## 8. Performance

- Card refresh: <1s
- Full report refresh: <5s on small dataset
- If dataset grows, schedule aggregations and incremental refresh in Power BI Service.
