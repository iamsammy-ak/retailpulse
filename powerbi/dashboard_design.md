# RetailPulse BI - Power BI Dashboard Design

## Page 1: Executive Sales Overview

### Layout (16:9, 1280x720)

```
+--------------------------------------------------------------+
|  Slicers:  [Year]  [Region Group]  [Channel]                 |
+--------------------------------------------------------------+
|  [Total Sales] [Total Profit] [Margin %] [Orders] [AOV]      |   <- KPI cards (5)
+--------------------------------------------------------------+
|                              |                                |
|   Monthly Sales Trend        |   Top 5 Products by Revenue    |   <- Combo bar/line
|   (Line: Sales,              |   (Bar: Product, Value: Sales, |
|    Line: Profit)             |    Color: Category)            |
|                              |                                |
+------------------------------+--------------------------------+
|                              |                                |
|   Sales by Region Group      |   Discount Band vs Profit      |   <- Donut + Bar
|   (Filled map or bar)        |   (X: Discount band, Y: Profit) |
|                              |                                |
+------------------------------+--------------------------------+
|   Segment Performance (Table)                                |
|   Segment | Customers | Orders | Sales | Profit | AOV        |
+--------------------------------------------------------------+
```

### Visual specifications
- **KPI cards** (top row, 5 across)
  - Total Sales, Total Profit, Profit Margin %, Total Orders, AOV
  - Each shows current value + YoY% delta with up/down arrow indicator
- **Monthly Sales Trend** (left, 60% width)
  - Combo chart. X = `Date[YearMonth]`. Column = `Total Sales`. Line = `Total Profit`.
  - Data labels on, X-axis labels angled 30 degrees.
- **Top 5 Products by Revenue** (right, 40% width)
  - Clustered bar. Y = `DimProduct[ProductName]` (top 5 via Top N). X = `Total Sales`.
  - Data colors mapped to `DimProduct[Category]`.
- **Sales by Region Group** (bottom left)
  - Filled map or bar chart. Region = `DimRegion[RegionGroup]`. Value = `Total Sales`.
- **Discount Band vs Profit** (bottom right)
  - Clustered column. X = a calculated `Discount Band` column on `FactSales`. Y = `Total Profit`.
- **Segment Performance table** (full width)
  - Rows: `DimCustomer[Segment]`. Values: Customers, Orders, Sales, Profit, AOV.
  - Conditional formatting: data bars on Sales; red/green on Margin.

### Slicers (top of page, sync to all visuals)
- Year (single-select default = latest year)
- Region Group (multi-select)
- Channel (Online / Retail)

### Interactivity
- Cross-filtering enabled on all visuals.
- Tooltip page: hover a product bar shows monthly sales trend for that product.
- Drill-through: right-click a region -> goes to "Region Detail" page.

### Formatting
- Theme: custom or "Executive" Power BI theme. Background `#F5F7FA`, accent `#1F4E79`.
- Number formats: currency `$#,##0` for money, percent `0.0%` for margins, integer for orders.
- Title bar with company name placeholder, refresh date, and a bookmark "Reset all filters".
- Mobile layout: stack cards vertically, then charts in one column.

### Storytelling order (top-to-bottom)
1. What is happening? Headline numbers (cards).
2. Is it growing? Trend chart with YoY.
3. Where is it happening? Region and segment breakdown.
4. Why? Discount impact and product mix.
5. So what? Segment table and Top-5 prompt action.

---

## Page 2 (optional): Region / Product Detail

### Layout
- Filters on the left: Region, Country, City, Category, Subcategory, Product.
- KPI cards: Sales, Profit, Margin %, AOV for the selected slice.
- Line chart: Sales over time (drill down Year > Quarter > Month).
- Bar chart: Top 10 products in the selected region.
- Table: Customer contribution with sortable columns.

### Drill-through
- Source page: Executive overview.
- Target: this detail page.
- "Back" button (Power BI built-in) returns to the originating visual's filter context.

---

## Delivery checklist
- [ ] Model relationships verified (one-to-many from dims to fact).
- [ ] Date table marked as date table.
- [ ] All measures created in a single `Sales Measures` display folder.
- [ ] Number formats applied at the measure level, not the visual.
- [ ] Slicers in a dedicated slicer pane.
- [ ] Bookmarks: Reset, YTD view, PY view.
- [ ] Report saved as `RetailPulse_BI.pbix`. Published to workspace if applicable.
- [ ] Row-level security note (out of scope for portfolio; document the intent).
