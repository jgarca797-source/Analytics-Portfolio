Select distinct
	year(h.OrderDate) as Ano,
    st.Name as País,
	Sum(d.orderqty) as TotalOrderQty,
	d.ProductID as Product,
	p.Name as ProductName
from Sales.SalesOrderHeader h
join Sales.SalesTerritory st 
on h.TerritoryID = st.TerritoryID
join sales.salesorderdetail d
on h.salesorderid = d.salesorderid
left join Production.Product p
on d.ProductID = p.ProductID
group by year(h.orderdate), st.Name, d.ProductID, p.Name
Having st.Name = 'Australia'
Order By Ano, TotalOrderQty desc
