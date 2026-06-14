# RetailPulse BI | SQL Server, Power BI, DAX

End-to-end Business Intelligence portfolio project that simulates a real BI delivery: data modelling, SQL, DAX, dashboard design, testing, and documentation.

## Project summary
A retail company (mock) wants visibility into sales, profit, product, and region performance. The solution loads star-schema data into SQL Server, exposes it through Power BI with DAX measures, and delivers an executive dashboard with KPIs, trends, and segment analysis.

## Business scenario
- **Company:** RetailPulse (fictional direct-to-consumer retailer).
- **Markets:** UK, Germany, Japan, India, USA (NY, Chicago), Brazil.
- **Channels:** Online, Retail.
- **Period covered:** Jan 2023 - Jun 2024.

## Business questions answered
1. What is total sales, profit, and margin this year vs last year?
2. Which products and categories drive the most revenue?
3. Which regions and cities are most profitable?
4. How does discount depth affect profit?
5. Which customer segment is the most valuable?

## KPIs
| KPI | Definition |
|-----|------------|
| Total Sales | SUM(FactSales.SalesAmount) |
| Total Cost | SUM(FactSales.CostAmount) |
| Total Profit | SUM(FactSales.ProfitAmount) |
| Profit Margin % | Profit / Sales |
| Total Orders | DISTINCTCOUNT(OrderID) |
| Average Order Value | Sales / Orders |
| YoY Growth % | (CY - PY) / PY |

## Architecture
```
   Source (CSV) --> SQL Server (dbo star schema) --> Power BI Desktop model
                                          \--> DAX measures --> Executive dashboard
```
- The star schema is implemented physically in SQL Server.
- In a real SSAS / Tabular deployment, the same model would be authored in Visual Studio as a Tabular model (.bim) and deployed to Analysis Services. The Power BI report would then connect live to that model. For portfolio scope, the Tabular model is conceptually identical to the Power BI dataset, so the same DAX and relationships apply.

## Repository layout
```
retailpulse/
+- .gitignore
+- data/                  CSV files for all 5 tables (regenerable)
+- generate_data.py       Python script that produces the CSVs (seed=42)
+- sql/
|  +- 01_ddl_and_load.sql Table DDL with PKs, FKs, indexes
|  +- 02_analytics.sql    6 analytical queries
+- powerbi/
|  +- dax_measures.md     15-measure DAX library with explanations
|  +- dashboard_design.md Layout, visuals, interactions
+- docs/
|  +- testing_plan.md     Test cases and UAT log
|  +- agile_plan.md       Backlog, sprint plan, DoD
|  +- cv_and_interview.md CV bullets, LinkedIn, Q&A
+- README.md
```

## Data model (star schema)

| Table | Role | Key |
|-------|------|-----|
| FactSales | Fact (grain: one row per order line) | SalesKey |
| DimDate | Dimension | DateKey |
| DimProduct | Dimension | ProductKey |
| DimCustomer | Dimension | CustomerKey |
| DimRegion | Dimension | RegionKey |

Relationships: DimDate, DimProduct, DimCustomer, DimRegion -> FactSales (one-to-many, single direction).

## Sample data
Generated with `python generate_data.py` (deterministic, seed=42):
- 7 regions, 12 products, 20 customers, 547 dates, 231 fact rows
- Total Sales: $60,941.75 | Total Cost: $28,947.50 | Total Profit: $31,994.25 | Orders: 120

## How to run
1. `python generate_data.py` to (re)create the CSVs.
2. In SSMS, create a database `RetailPulse` and run `sql/01_ddl_and_load.sql`, then BULK INSERT the CSVs from `/data`.
3. Run `sql/02_analytics.sql` to validate analytical outputs.
4. Open Power BI Desktop, import the CSVs (or connect to SQL Server), build relationships, create the DAX measures from `powerbi/dax_measures.md`, and replicate the layout in `powerbi/dashboard_design.md`.
5. Validate against `docs/testing_plan.md`.

## Assumptions
- One order can contain multiple products, so fact grain is order-line.
- Discounts are line-level percentages.
- Region attribution follows the customer's region, not shipping region.
- Cost and price are stable in the source system for the period analysed.
- Currency is single (USD-equivalent).

## Data definitions
- **SalesAmount** = Quantity * UnitPrice * (1 - DiscountPct)
- **CostAmount** = Quantity * UnitCost
- **ProfitAmount** = SalesAmount - CostAmount
- **Order** = unique `OrderID` (header). Fact is at line level.
- **Customer Segment** = source-system classification (Consumer, Corporate, Home Office).

## Refresh / update notes
- Daily refresh (intended). In production this would be a Power BI dataset refresh schedule; the SQL tables are updated by the upstream ETL.
- For the portfolio, the CSVs are regenerated deterministically (seed=42) so the numbers in the documentation are stable.

## Known limitations
- Small dataset (~230 fact rows). A production deployment would use incremental refresh and aggregations.
- No row-level security; would be added per region/segment in a real environment.
- No SSAS / Tabular deployment step; the model is built directly in Power BI Desktop. Conceptually identical to a Tabular model.
- No automated CI/CD; a real project would use Power BI deployment pipelines or Tabular Model deployment via Azure DevOps.
- No streaming source; data is loaded as a batch.

## Author
Built as a portfolio project for a Business Intelligence Developer role.
