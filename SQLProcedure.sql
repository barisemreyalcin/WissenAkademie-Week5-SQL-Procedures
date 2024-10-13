----------------------------------------
-- STORED PROCEDURE - SAKLI YORDAMLAR --
----------------------------------------
/*
CREATE PROCEDURE ProcedureName
	@parameter1 dataType = 0, -- optional value
	@parameter2 dataType

AS
QueryContent
*/
-- Parameter almak zorunda deðil

SELECT * FROM Categories
SELECT * FROM Products
SELECT * FROM [Order Details]
-- Kategorideki ürün adedini bulan sorgu:
SELECT C.CategoryName, SUM(OD.Quantity) TotalProductCount
FROM [Order Details] OD INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories C ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName
ORDER BY TotalProductCount

CREATE PROCEDURE SP_Category_ProductCount
AS
SELECT C.CategoryName, SUM(OD.Quantity) TotalProductCount
FROM [Order Details] OD INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories C ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName
ORDER BY TotalProductCount

EXECUTE [dbo].[SP_Category_ProductCount]

-----------
SELECT C.CategoryName, SUM(OD.Quantity) TotalProductCount
FROM [Order Details] OD INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories C ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName
HAVING SUM(OD.Quantity) > 5000 -- Parametre gerekebilir
ORDER BY TotalProductCount

-- with parameter
CREATE PROCEDURE SP_Category_ProductCountWithParameter
@Count int
AS
SELECT C.CategoryName, SUM(OD.Quantity) TotalProductCount
FROM [Order Details] OD INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories C ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryName
HAVING SUM(OD.Quantity) > @Count 
ORDER BY TotalProductCount

--EXECUTE [dbo].[SP_Category_ProductCountWithParameter] 7000
EXECUTE [dbo].[SP_Category_ProductCountWithParameter]
@Count = 7000

-- with 2 parameters
CREATE PROCEDURE SP_Category_ProductCountWithParameters2
@Count int, 
@CategoryName varchar(100)
AS
SELECT C.CategoryName, SUM(OD.Quantity) TotalProductCount
FROM [Order Details] OD INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories C ON C.CategoryID = P.CategoryID
WHERE CategoryName = @CategoryName
GROUP BY C.CategoryName
HAVING SUM(OD.Quantity) > @Count 
ORDER BY TotalProductCount

--EXECUTE [dbo].[SP_Category_ProductCountWithParameters2] 6000, 'Seafood'
EXECUTE [dbo].[SP_Category_ProductCountWithParameters2] 
@Count = 6000, @CategoryName = 'Seafood'

CREATE PROCEDURE SP_Category_ProductCountWithDefaultParameters
@Count int = 5000, 
@CategoryName varchar(100)
AS
SELECT C.CategoryName, SUM(OD.Quantity) TotalProductCount
FROM [Order Details] OD INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories C ON C.CategoryID = P.CategoryID
WHERE CategoryName = @CategoryName
GROUP BY C.CategoryName
HAVING SUM(OD.Quantity) > @Count 
ORDER BY TotalProductCount

EXECUTE [dbo].[SP_Category_ProductCountWithDefaultParameters] 
@CategoryName = 'Condiments'

-- EmployeeID alan ve ismini döndüren:
CREATE PROCEDURE SP_EmployeeInfo
@EmployeeID int,
@EmployeeName varchar(100) OUTPUT -- Döndüreceðimiz deðer için deðiþken
AS
DECLARE @FirstName varchar(50)
DECLARE @LastName varchar(50)
SELECT @FirstName = FirstName, @LastName = LastName
FROM Employees
WHERE EmployeeID = @EmployeeID
SET @EmployeeName = @FirstName + ' ' + @LastName

DECLARE @FullName varchar(100)
EXECUTE [dbo].[SP_EmployeeInfo]
@EmployeeID = 5,
@EmployeeName = @FullName OUTPUT
SELECT @FullName EmployeeName

ALTER PROCEDURE SP_CustomerTotal
@CustomerID varchar(5),
@CustomerTotal money OUTPUT,
@CompanyName varchar(100) OUTPUT
AS
SELECT @CompanyName = C.CompanyName,
@CustomerTotal = SUM(OD.Quantity * OD.UnitPrice * (1 - OD.Discount))
FROM Customers C INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN [Order Details] OD ON O.OrderID = OD.OrderID
WHERE C.CustomerID = @CustomerID
GROUP BY C.CustomerID, C.CompanyName

DECLARE @CusTotal money
DECLARE @Company varchar(100)
EXECUTE [dbo].[SP_CustomerTotal]
@CustomerID = 'ALFKI',
@CustomerTotal = @CusTotal OUTPUT,
@CompanyName = @Company OUTPUT
SELECT  @Company Company, @CusTotal Total

--------------------
-- KARAR YAPILARI --
--------------------
CREATE PROCEDURE SP_ProductInfo
@ProductID int = 0
AS
IF @ProductID <> 0
BEGIN
	SELECT * FROM Products WHERE ProductID = @ProductID
END
ELSE
BEGIN
	SELECT * FROM Products
END

EXECUTE [dbo].[SP_ProductInfo] 
@ProductID = 0 -- Deðer vermememizle ayný sonuç

CREATE PROCEDURE SP_ProductInfo2
@ProductID int = 0
AS
SELECT * FROM Products
WHERE CASE
		WHEN @ProductID = 0 THEN @ProductID ELSE ProductID END = @ProductID 

--0 => @ProductId = 0 => SELECT * FROM Products WHERE 0 = 0
--15 => ProductId = 15 => SELECT * FROM Products WHERE ProductID = 15

EXECUTE [dbo].[SP_ProductInfo2] 24 -- 0 veya deðer vermezsek hepsini döner
EXEC('[dbo].[SP_ProductInfo2] 8')