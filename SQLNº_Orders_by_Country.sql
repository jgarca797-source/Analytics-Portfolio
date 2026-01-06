SELECT 
    st.Name AS Pais,
    COUNT(DISTINCT h.SalesOrderID) AS NumeroPedidos
FROM Sales.SalesOrderHeader h
JOIN Sales.SalesTerritory st ON h.TerritoryID = st.TerritoryID
GROUP BY st.Name
ORDER BY NumeroPedidos desc
