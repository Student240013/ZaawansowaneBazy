-- =============================================
-- Bartosz
-- Walasek
-- 240013
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

select *
from saleslt.Customer
where lastname like 'B%';
GO

-- =============================================
-- Zadanie 2
-- =============================================

select firstname, lastname, emailaddress, customerid 
from saleslt.Customer
where customerid like '%3';
GO

-- =============================================
-- Zadanie 3
-- =============================================

select name, listprice, ProductNumber
from saleslt.Product
where name like '%b%'
order by listprice desc;
GO

-- =============================================
-- Zadanie 4
-- =============================================

select avg(listprice) as avgprice
from SalesLT.Product
where ProductCategoryID % 10 = 3;
GO

-- =============================================
-- Zadanie 5
-- =============================================

select distinct City
from saleslt.CustomerAddress ca
join saleslt.Address a on ca.AddressID = a.AddressID
where city like 'B%';
GO

-- =============================================
-- Zadanie 6
-- =============================================

insert into SalesLT.Customer (FirstName, LastName, CompanyName, EmailAddress, PasswordHash, PasswordSalt)
values ('Bartosz', 'Walasek', 'lab3', 'bartosz.walasek@lab3.com', '123', '123'); --wpisalem byle co w PasswordHash oraz PasswordSalt, poniewaz to wymagane pola

select *
from SalesLt.Customer
where EmailAddress = 'bartosz.walasek@lab3.com'
GO

-- =============================================
-- Zadanie 7
-- =============================================

insert into SalesLT.ProductCategory (name)
values ('Special-B'), 
		('Extra-3')
GO

-- =============================================
-- Zadanie 8
-- =============================================

select p.name, p.productnumber, 240013 as OwnerId, pp.name as name2
into productscategories240013
from SalesLT.Product p
join SalesLT.ProductCategory pp on p.ProductCategoryID = pp.ProductCategoryID
where (p.name like 'B%B') or (pp.name like '%B%')
GO

-- =============================================
-- Zadanie 9
-- =============================================

select name2, count(*) as ilosc
from productscategories240013
group by name2;
GO