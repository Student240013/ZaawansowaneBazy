CREATE TABLE [SalesLT].[gamepurchase] (
    [purchaseid]   INT      IDENTITY (1, 1) NOT NULL,
    [productid]    INT      NOT NULL,
    [customerid]   INT      NOT NULL,
    [price]        MONEY    NOT NULL,
    [purchasedate] DATETIME DEFAULT (getdate()) NOT NULL,
    [isfavorite]   BIT      DEFAULT ((0.0)) NOT NULL,
    CONSTRAINT [pk_gamepurchase] PRIMARY KEY CLUSTERED ([purchaseid] ASC),
    CONSTRAINT [fk_gamepurchase_customer] FOREIGN KEY ([customerid]) REFERENCES [240013].[Customer] ([CustomerID]),
    CONSTRAINT [fk_gamepurchase_product] FOREIGN KEY ([productid]) REFERENCES [SalesLT].[Product] ([ProductID])
);


GO
CREATE NONCLUSTERED INDEX [ix_gamepurchase_playergame]
    ON [SalesLT].[gamepurchase]([customerid] ASC, [productid] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_gamepurchase_player_covering]
    ON [SalesLT].[gamepurchase]([customerid] ASC, [purchasedate] ASC)
    INCLUDE([productid], [price]);


GO
CREATE NONCLUSTERED INDEX [ix_gamepurchase_favorites]
    ON [SalesLT].[gamepurchase]([customerid] ASC, [productid] ASC) WHERE ([isfavorite]=(1));

