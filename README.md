# 📚 Gravity Books — Data Warehouse & OLAP Project

A full end-to-end **Data Warehousing** project built on the **Gravity Books** OLTP database, covering source analysis, dimensional modeling, ETL pipelines, and an SSAS multidimensional cube.

---

## 🗂️ Project Structure

```
📁 New folder/
├── 📁 Gravity_Books_ETL/         # SSIS ETL project (dimension & fact packages)
├── 📁 DWH_Gravity_SSAS/          # SSAS multidimensional cube project
├── 🖼️ 1–10.png                   # Project documentation screenshots
└── 🗄️ Gravity_DWH               # SQL Server Data Warehouse database backup
```

---

## 🏗️ Architecture Overview

```
┌─────────────────────┐     ┌──────────────────────┐     ┌──────────────────────┐
│   Source OLTP DB    │────▶│     SSIS ETL Layer    │────▶│  DWH (Star Schema)   │
│  (Gravity Books)    │     │  Gravity_Books_ETL    │     │   SQL Server DWH     │
└─────────────────────┘     └──────────────────────┘     └──────────┬───────────┘
                                                                     │
                                                                     ▼
                                                          ┌──────────────────────┐
                                                          │    SSAS OLAP Cube    │
                                                          │  DWH_Gravity_SSAS    │
                                                          └──────────────────────┘
```

---

## 1️⃣ Source System — Gravity Books OLTP

The source is a normalized **bookstore transactional database** with the following entities:

| Domain | Tables |
|---|---|
| **Books** | `book`, `book_language`, `book_author`, `author`, `publisher` |
| **Customers** | `customer`, `customer_address`, `address`, `address_status`, `country` |
| **Orders** | `cust_order`, `order_line`, `order_history`, `order_status`, `shipping_method` |

**Source ERD:**

![Source ERD](10.png)

---

## 2️⃣ Dimensional Model — Star Schema

The DWH follows a **Star Schema** design with **SCD Type 2** tracking on slowly changing dimensions.

### Fact Table

| Table | Description | Foreign Keys |
|---|---|---|
| `Fact_Sales` | Core sales grain — one row per order line | Book, Date, Time, Customer, History, Order |

### Dimension Tables

| Dimension | Key Columns | SCD | Notes |
|---|---|---|---|
| `Dim_Book` | Book_SK, Book_BK, Title, ISBN13, Language, Publisher | Type 1 | Full book catalog |
| `Dim_Author` | Author_SK, Author_BK, Author_Name | Type 1 | |
| `Dim_BookAuthor` | BookAuthor_SK, Book_BK, Author_BK | — | Bridge table |
| `Dim_Customer` | Customer_SK, Customer_BK, First_Name, Last_Name, Email | Type 2 | ST_Date, End_Date, Is_Current |
| `Dim_Customer_Address` | Customer_Address_SK, Customer_BK, Address_BK, Status | Type 2 | |
| `Dim_Address` | Address_SK, Address_BK, Street_Number, Street_Name, City, Country | Type 2 | |
| `Dim_Customer_Order` | Order_SK, Order_id, Order_date, Shipping_Method_BK, Dest_Address_BK | Type 2 | Includes SSC, Cost, Is_Current |
| `Dim_Order_History` | History_SK, Order_BK, Status_BK, Status_Value, Start_Date, End_Date | Type 2 | Tracks order lifecycle |
| `DimDate` | DateSK, Date, Day, DayOfWeek, Week, Month, Quarter, Year | — | Full calendar attributes |
| `DimTime` | TimeSK, Time, Hour, Minute, Second, AmPm | — | Time-of-day grain |

**Star Schema Diagram:**

![Star Schema](6.png)

---

## 3️⃣ ETL Layer — SSIS (`Gravity_Books_ETL`)

All ETL packages are built with **SQL Server Integration Services (SSIS)** and implement **SCD Type 2** logic where applicable.

### SSIS Packages

| # | Package | Target Dimension | Size |
|---|---|---|---|
| 01 | `01_Dim_Customer.dtsx` | `Dim_Customer` | 90 KB |
| 02 | `02_Dim_book.dtsx` | `Dim_Book` | 47 KB |
| 03 | `03_Dim_Customer_Address.dtsx` | `Dim_Customer_Address` | 31 KB |
| 04 | `04_Dim_Address.dtsx` | `Dim_Address` | 101 KB |
| 05 | `05_Dim_Book_Author.dtsx` | `Dim_BookAuthor` | 28 KB |
| 06 | `06_Dim_Author.dtsx` | `Dim_Author` | 28 KB |
| 07 | `07_Dim_Order_History.dtsx` | `Dim_Order_History` | 98 KB |
| 08 | `08_Dim_Customer_Order.dtsx` | `Dim_Customer_Order` | 108 KB |
| — | `Fact_Sales.dtsx` | `Fact_Sales` | 116 KB |

### ETL Execution Order

```
01_Dim_Customer
02_Dim_Book
03_Dim_Customer_Address
04_Dim_Address
05_Dim_Book_Author
06_Dim_Author
07_Dim_Order_History
08_Dim_Customer_Order
        │
        ▼
  Fact_Sales  ← (loaded last, after all dimensions are ready)
```

> **Connection Managers:** `LocalHost.DWH_Gravity_Books.conmgr` (DWH target) and `LocalHost.gravity_books.conmgr` (OLTP source) — both configured via `Project.params`.

---

## 4️⃣ OLAP Layer — SSAS Cube (`DWH_Gravity_SSAS`)

A **multidimensional SSAS cube** built on top of the star schema.

**Cube:** `DWH Gravity Books`

### Measures (Measure Groups)

| Measure Group | Key Metrics |
|---|---|
| **DWH Gravity Books** | Aggregate sales metrics |
| **Fact Sales** | Sales count, revenue |
| **Dim Book Author** | Author–book relationships |
| **Dim Customer Address** | Address coverage |

### Dimensions in Cube

| Dimension | Attributes |
|---|---|
| Dim Book | Title, ISBN13, Language, Publisher, Num_Pages, Publication_Date |
| Dim Author | Author Name |
| Dim Customer Order | Order details, Shipping Method, Cost |
| Dim Customer | Name, Email |
| Dim Customer Address | Address Status |
| Dim Address | Street, City, Country |
| Dim Order History | Status lifecycle |
| Dim Date | Full calendar hierarchy (Day → Month → Quarter → Year) |
| Dim Time | Hour → Minute → Second |

**SSAS Cube Design:**

![SSAS Cube](1.png)

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Source OLTP | SQL Server |
| Data Warehouse | SQL Server (Star Schema) |
| ETL | SQL Server Integration Services (SSIS) |
| OLAP | SQL Server Analysis Services (SSAS) — Multidimensional |
| Development IDE | Visual Studio (with SSDT) |

---

## 🚀 Getting Started

### Prerequisites

- SQL Server 2019+
- SQL Server Integration Services (SSIS)
- SQL Server Analysis Services (SSAS)
- Visual Studio with SQL Server Data Tools (SSDT)

### Setup Steps

1. **Restore the source database**
   - Restore `Gravity_DWH` backup file to your SQL Server instance.

2. **Create the DWH database**
   - Execute the star schema DDL scripts to create all dimension and fact tables.

3. **Configure ETL connections**
   - Open `Gravity_Books_ETL` in Visual Studio.
   - Update `LocalHost.gravity_books.conmgr` to point to your OLTP source.
   - Update `LocalHost.DWH_Gravity_Books.conmgr` to point to your DWH database.

4. **Run SSIS packages** in order (01 → 08 → Fact_Sales)

5. **Deploy the SSAS cube**
   - Open `DWH_Gravity_SSAS` in Visual Studio.
   - Update the `Sales_Data_Source` connection string.
   - Deploy and process the cube.

---

## 📸 Screenshots

| # | Description |
|---|---|
| `1.png` | SSAS Cube Design (Visual Studio) |
| `6.png` | Star Schema Diagram (SQL Server) |
| `10.png` | Source OLTP ERD (Gravity Books) |

---

## 👤 Author

**Hazem Osama**
Data Engineering Track — Information Technology Institute (ITI)
