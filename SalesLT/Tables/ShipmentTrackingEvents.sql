CREATE TABLE [SalesLT].[ShipmentTrackingEvents] (
    [EventID]      BIGINT        NULL,
    [SalesOrderID] INT           NOT NULL,
    [EventDate]    DATETIME      NOT NULL,
    [Location]     VARCHAR (100) NULL,
    [Status]       VARCHAR (50)  NULL,
    [Notes]        VARCHAR (200) NULL
);


GO
CREATE NONCLUSTERED INDEX [nix_shipmenttracking_salesorder]
    ON [SalesLT].[ShipmentTrackingEvents]([SalesOrderID] ASC, [EventDate] ASC)
    INCLUDE([Status], [Location]);


GO
CREATE NONCLUSTERED INDEX [ix_shipmenttracking_salesorderid]
    ON [SalesLT].[ShipmentTrackingEvents]([SalesOrderID] ASC, [EventDate] ASC);

