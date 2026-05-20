CREATE TABLE [SalesLT].[ProductVendor] (
    [ProductID]       INT   NOT NULL,
    [VendorID]        INT   NOT NULL,
    [StandardPrice]   MONEY NOT NULL,
    [AverageLeadTime] INT   NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [nix_productvendor_productID]
    ON [SalesLT].[ProductVendor]([ProductID] ASC);


GO
CREATE NONCLUSTERED INDEX [nix_productvendor_vendorID]
    ON [SalesLT].[ProductVendor]([VendorID] ASC);


GO
CREATE NONCLUSTERED INDEX [nix_productvendor_full]
    ON [SalesLT].[ProductVendor]([ProductID] ASC, [VendorID] ASC)
    INCLUDE([StandardPrice], [AverageLeadTime]);


GO
CREATE NONCLUSTERED INDEX [ix_productvendor_product_covering]
    ON [SalesLT].[ProductVendor]([ProductID] ASC, [StandardPrice] ASC)
    INCLUDE([VendorID], [AverageLeadTime]);

