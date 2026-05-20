-- =============================================
-- Bartosz
-- Walasek
-- 240013
-- =============================================


IF OBJECT_ID('SalesLT.Vendor', 'U') IS NOT NULL
    DROP TABLE SalesLT.Vendor;
GO
CREATE TABLE SalesLT.Vendor (
    VendorID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    AccountNumber NVARCHAR(20) NOT NULL,
    CreditRating TINYINT NOT NULL, -- 1 do 5
    ActiveFlag BIT DEFAULT 1
);

IF OBJECT_ID('SalesLT.ProductVendor', 'U') IS NOT NULL
    DROP TABLE SalesLT.ProductVendor;
GO
CREATE TABLE SalesLT.ProductVendor (
    ProductID INT NOT NULL,
    VendorID INT NOT NULL,
    StandardPrice MONEY NOT NULL,
    AverageLeadTime INT NOT NULL, -- Czas dostawy w dniach
);

IF OBJECT_ID('SalesLT.ProductBOM', 'U') IS NOT NULL
    DROP TABLE SalesLT.ProductBOM;
GO
CREATE TABLE SalesLT.ProductBOM (
    BOMID INT,
    ParentProductID INT NOT NULL,    -- Rower
    ComponentProductID INT NOT NULL, -- Rama
    Quantity DECIMAL(18,2) DEFAULT 1.0,
    InstructionStep INT,             -- Kolejno?? monta?u
    CONSTRAINT FK_BOM_Parent FOREIGN KEY (ParentProductID) REFERENCES SalesLT.Product(ProductID),
    CONSTRAINT FK_BOM_Component FOREIGN KEY (ComponentProductID) REFERENCES SalesLT.Product(ProductID)
);
GO


IF OBJECT_ID('SalesLT.VendorPriceHistory', 'U') IS NOT NULL
    DROP TABLE SalesLT.VendorPriceHistory;
GO
CREATE TABLE SalesLT.VendorPriceHistory (
    QuoteID BIGINT,
    VendorID INT NOT NULL,
    ProductID INT NOT NULL,
    Price MONEY NOT NULL,
    QuoteDate DATETIME NOT NULL
);
GO



IF OBJECT_ID('SalesLT.ShipmentTrackingEvents', 'U') IS NOT NULL
    DROP TABLE SalesLT.ShipmentTrackingEvents;
GO
CREATE TABLE SalesLT.ShipmentTrackingEvents (
    EventID BIGINT,
    SalesOrderID INT NOT NULL, -- FK do istniej?cych zamówie?
    EventDate DATETIME NOT NULL,
    Location VARCHAR(100),
    Status VARCHAR(50),
    Notes VARCHAR(200)
);
GO


INSERT INTO SalesLT.Vendor (Name, AccountNumber, CreditRating, ActiveFlag)
SELECT TOP 500000
    'Dostawca ' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS NVARCHAR(10)),
    'ACT' + CAST(10000 + ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS NVARCHAR(10)),
    (ABS(CHECKSUM(NEWID())) % 5) + 1,
    1
FROM sys.all_objects a CROSS JOIN sys.all_objects b;
GO


INSERT INTO SalesLT.ProductVendor (ProductID, VendorID, StandardPrice, AverageLeadTime)
SELECT 
    p.ProductID,
    v.VendorID,
    p.ListPrice * RAND(10000) * 0.1, -- Cena zakupu to 60% ceny sprzeda?y
    (ABS(CHECKSUM(NEWID())) % 15) + 1 -- Czas dostawy 1-15 dni
FROM SalesLT.Product p
CROSS APPLY (
    -- Wybierz 10 losowych dostawców dla ka?dego produktu
    SELECT TOP 15 VendorID 
    FROM SalesLT.Vendor 
    ORDER BY NEWID()
) v;
GO


-- Generowanie milionów rekordów
INSERT INTO SalesLT.VendorPriceHistory (VendorID, ProductID, Price, QuoteDate)
SELECT 
    pv.VendorID,
    pv.ProductID,
    pv.StandardPrice * (1 + (CAST(ABS(CHECKSUM(NEWID())) % 20 AS FLOAT) - 10) / 100), -- Fluktuacja ceny +/- 10%
    DATEADD(DAY, -n.Number, GETDATE()) -- Cena z ka?dego z ostatnich 'N' dni
FROM SalesLT.ProductVendor pv
CROSS JOIN (
    SELECT TOP 1000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Number
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
) n;
GO

INSERT INTO SalesLT.ProductBOM (ParentProductID, ComponentProductID, Quantity, InstructionStep)
SELECT 
    p_parent.ProductID,
    p_child.ProductID,
    1,
    1
FROM SalesLT.Product p_parent
CROSS JOIN SalesLT.Product p_child
WHERE p_parent.Name LIKE '%Bike%' 
  AND (p_child.Name LIKE '%Frame%' OR p_child.Name LIKE '%Wheel%')
  AND p_parent.ProductID <> p_child.ProductID;
GO




INSERT INTO SalesLT.ShipmentTrackingEvents (SalesOrderID, EventDate, Location, Status, Notes)
SELECT 
    soh.SalesOrderID,
    -- Data zdarzenia przesuni?ta wzgl?dem daty zamówienia
    DATEADD(HOUR, x.HoursOffset, soh.OrderDate),
    -- Losowa lokalizacja z listy
    x.Location,
    -- Status
    x.Status,
    -- Dodatkowa notatka
    x.Note
FROM SalesLT.SalesOrderHeader soh
CROSS JOIN (
    -- Symulujemy 5 etapów podró?y dla KA?DEGO zamówienia
    SELECT 2 AS HoursOffset, 'Magazyn Centralny' AS Location, 'Picked' AS Status, 'Skompletowano' AS Note UNION ALL
    SELECT 6, 'Magazyn Centralny', 'Shipped', 'Wydano kurierowi' UNION ALL
    SELECT 18, 'Sortownia Regionalna Wawa', 'Arrived', 'Skanowanie w sortowni' UNION ALL
    SELECT 24, 'Sortownia Regionalna Wawa', 'Departed', 'Wyjazd z sortowni' UNION ALL
    SELECT 30, 'Lokalny Oddzia?', 'OutForDelivery', 'Wydano do dor?czenia' UNION ALL
    SELECT 32, 'Adres Klienta', 'Delivered', 'Pozostawiono pod drzwiami'
) AS x

-- =============================================
-- Zadanie 1
-- =============================================

create nonclustered index nix_vendor_name --Poniewaz czesto wyszukujemy po nazwie i przyspieszy nam to wyszukiwanie
on saleslt.Vendor(name);
GO

create nonclustered index nix_productvendor_productID -- Aby ulatwic wyszukiwanie dostawcow dla jakiegos (danego) produktu
on saleslt.productvendor (productid);
GO

create nonclustered index nix_productvendor_vendorID -- Aby ulatwic wyszukiwanie produktu dla jakiegos (danego) dostawcy
on saleslt.productvendor (vendorID);
GO

create nonclustered index nix_productvendor_full -- Eliminuje operacje lookup
on saleslt.ProductVendor (productID, vendorID)
INCLUDE (StandardPrice, AverageLeadTime);
GO

create nonclustered index nix_vendorpricehistory_product -- jakbysmy chcieli sprawdzic historie cen produktow w jakims danym czasie
on saleslt.vendorpricehistory (productID, quoteDate)
INCLUDE (price, vendorID);
GO

create nonclustered index nix_shipmenttracking_salesorder -- przyspiesza pobieranie historii statusow zamowien oraz wspiera sortowanie chronologiczne
on saleslt.shipmenttrackingevents (SalesOrderID, EventDate)
INCLUDE (Status, Location);
GO

create nonclustered index nix_productbom_parent -- przyspiesza pobieranie komponentow produktu
on saleslt.productbom (ParentProductID);
GO


create nonclustered index nix_productbom_component -- przyspiesza wyszukiwanie uzycia komponentu w produkcie
on saleslt.productbom (ComponentProductID);
GO
-- =============================================
-- Zadanie 2
-- =============================================

create nonclustered index nix_vendor_acrive_name_account
on saleslt.vendor (name, accountnumber)
include (activeflag)
where activeflag= 1;
GO

-- =============================================
-- Zadanie 3
-- =============================================

--1 indeks wybiera po wysokiej cenie kredytowej, dzieki temu mozemy wybrac zaufanych partnerow biznesowych szybciej
create nonclustered index nix_vendor_highcredit
on saleslt.vendor (name,accountnumber)
where creditrating >=4;
GO

select name, accountnumber, creditrating
from saleslt.vendor
where creditrating >= 4;
GO
--
--2 znajduje dostawcow dla produktu, np najtanszego dostawce
create nonclustered index nix_productvendor_product_covering
on saleslt.productvendor (productid, standardprice)
include (vendorid, averageleadtime);
GO

select productid, vendorid, standardprice, averageleadtime
from saleslt.productvendor
where productid = 863
order by standardprice;
GO
--
--3 szybsze wyszukiwanie statusow zamowien
create nonclustered index nix_shipmenttracking_salesorderid
on saleslt.shipmenttrackingevents (salesorderid, eventdate);

select salesorderid, eventdate, status, location
from saleslt.ShipmentTrackingEvents
where SalesOrderID < 80000
order by eventdate;
GO
-- =============================================
-- Zadanie 4
-- =============================================

alter index nix_vendorpricehistory_product on saleslt.vendorpricehistory
rebuild with (fillfactor = 75);
GO
-- =============================================
-- Zadanie 5
-- =============================================
IF OBJECT_ID('SalesLT.gamepurchase', 'U') IS NOT NULL
    DROP TABLE SalesLT.gamepurchase;

create table saleslt.gamepurchase (
purchaseid int identity(1,1),
productid int not null,
customerid int not null,
price money not null,
purchasedate datetime not null default getdate(),
isfavorite bit not null default 0.
constraint pk_gamepurchase primary key clustered (purchaseid),
constraint fk_gamepurchase_product foreign key (productid) references saleslt.product(productid),
constraint fk_gamepurchase_customer foreign key (customerid) references saleslt.customer(customerid));


create nonclustered index nix_gamepurchase_playergame
on saleslt.gamepurchase (customerid, productid);

create nonclustered index nix_gamepurchase_player_covering
on saleslt.gamepurchase (customerid, purchasedate)
include (productid, price);

create nonclustered index nix_gamepurchase_favorites
on saleslt.gamepurchase (customerid, productid)
where isfavorite = 1;
