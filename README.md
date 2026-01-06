# AdventureWorks 2017 – Monthly Sales, Cost & Inventory Analysis by Country (SQL)

📌 Project Overview

This repository contains an SQL Server analytical query developed using the AdventureWorks 2017 sample database.
The query produces a monthly financial, operational, and inventory analysis by country, combining data from sales, purchasing, production cost history, and manufacturing operations.

The solution is built using Common Table Expressions (CTEs) to ensure:

- Clear logical separation of steps
- Historical accuracy of product costs
- Reliable stock calculations
- Scalable and readable SQL design

🎯 Analysis Objectives

The query calculates the following metrics per year, month, and country:

- Quantity sold
- Quantity purchased
- Cumulative stock
- Gross monthly revenue
- Gross monthly cost
- Gross profit
- Operating profit
- Gross margin (%)
- Operating margin (%)

These indicators support commercial performance analysis, margin monitoring, and inventory management across geographic markets.

🗄️ Database & Environment

- Database: AdventureWorks 2017
- DBMS: Microsoft SQL Server
- Tables Used
- Sales.SalesOrderHeader
- Sales.SalesOrderDetail
- Purchasing.PurchaseOrderHeader
- Purchasing.PurchaseOrderDetail
- Production.ProductCostHistory
- Production.WorkOrderRouting
- Sales.SalesTerritory

🧠 Key SQL Concepts Used

- Common Table Expressions (CTEs)
- Time-based aggregation (Year / Month)
- Territory-to-country mapping
- Historical cost validation using StartDate and EndDate
- Window functions (SUM() OVER) for cumulative stock calculation
- Defensive calculations with NULLIF
- Multi-source joins across Sales, Purchasing, and Production domains

🧩 Query Logic Overview

The query is structured into the following CTEs:

vendas1
- Extracts detailed sales data, including order date, product, quantity, territory, and effective unit price.

vendas2
- Applies historically valid StandardCost to each sale based on the transaction date.

vendas_agg
- Aggregates sales data by year, month, product, and territory, calculating revenue, cost, and gross profit.

compras
- Aggregates purchased quantities by year, month, and product.

stock_calc
- Calculates cumulative inventory levels per product using window functions
(cumulative purchases minus cumulative sales).

custo_operacional
- Computes the average operational (manufacturing) cost per product.

regioes
- Maps sales territories to country names.

resumo_por_pais
- Consolidates all metrics by year, month, and country, producing financial, operational, and inventory KPIs.

Final SELECT
- Calculates gross and operating margins (%) and returns the final ordered result set.

📈 Final Output

The final query returns one row per:

- Year × Month × Country

Including:

- Sales, purchase, and stock quantities
- Gross revenue and cost
- Gross and operating profit
- Gross margin (%)
- Operating margin (%)

Results are sorted chronologically and alphabetically by country.

🚀 How to Run the Query

- Connect to the AdventureWorks 2017 database
- Open the SQL file in SQL Server Management Studio (SSMS)
- Execute the script
- Review the final result set

🧪 Assumptions & Business Rules

- Product costs are matched historically to the sale date
- Costs without an EndDate are treated as currently valid
- Months without purchase records are included via LEFT JOIN
- Stock is calculated cumulatively per product over time
- Operational cost is calculated as an average manufacturing cost

📚 Project Purpose

This project was created to demonstrate:

- Advanced SQL querying
- Financial and operational modeling
- Inventory analysis
- Business-oriented data transformation
- Clean, maintainable SQL design

👤 Authors

António Ramalho
Filipe Gil
João Garcia
João Monteiro
