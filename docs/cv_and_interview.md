# RetailPulse BI - CV, LinkedIn, and Interview Content

## 1. CV bullet points (pick 3-4)

- Designed and built a **star-schema retail sales data model** in SQL Server (1 fact, 4 dimensions) supporting executive reporting on sales, profit, and customer segment performance.
- Authored **15+ DAX measures** in Power BI (YTD, YoY growth, profit margin, AOV, top-N ranking) and delivered an **executive dashboard** with KPI cards, monthly trend, region and segment breakdowns, and drill-through navigation.
- Wrote **analytical SQL** (joins, aggregations, window functions) for monthly trends, top products, regional profit, discount impact, and segment KPIs; cross-validated every Power BI measure against SQL totals to guarantee reporting accuracy.
- Produced end-to-end **BI documentation**: technical data dictionary, KPI definitions, KPI catalogue, test/UAT plan, and Agile delivery plan, following best practices for stakeholder-ready BI delivery.

## 2. GitHub project description

> **RetailPulse BI | SQL Server, Power BI, DAX**
> A portfolio BI project covering the full delivery lifecycle: star-schema data modelling in SQL Server, analytical SQL queries, a Power BI dataset with DAX measures (YTD, YoY, AOV, top-N), an executive dashboard with KPI cards, trend and segment visuals, and a complete documentation and testing pack. Built to demonstrate real-world BI Developer skills: dimensional modelling, DAX, dashboard design, validation, and Agile delivery.

Suggested topics/tags: `powerbi`, `dax`, `sql-server`, `star-schema`, `business-intelligence`, `data-warehouse`, `portfolio`.

## 3. LinkedIn post draft

Just shipped a new portfolio project: **RetailPulse BI**, an end-to-end retail sales dashboard built with **SQL Server, Power BI, and DAX**.

What is inside:
- A clean star schema: FactSales + DimDate, DimProduct, DimCustomer, DimRegion.
- 6 analytical SQL queries (monthly trend, top products, regional profit, discount impact, segment KPIs, YoY window function).
- A 15-measure DAX library covering sales, profit, margin, AOV, YTD, YoY growth, and top-N ranking.
- An executive dashboard design with KPI cards, a sales/profit trend, top-5 products, region and segment breakdowns, and drill-through navigation.
- A full BI delivery pack: README, data dictionary, test plan, UAT log, and an Agile sprint plan.

Why I built it: I wanted a portfolio piece that reflects how BI work is actually delivered - data model first, validated measures second, then a dashboard a stakeholder can use in 10 seconds. Happy to walk through it on a call.

Hashtags: #PowerBI #DAX #SQLServer #BusinessIntelligence #DataAnalytics #Portfolio #BIDeveloper

## 4. Elevator pitch (60 seconds)

"I built RetailPulse BI as a portfolio project to show the full BI lifecycle. I designed a star schema in SQL Server with one fact and four dimensions, loaded sample retail data, and wrote analytical SQL for monthly trends, top products, regional profit, and segment performance. In Power BI, I built a semantic model on top of that schema, wrote 15 DAX measures including YTD, YoY growth, profit margin, and average order value, and delivered an executive dashboard with KPI cards, a sales and profit trend, top-5 products, and a region and segment breakdown. Every measure was validated against SQL, and the repo includes a test plan, UAT log, and Agile delivery breakdown. The project is a faithful, if small-scale, version of what I'd deliver in a real BI team."

## 5. Likely interview questions and sample answers

**Q1. Walk me through your data model. Why a star schema?**
A: I used a star schema with `FactSales` at the grain of one order line, joined to `DimDate`, `DimProduct`, `DimCustomer`, and `DimRegion`. Star schemas are BI best practice because they keep joins simple, allow Power BI and SSAS to compress columns efficiently, and make filter propagation predictable. Snowflaking would add complexity without benefit at this scale.

**Q2. How did you decide on the fact grain?**
A: An order can have multiple products, so I chose the order-line grain. That let me analyse per-product revenue while still being able to count distinct orders using `DISTINCTCOUNT(OrderID)`. If I'd gone to order header, I'd lose product-level analysis; if I'd gone lower (e.g. daily snapshot), I'd over-count revenue.

**Q3. Why measures instead of calculated columns?**
A: Aggregations like Total Sales, Profit, and YoY are always calculated at query time against the current filter context. Putting them in calculated columns would inflate the model size, lock the result at refresh time, and remove the ability to respond to slicers. The only reason to use a calculated column is when the value is a property of a single row, like a `Discount Band` bucket.

**Q4. How do you validate a Power BI report?**
A: Three layers. First, data quality at the source: row counts, null checks, duplicate keys, and orphan foreign keys. Second, measure parity: every DAX measure is compared against a SQL aggregate for the same filter context. Third, dashboard behaviour: I test slicer interaction, drill-down, and reset. I document the test plan and a UAT log in the repo so a stakeholder can sign off.

**Q5. Explain `SAMEPERIODLASTYEAR` and why you need a date table.**
A: `SAMEPERIODLASTYEAR` returns the equivalent range in the previous year for the dates in the current filter context. It needs a properly marked date table with continuous dates so the time intelligence functions know what "the same period last year" means. Without a marked date table, you get blank visuals or wrong YoY numbers.

**Q6. How would you scale this to a real warehouse?**
A: Move the source into a proper staging / core / mart layered warehouse, add SCD2 for the customer and product dimensions, and deploy the semantic model as a Tabular model in SSAS so multiple reports can share one version of the truth. On the Power BI side, add incremental refresh and aggregations, and put row-level security in place for regional sales managers.

**Q7. Where would SSAS / Tabular fit in this architecture?**
A: In a full enterprise design, the Power BI dataset would be authored as a Tabular model in Visual Studio, deployed to an Analysis Services instance, and consumed by Power BI reports via a live connection. For a portfolio build, the Power BI dataset is functionally equivalent to a Tabular model: same relationships, same DAX, same partition and refresh concepts. I designed the DAX and the model so they would translate 1:1 into a Tabular deployment.

**Q8. What's one thing you'd improve?**
A: Add an aggregated table for the monthly trend so the visual pre-aggregates instead of scanning the fact on every click. Combined with incremental refresh, that would keep the dashboard fast as the dataset grows.
