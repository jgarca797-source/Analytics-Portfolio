WITH vendas1 AS (
    SELECT 
        h.OrderDate,
        h.SalesOrderID,
        YEAR(h.OrderDate) AS Ano,
        MONTH(h.OrderDate) AS Mes,
        d.ProductID,
        d.OrderQty,
        d.LineTotal,
        d.LineTotal * 1.0 / NULLIF(d.OrderQty, 0) AS PUnit,
        h.TerritoryID
    FROM Sales.SalesOrderHeader h
    JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID
),
vendas2 AS (
    SELECT 
        v1.*,
        pch.StandardCost
    FROM vendas1 v1
    JOIN Production.ProductCostHistory pch 
        ON v1.ProductID = pch.ProductID
       AND v1.OrderDate >= pch.StartDate 
       AND (v1.OrderDate <= pch.EndDate OR pch.EndDate IS NULL)
),
vendas_agg AS (
    SELECT 
        Ano,
        Mes,
        TerritoryID,
        ProductID,
        SUM(OrderQty) AS QtdeVendida,
        SUM(LineTotal) AS ReceitaMensalBruta,
        SUM(OrderQty * StandardCost) AS CustoMensalBruto,
        SUM(LineTotal - (OrderQty * StandardCost)) AS LucroBrutoMensal
    FROM vendas2
    GROUP BY Ano, Mes, TerritoryID, ProductID
),
compras AS (
    SELECT 
        YEAR(poh.OrderDate) AS Ano,
        MONTH(poh.OrderDate) AS Mes,
        pod.ProductID,
        SUM(pod.OrderQty) AS QtdeComprada
    FROM Purchasing.PurchaseOrderHeader poh
    JOIN Purchasing.PurchaseOrderDetail pod ON poh.PurchaseOrderID = pod.PurchaseOrderID
    GROUP BY YEAR(poh.OrderDate), MONTH(poh.OrderDate), pod.ProductID
),
stock_calc AS (
    SELECT 
        v.ProductID,
        v.Ano,
        v.Mes,
        SUM(ISNULL(c.QtdeComprada, 0)) OVER (PARTITION BY v.ProductID ORDER BY v.Ano, v.Mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        -
        SUM(v.QtdeVendida) OVER (PARTITION BY v.ProductID ORDER BY v.Ano, v.Mes ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS Stock
    FROM vendas_agg v
    LEFT JOIN compras c ON v.ProductID = c.ProductID AND v.Ano = c.Ano AND v.Mes = c.Mes
),
custo_operacional AS (
    SELECT 
        ProductID,
        AVG(ActualCost) AS CustoMedioOperacional
    FROM Production.WorkOrderRouting
    GROUP BY ProductID
),
regioes AS (
    SELECT 
        TerritoryID,
        Name AS Pais
    FROM Sales.SalesTerritory
),
resumo_por_pais AS (
    SELECT 
        v.Ano,
		v.Mes,
        r.Pais,
        SUM(v.QtdeVendida) AS QtdeVendida,
        SUM(ISNULL(c.QtdeComprada, 0)) AS QtdeComprada,
        SUM(ISNULL(s.Stock, 0)) AS Stock,
        SUM(v.CustoMensalBruto) AS CustoMensalBruto,
        SUM(v.ReceitaMensalBruta) AS ReceitaMensalBruta,
        SUM(v.LucroBrutoMensal) AS LucroBrutoMensal,
        AVG(ISNULL(co.CustoMedioOperacional, 0)) AS CustoMedioOperacional,
        SUM(v.LucroBrutoMensal - ISNULL(co.CustoMedioOperacional, 0)) AS LucroOperacional
    FROM vendas_agg v
    LEFT JOIN compras c ON v.ProductID = c.ProductID AND v.Ano = c.Ano AND v.Mes = c.Mes
    LEFT JOIN stock_calc s ON v.ProductID = s.ProductID AND v.Ano = s.Ano AND v.Mes = s.Mes
    LEFT JOIN custo_operacional co ON v.ProductID = co.ProductID
    LEFT JOIN regioes r ON v.TerritoryID = r.TerritoryID
    GROUP BY v.Ano, v.Mes, r.Pais
)
SELECT 
    Ano,
	Mes,
    Pais,
    QtdeVendida,
    QtdeComprada,
    Stock,
    CustoMensalBruto,
    ReceitaMensalBruta,
    LucroBrutoMensal,
    CustoMedioOperacional,
    LucroOperacional,
    ROUND((LucroBrutoMensal * 1.0 / NULLIF(ReceitaMensalBruta, 0)) * 100, 2) AS MargemBrutaPercent,
    ROUND((LucroOperacional * 1.0 / NULLIF(ReceitaMensalBruta, 0)) * 100, 2) AS MargemOperacionalPercent
FROM resumo_por_pais
ORDER BY Ano, Mes, Pais;
