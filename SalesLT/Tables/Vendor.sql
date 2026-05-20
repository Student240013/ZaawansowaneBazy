CREATE TABLE [SalesLT].[Vendor] (
    [VendorID]      INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (100) NOT NULL,
    [AccountNumber] NVARCHAR (20)  NOT NULL,
    [CreditRating]  TINYINT        NOT NULL,
    [ActiveFlag]    BIT            DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([VendorID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [nix_vendor_name]
    ON [SalesLT].[Vendor]([Name] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_vendor_acrive_name_account]
    ON [SalesLT].[Vendor]([Name] ASC, [AccountNumber] ASC)
    INCLUDE([ActiveFlag]) WHERE ([activeflag]=(1));


GO
CREATE NONCLUSTERED INDEX [ix_vendor_highcredit]
    ON [SalesLT].[Vendor]([Name] ASC, [AccountNumber] ASC) WHERE ([creditrating]>=(4));

