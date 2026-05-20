 -- =============================================
-- Bartosz
-- Walasek
-- 240013
-- =============================================

-- =============================================
-- Zadanie 1
-- =============================================

-- zapytanie pobiera dane z tabel sprzedazy, sql odczytuje najpierw tabele salesorderheader, a potem laczy je z salesorderdetail czyli takie tabele jak
tabele zamowien, produktow, adresow i opisow co powiela wiersze. Nastepnie zapytanie where ogranicza wyniki, a na koncu te wyniki sa sortowane wedlug daty wysylki(malejaco) i miasta (alfabetycznie)
SELECT 
        soh.SalesOrderID,
        soh.ShipDate,
        a.City,
        a.StateProvince,
        p.Name AS ProductName,
        pd.Description,
        sod.OrderQty,
        sod.LineTotal
    FROM 
        SalesLT.SalesOrderHeader soh
    JOIN 
        SalesLT.Address a ON soh.ShipToAddressID = a.AddressID
    JOIN 
        SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN 
        SalesLT.Product p ON sod.ProductID = p.ProductID
    JOIN 
        SalesLT.ProductModelProductDescription pmpd ON p.ProductModelID = pmpd.ProductModelID
    JOIN 
        SalesLT.ProductDescription pd ON pmpd.ProductDescriptionID = pd.ProductDescriptionID
    WHERE 
        a.City IN ('London', 'Cambridge', 'Oxford')
        AND pmpd.Culture = 'en'
        AND soh.ShipDate IS NOT NULL
    ORDER BY 
        soh.ShipDate DESC, a.City ASC;

-- =============================================
-- Zadanie 2
-- =============================================

--Zapytanie na poczatku uzywalo index scan i has match co bylo dosyc wolne, jednak po dodaniu indeksow uzywany jest index seek oraz nested lopp co poprawilo wydajnosc

  SELECT 
        p.Name AS ProductName,
        pc.Name AS CategoryName,
        SUM(sod.LineTotal) AS TotalRevenue,
        AVG(p.StandardCost) AS AvgCost,
        (SUM(sod.LineTotal) - SUM(sod.UnitPrice * sod.OrderQty)) AS ProfitMargin
    FROM 
        SalesLT.Product p
    JOIN 
        SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    LEFT JOIN 
        SalesLT.SalesOrderDetail sod ON p.ProductID = sod.ProductID
    WHERE 
        p.ProductNumber = '705' 
        OR p.ProductNumber LIKE 'B%'
        AND ISNULL(sod.UnitPrice, 0) > 0
    GROUP BY 
        p.Name, pc.Name
    ORDER BY 
        TotalRevenue DESC;
        GO

create nonclustered index nix_product_productnumber
on saleslt.product (productnumber)
include (productid, name, standardcost, productcategoryid);

create nonclustered index nix_sod_productid_unitprice
on saleslt.salesorderdetail (productid, unitprice)
include (linetotal, orderqty);

create nonclustered index nix_productcategory_id
on saleslt.productcategory (productcategoryid)
include (name);
GO


-- =============================================
-- Zadanie 3
-- =============================================

-- =============================================
-- Zadanie 4
-- =============================================

update statistics saleslt.product;

-- Odswiezylem te statystyki, aby optymalizator mogl tworzyc lepsze plany wykonania majac aktualne dane

