CREATE DATABASE END_TO_END

SELECT TOP 1* FROM Customer
SELECT TOP 1* FROM Orders
SELECT TOP 1* FROM OrderItem
SELECT TOP 1* FROM Product
SELECT TOP 1* FROM Supplier

--1. List all customers

SELECT Id, CONCAT(' ',FirstName,LastName) AS CUSTOMER_NAME from Customer

--2. List the first name, last name, and city of all customers

SELECT FirstName, LastName, City from Customer

--3. List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" because filtering value is case sensitive in Redshift.

SELECT Id, CONCAT(' ',FirstName, LastName) AS NAME FROM 
Customer WHERE Country='Sweden'

--4. Create a copy of Supplier table. Update the city to Sydney for supplier starting with letter P.

SELECT * INTO Supplier_copy FROM Supplier
SELECT * FROM Supplier_copy

UPDATE Supplier_copy
SET City= 'Sydney'
WHERE CompanyName LIKE 'P%'


--5. Create a copy of Products table and Delete all products with unit price higher than $50.

SELECT * INTO PRODUCT_COPY FROM Product
SELECT * FROM PRODUCT_COPY

DELETE FROM PRODUCT_COPY
WHERE UnitPrice>50


--6. List the number of customers in each country

SELECT Country, COUNT(Id) AS CUST_CNT FROM Customer AS A
GROUP BY Country


--7. List the number of customers in each country sorted high to low

SELECT Country, COUNT(Id) AS CUST_CNT FROM Customer AS A
GROUP BY Country 
ORDER BY CUST_CNT DESC

--8. List the total amount for items ordered by each customer

SELECT Id, SUM(TotalAmount) AS TOTAL_AMOUNT FROM Orders
GROUP BY Id

--9. List the number of customers in each country. Only include countries with more than 10 customers.

SELECT Country, COUNT(Id) as CUST_CNT FROM Customer
GROUP BY Country
HAVING COUNT(Id)>10

--10. List the number of customers in each country, except the USA, sorted high to low. Only include countries with 9 
--or more customers.

SELECT Country, COUNT(Id) as CUST_CNT FROM Customer
WHERE Country != 'USA'
GROUP BY Country
HAVING COUNT(Id) >9
ORDER BY CUST_CNT

--11. List all customers whose first name or last name contains "ill". 

SELECT * FROM Customer WHERE FirstName LIKE '%ill%' OR LastName LIKE '%ill%'

--12. List all customers whose average of their total order amount is between $1000 and $1200.Limit your output to 5 results.

SELECT * FROM Orders

SELECT TOP 5 CustomerId,AVG(TotalAmount) AVERAGE_AMT FROM Orders
GROUP BY CustomerId
HAVING AVG(TotalAmount) BETWEEN 1000 AND 1200
ORDER BY AVERAGE_AMT DESC


--13. List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from A-Z, and then by company name 
--in reverse order.

SELECT * FROM Supplier
WHERE Country IN('USA','JAPAN','Germany')
ORDER BY Country, CompanyName DESC


--14. Show all orders, sorted by total amount (the largest amount first), within each year.

SELECT *,YEAR(OrderDate) AS YEAR_ FROM Orders
ORDER BY YEAR_, TotalAmount DESC


--15. Products with UnitPrice greater than 50 are not selling despite promotions. You are asked to discontinue
--products over $25. Write a query to relfelct this. Do this in the copy of the Product table. 
--DO NOT perform the update operation in the Product table.

SELECT * FROM PRODUCT_COPY

UPDATE PRODUCT_COPY
SET IsDiscontinued= 1
WHERE UnitPrice>25


--16. List top 10 most expensive products

SELECT TOP 10 ProductName,UnitPrice
FROM Product
ORDER BY UnitPrice DESC


--17. Get all but the 10 most expensive products sorted by price

SELECT * FROM Product AS A
WHERE A.Id NOT IN(
					SELECT TOP 10 Id FROM Product
					ORDER BY UnitPrice DESC)
--OR--

SELECT * FROM (
				SELECT *,DENSE_RANK() 
				OVER(ORDER BY UnitPrice DESC) AS RANK_ 
				FROM Product AS A) AS T
WHERE T.RANK_>10

--18. Get the 10th to 15th most expensive products sorted by price

SELECT * FROM (
				SELECT *,DENSE_RANK() 
				OVER(ORDER BY UnitPrice DESC) AS RANK_ 
				FROM Product AS A) AS T
WHERE T.RANK_>10 AND T.RANK_<16


--19. Write a query to get the number of supplier countries. Do not count duplicate values.

SELECT COUNT(DISTINCT Country) AS SUPPLIER_COUNTRY_CNT FROM Supplier

--20. Find the total sales cost in each month of the year 2013.

SELECT TOP 1* FROM Orders AS A
SELECT TOP 1* FROM OrderItem AS B

SELECT YEAR(OrderDate) AS YEAR_, MONTH(OrderDate) AS MONTH_, SUM(B.UnitPrice * B.Quantity) AS UNIT_PRICE FROM Orders AS A
JOIN 
OrderItem AS B
ON A.Id= B.OrderId
WHERE YEAR(OrderDate)= 2013
GROUP BY YEAR(OrderDate), MONTH(OrderDate)

--21. List all products with names that start with 'Ca'.

SELECT ProductName
FROM Product 
WHERE ProductName LIKE 'Ca%' 

--22. List all products that start with 'Cha' or 'Chan' and have one more character.

SELECT ProductName FROM Product
WHERE ProductName LIKE 'Cha_' OR PRODUCTName LIKE 'Chan_'

--23. Your manager notices there are some suppliers without fax numbers. He seeks your help to get a list of suppliers 
--with remark as "No fax number" for suppliers who do not have fax numbers (fax numbers might be null or blank).
--Also, Fax number should be displayed for customer with fax numbers.




--24. List all orders, their orderDates with product names, quantities, and prices.

SELECT TOP 1* FROM Customer
SELECT TOP 1* FROM Orders
SELECT TOP 1* FROM OrderItem
SELECT TOP 1* FROM Product
SELECT TOP 1* FROM Supplier

SELECT A.Id,A.OrderDate,c.ProductName,B.Quantity, B.UnitPrice FROM Orders AS A
JOIN 
OrderItem AS B
ON A.Id= B.OrderId
JOIN Product AS C
ON B.ProductId= C.Id



--25. List all customers who have not placed any Orders.

SELECT * FROM Customer AS A
LEFT JOIN 
Orders AS B
ON A.Id= B.CustomerId
WHERE B.Id IS NULL


--26. List suppliers that have no customers in their country, and customers that have no suppliers
--in their country, and customers and suppliers that are from the same country. 

SELECT TOP 1* FROM Customer
SELECT TOP 1* FROM Supplier

(SELECT A.FirstName,A.LastName, A.Country,B.Country,B.CompanyName FROM CUSTOMER AS A
RIGHT JOIN Supplier AS B
ON A.Country= B.Country
WHERE A.FirstName IS NULL)
UNION ALL
(SELECT A.FirstName,A.LastName, A.Country,B.Country,B.CompanyName FROM Customer AS A
LEFT JOIN Supplier AS B
ON A. Country= B.Country
WHERE B.CompanyName IS NULL)
UNION ALL
(SELECT A.FirstName,A.LastName, A.Country,B.Country,B.CompanyName FROM Customer AS A
INNER JOIN Supplier AS B
ON A. Country= B.Country
WHERE A.Country=B.Country)



--27. Match customers that are from the same city and country. That is you are asked to give a list

 customers that are from same country and city. Display firstname, lastname, city and
coutntry of such customers.

A.FirstName AS FN1, A.LastName AS LN1,B.FirstName AS FN2, B.LastName AS LN2, A.City,A. Country

SELECT A.Id, B.Id,A.FirstName AS FN1, A.LastName AS LN1,B.FirstName AS FN2, B.LastName AS LN2, A.City,A. Country
FROM Customer AS A
INNER JOIN 
Customer AS B
ON A.Country= B.Country
AND A.City= B.City
WHERE A.Id< B.Id



--28. List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if he is a supplier and 'Customer' 
--if he is a customer accordingly. Also, do not display firstname and lastname as two fields; 
--Display Full name of customer or supplier. 

SELECT TOP 1* FROM Customer
SELECT TOP 1* FROM Supplier

SELECT ContactName, City, Country, Phone FROM Supplier 
UNION ALL 
SELECT CONCAT(' ',FirstName,LastName) AS ContactName,City, Country, Phone FROM Customer

SELECT*,
CASE WHEN ContactName IN( SELECT ContactName FROM Supplier)
THEN 'SUPPLIER' ELSE 'CUSTOMER'
END AS [TYPE]
FROM(
			SELECT ContactName, City, Country, Phone FROM Supplier 
			UNION ALL 
			SELECT CONCAT_WS(' ',FirstName,LastName) AS ContactName,City, Country, Phone FROM Customer) AS T

--29. Create a copy of orders table. In this copy table, now add a column city of type varchar (40).
--Update this city column using the city info in customers table.SELECT * INTO ORDERS_COPY FROM OrdersSELECT * FROM ORDERS_COPYALTER TABLE ORDERS_COPY ADD City VARCHAR(40)UPDATE ORDERS_COPYSET City= (SELECT CITY FROM Customer			WHERE ORDERS_COPY.Id= Customer.Id)SELECT * FROM ORDERS_COPY--30. Suppose you would like to see the last OrderID and the OrderDate for this last order that was shipped to 'Paris'. 
--Along with that information, say you would also like to see the OrderDate for the last order shipped regardless of 
--the Shipping City. In addition to this, you would also like to calculate the difference in days between these two 
--OrderDates that you get. Write a single query which performs this.
--(Hint: make use of max (columnname) function to get the last order date and the output is a single row output.)

SELECT TOP 2* FROM Customer
SELECT TOP 2* FROM ORDERS

SELECT MAX(A.Id) AS ID,MAX(A.OrderDate) AS LASTPARISORDER,(SELECT MAX(OrderDate) FROM ORDERS) AS LASTDATE,DATEDIFF(DAY,MAX(A.OrderDate),(SELECT MAX(OrderDate) FROM ORDERS)) AS DAY_DIFFFROM Orders AS AINNER JOIN Customer AS BON A.CustomerId = B.IdWHERE B.City = 'PARIS'

--31. Find those customer countries who do not have suppliers. This might help you provide better delivery time --to customers by adding suppliers to these countires. Use SubQueries.
SELECT DISTINCT A.Country FROM Customer AS A
WHERE A.Country NOT IN (SELECT DISTINCT  B.Country FROM Supplier AS B)

--32. Suppose a company would like to do some targeted marketing where it would
--contact customers in the country with the fewest number of orders. 
--It is hoped that this targeted marketing will increase the overall sales 
--in the targeted country. You are asked to write a query to get all details 
--of such customers from top 5 countries with fewest numbers of orders. Use Subqueries.SELECT A.CustomerId, COUNT(A.Id) AS CNT_ORDERSFROM Orders AS AINNER JOIN Customer AS BON A.CustomerId = B.IdWHERE B.Country IN (SELECT TOP 5 B.Country FROM Orders AS A                        INNER JOIN Customer AS B						ON A.CustomerId = B.Id						GROUP BY B.Country						ORDER BY SUM(A.TotalAmount) DESC)GROUP BY A.CustomerIdHAVING COUNT(A.Id) <=7ORDER BY CNT_ORDERS --33.. Let's say you want report of all distinct "OrderIDs" where the customer 
--did not purchase more than 10% of the average quantity sold for a given product.
--This way you could review these orders, and possibly contact the customers, 
--to help determine if there was a reason for the low quantity order.
--Write a query to report such orderIDs.

SELECT DISTINCT T.ORDER_ID FROM(
          SELECT A.Id AS ORDER_ID,C.Id AS PROD_ID ,
          SUM(B.Quantity) AS TOTAL_QTY
          FROM Orders AS A
          INNER JOIN OrderItem AS B
          ON A.Id = B.OrderId
          INNER JOIN Product AS C
          ON B.ProductId = C.Id
          GROUP BY A.Id,C.Id
		  ) AS T
INNER JOIN (
            SELECT C.Id AS PROD_ID, ROUND(AVG(B.Quantity)*0.1,0) AS PERC_10_AVG_QTY FROM Orders AS A
            INNER JOIN OrderItem AS B
            ON A.Id = B.OrderId
            INNER JOIN Product AS C
            ON B.ProductId = C.Id
            GROUP BY C.Id
			) AS T1
ON T.PROD_ID = T1.PROD_ID
WHERE T.TOTAL_QTY < T1.PERC_10_AVG_QTY



