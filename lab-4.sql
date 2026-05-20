-- =============================================
-- Bartosz
-- Walasek
-- 240013
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================


Declare @litera char (1);
Declare @cyfra int;

set @litera = 'B';
set @cyfra = '3';

SELECT CustomerID, FirstName, LastName
FROM SalesLT.Customer
where LastName like @litera + '%' and CustomerID % 10 = @cyfra;

GO

-- =============================================
-- Zadanie 2
-- =============================================

Declare @produkty TABLE
(
ProductID int,
Name nvarchar(50),
ListPrice money
);

Insert into @produkty (ProductID, Name, ListPrice)
select ProductID, Name, ListPrice
From SalesLT.Product
where Name like '%B%';

Select *
from @produkty;

GO

-- =============================================
-- Zadanie 3
-- =============================================

CREATE TABLE KlienciMiasta
(
CustomerID int,
FirstName nvarchar(50),
LastName nvarchar(50),
City nvarchar(50)
);

Insert into KlienciMiasta (CustomerID, FirstName, LastName, City)
select c.customerID, c.FirstName, c.LastName, a.City
FRom SalesLT.Customer c
inner join SalesLT.CustomerAddress ca on c.CustomerID = ca.CustomerID
inner join SalesLT.Address a on ca.AddressID = a.AddressID
where a.City like 'B%';

Select *
from KlienciMiasta
DROP TABLE KlienciMiasta;

GO

-- =============================================
-- Zadanie 4
-- =============================================

create schema Student_3;
GO

Create table Student_3.ProduktyB
(
ProductID int,
Name nvarchar(100),
Category nvarchar(100),
ListPrice money
);

insert into Student_3.ProduktyB (ProductID, Name, Category, ListPrice)
Select
p.ProductID, p.Name, pc.Name as Category, p.ListPrice
From SalesLT.Product p
inner join SalesLT.ProductCategory pc on p.ProductCategoryID = pc.ProductCategoryID
where pc.Name like '%B%';

Select *
from Student_3.ProduktyB

-- =============================================
-- Zadanie 5
-- =============================================

Declare @podsumowanie table
(
Category nvarchar(100),
SredniaCena money
);

Insert into @podsumowanie (Category, SredniaCena)
select
pc.Name as category,
avg(p.ListPrice) as SredniaCena
from SalesLT.Product p
inner join SalesLT.ProductCategory pc on p.ProductCategoryID = pc.ProductCategoryID
where pc.ProductCategoryID % 10 = 3
Group by pc.Name;

Select *
from @podsumowanie;

GO
-- =============================================
-- Zadanie 6
-- =============================================

alter schema [240013]
transfer SalesLT.Customer;
GO

alter schema [240013]
transfer SalesLT.CustomerAddress;
GO
