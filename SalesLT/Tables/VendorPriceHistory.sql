CREATE TABLE [SalesLT].[VendorPriceHistory] (
    [QuoteID]   BIGINT   NULL,
    [VendorID]  INT      NOT NULL,
    [ProductID] INT      NOT NULL,
    [Price]     MONEY    NOT NULL,
    [QuoteDate] DATETIME NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [nix_vendorpricehistory_product]
    ON [SalesLT].[VendorPriceHistory]([ProductID] ASC, [QuoteDate] ASC)
    INCLUDE([Price], [VendorID]) WITH (FILLFACTOR = 75);

