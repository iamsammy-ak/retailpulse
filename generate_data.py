"""
RetailPulse BI - Mock Data Generator
Generates consistent star-schema CSVs for the retail portfolio project.
Reproducible: seed=42 yields the exact totals documented in the README
(Sales = $60,941.75, Profit = $31,994.25, 231 fact rows, 120 distinct orders).
"""
import csv
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)

OUT = Path(__file__).parent / "data"
OUT.mkdir(exist_ok=True)

# ---------- DimRegion ----------
regions = [
    (1, "EMEA",   "UK",      "London",    "Online + Retail"),
    (2, "EMEA",   "Germany", "Berlin",    "Online + Retail"),
    (3, "APAC",   "Japan",   "Tokyo",     "Online"),
    (4, "APAC",   "India",   "Mumbai",    "Online + Retail"),
    (5, "NA",     "USA",     "New York",  "Online + Retail"),
    (6, "NA",     "USA",     "Chicago",   "Retail"),
    (7, "LATAM",  "Brazil",  "Sao Paulo", "Online + Retail"),
]
with (OUT / "DimRegion.csv").open("w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["RegionKey","RegionGroup","Country","City","ChannelMix"])
    w.writerows(regions)

# ---------- DimProduct ----------
products = [
    (1, "Aurora Wireless Earbuds",   "Electronics", "Audio",       129.00,  62.00),
    (2, "Nimbus Smartwatch",         "Electronics", "Wearables",   249.00, 120.00),
    (3, "Atlas Laptop Stand",        "Accessories", "Desk Setup",   39.00,  14.00),
    (4, "Trail Runner Shoes",        "Apparel",     "Footwear",     89.00,  41.00),
    (5, "Pioneer Backpack 25L",      "Accessories", "Bags",         59.00,  22.00),
    (6, "Cascade Water Bottle 1L",   "Lifestyle",   "Hydration",    19.00,   6.50),
    (7, "Lumen Desk Lamp",           "Home",        "Lighting",     49.00,  18.00),
    (8, "Forge Chef Knife 8in",      "Home",        "Kitchen",      79.00,  28.00),
    (9, "Drift Hoodie",              "Apparel",     "Outerwear",    69.00,  25.00),
    (10,"Pulse Yoga Mat",            "Lifestyle",   "Fitness",      34.00,  11.00),
    (11,"Halo Air Purifier",         "Home",        "Appliances",  189.00,  88.00),
    (12,"Vector Mechanical Keyboard","Electronics", "Peripherals",  119.00,  55.00),
]
with (OUT / "DimProduct.csv").open("w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["ProductKey","ProductName","Category","Subcategory","UnitPrice","UnitCost"])
    w.writerows(products)

# ---------- DimCustomer ----------
segments = ["Consumer","Corporate","Home Office"]
first_names = ["Ava","Noah","Mia","Liam","Zoe","Aarav","Yuki","Sofia","Diego","Priya","Jonas","Hana","Lucas","Aisha","Mateo","Chloe","Kenji","Emma","Ravi","Lea"]
last_names  = ["Patel","Khan","Silva","Tanaka","Mueller","Rossi","Brown","Garcia","Singh","Nakamura","Schmidt","Costa","Park","Khan","Lopez","Smith","Yamada","Adler","Verma","Aoki"]
customers = []
for i in range(1, 21):
    fn = random.choice(first_names)
    ln = random.choice(last_names)
    customers.append((
        i,
        f"{fn} {ln}",
        random.choice(segments),
        random.choice([r[0] for r in regions]),
        date(2022, 1, 1) + timedelta(days=random.randint(0, 700)),
    ))
with (OUT / "DimCustomer.csv").open("w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["CustomerKey","CustomerName","Segment","RegionKey","SignupDate"])
    w.writerows(customers)

# ---------- DimDate ----------
start = date(2023, 1, 1)
end   = date(2024, 6, 30)
rows = []
d = start
dk = 1
while d <= end:
    rows.append((
        dk,
        d.isoformat(),
        d.day,
        d.month,
        d.year,
        d.strftime("%A"),
        d.strftime("%b"),
        ("Q1" if d.month <= 3 else "Q2" if d.month <= 6 else "Q3" if d.month <= 9 else "Q4"),
        ("H1" if d.month <= 6 else "H2"),
        f"{d.month:02d}/{d.year}",
        1 if d.weekday() >= 5 else 0,
    ))
    dk += 1
    d += timedelta(days=1)
with (OUT / "DimDate.csv").open("w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["DateKey","FullDate","Day","Month","Year","DayName","MonthName","Quarter","Half","YearMonth","IsWeekend"])
    w.writerows(rows)

date_keys = [r[0] for r in rows]

# ---------- FactSales ----------
# Grain: one row per order line (OrderID + ProductKey)
channel_mix = ["Online","Retail","Online","Online","Retail"]
order_id = 1000
fact = []
for _ in range(120):
    oid = order_id
    order_date = random.choice(date_keys)
    cust = random.choice(customers)
    channel = random.choice(channel_mix)
    n_lines = random.randint(1, 3)
    used_p = set()
    for _ in range(n_lines):
        p = random.choice(products)
        while p[0] in used_p:
            p = random.choice(products)
        used_p.add(p[0])
        qty = random.randint(1, 5)
        discount = round(random.choice([0, 0, 0.05, 0.10, 0.15, 0.20]), 2)
        sales = round(qty * p[4] * (1 - discount), 2)
        cost  = round(qty * p[5], 2)
        profit = round(sales - cost, 2)
        fact.append((
            len(fact) + 1,
            oid,
            order_date,
            cust[0],
            p[0],
            cust[3],            # region key from customer
            qty,
            p[4],               # unit price
            p[5],               # unit cost
            discount,
            sales,
            cost,
            profit,
            channel,
        ))
    order_id += 1

with (OUT / "FactSales.csv").open("w", newline="") as f:
    w = csv.writer(f)
    w.writerow([
        "SalesKey","OrderID","DateKey","CustomerKey","ProductKey","RegionKey",
        "Quantity","UnitPrice","UnitCost","DiscountPct","SalesAmount","CostAmount","ProfitAmount","Channel"
    ])
    w.writerows(fact)

print("CSVs written to", OUT)
print(f"Regions: {len(regions)}  Products: {len(products)}  Customers: {len(customers)}  Dates: {len(rows)}  Fact rows: {len(fact)}")
print(f"Total Sales: {sum(r[10] for r in fact):.2f}  Total Profit: {sum(r[12] for r in fact):.2f}  Distinct Orders: {len(set(r[1] for r in fact))}")
