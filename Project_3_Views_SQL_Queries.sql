---Create Views----

---1) Average Order Value (AOV)

CREATE VIEW View_AverageOrderValue AS
SELECT
    P.ProductID,
    P.Name AS ProductName,
    P.Category,
    S.Location AS StoreLocation,
    SUM(OT.Amount) / COUNT(OT.OrderID) AS AverageOrderValue
FROM
    OnlineTransactions OT
JOIN
    Products P ON OT.ProductID = P.ProductID
LEFT JOIN
    InStoreTransactions IST ON OT.CustomerID = IST.CustomerID
LEFT JOIN
    Stores S ON IST.StoreID = S.StoreID
GROUP BY
    P.ProductID, P.Name, P.Category, S.Location;

-----------------------
Select * from View_AverageOrderValue;
---============================================================================
---2) Customer Segmentation based on Spend, Frequency, and Loyalty Tier

CREATE VIEW View_CustomerSegmentation AS
WITH CustomerSpend AS (
    SELECT 
        C.CustomerID,
        C.Name AS CustomerName,
        SUM(COALESCE(OT.Amount, 0) + COALESCE(IST.Amount, 0)) AS TotalSpend,
        COUNT(DISTINCT OT.OrderID) + COUNT(DISTINCT IST.TransactionID) AS PurchaseFrequency,
        LA.TierLevel
    FROM
        Customers C
    LEFT JOIN
        OnlineTransactions OT ON C.CustomerID = OT.CustomerID
    LEFT JOIN
        InStoreTransactions IST ON C.CustomerID = IST.CustomerID
    LEFT JOIN
        LoyaltyAccounts LA ON C.CustomerID = LA.CustomerID
    GROUP BY
        C.CustomerID, C.Name, LA.TierLevel
),
Percentile AS (
    SELECT 
        PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY TotalSpend) 
        OVER () AS Spend90Percentile
    FROM CustomerSpend
)
SELECT
    CS.CustomerID,
    CS.CustomerName,
    CS.TotalSpend,
    CS.PurchaseFrequency,
    CS.TierLevel,
    CASE
        WHEN CS.TotalSpend >= (SELECT TOP 1 Spend90Percentile FROM Percentile) THEN 'High-Value Customer'
        WHEN CS.PurchaseFrequency = 1 THEN 'One-Time Buyer'
        WHEN CS.TierLevel IN ('Gold', 'Platinum') THEN 'Loyalty Champion'
        ELSE 'Regular Customer'
    END AS CustomerSegment
FROM
    CustomerSpend CS;

-------------------
Select * from View_CustomerSegmentation;

---============================================================================

---3) Peak Days and Times Analysis (Online vs In-Store)

CREATE VIEW View_PeakTimes AS
SELECT
    'Online' AS Channel,
    DATENAME(WEEKDAY, OT.DateTime) AS DayOfWeek,
    DATEPART(HOUR, OT.DateTime) AS HourOfDay,
    COUNT(*) AS TransactionCount
FROM
    OnlineTransactions OT
GROUP BY
    DATENAME(WEEKDAY, OT.DateTime),
    DATEPART(HOUR, OT.DateTime)

UNION ALL

SELECT
    'InStore' AS Channel,
    DATENAME(WEEKDAY, IST.DateTime) AS DayOfWeek,
    DATEPART(HOUR, IST.DateTime) AS HourOfDay,
    COUNT(*) AS TransactionCount
FROM
    InStoreTransactions IST
GROUP BY
    DATENAME(WEEKDAY, IST.DateTime),
    DATEPART(HOUR, IST.DateTime);

-----------------
Select * from View_PeakTimes
---============================================================================

--4) Agent Interactions and Resolution Success Rate

ALTER VIEW View_AgentPerformance AS
SELECT
    A.AgentID,
    A.Name AS AgentName,
    COUNT(CSI.InteractionID) AS TotalInteractions,
    SUM(CASE WHEN CSI.ResolutionStatus = 'Resolved' THEN 1 ELSE 0 END) AS ResolvedInteractions,
    CASE 
        WHEN COUNT(CSI.InteractionID) = 0 THEN NULL
         ELSE CAST((SUM(CASE WHEN CSI.ResolutionStatus = 'Resolved' THEN 1 ELSE 0 END) * 1.0 / COUNT(CSI.InteractionID)) * 100 AS DECIMAL(10,2))
    END AS ResolutionSuccessRate
FROM
    Agents A
LEFT JOIN
    CustomerServiceInteractions CSI ON A.AgentID = CSI.AgentID
GROUP BY
    A.AgentID, A.Name;

----------------------
Select * from View_AgentPerformance;