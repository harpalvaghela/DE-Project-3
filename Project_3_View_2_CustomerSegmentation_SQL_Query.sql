CREATE OR ALTER VIEW View_2_CustomerSegmentation AS
WITH LoyaltyRanked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY CustomerID 
                           ORDER BY 
                               CASE TierLevel
                                   WHEN 'Platinum' THEN 4
                                   WHEN 'Gold' THEN 3
                                   WHEN 'Silver' THEN 2
                                   WHEN 'Bronze' THEN 1
                                   ELSE 0
                               END DESC) AS rn
    FROM LoyaltyAccounts
),
BestLoyalty AS (
    SELECT CustomerID, TierLevel
    FROM LoyaltyRanked
    WHERE rn = 1
),
CustomerSpend AS (
    SELECT 
        C.CustomerID,
        C.Name AS CustomerName,
        SUM(COALESCE(OT.Amount, 0) + COALESCE(IST.Amount, 0)) AS TotalSpend,
        COUNT(DISTINCT OT.OrderID) + COUNT(DISTINCT IST.TransactionID) AS PurchaseFrequency,
        COALESCE(BL.TierLevel, 'None') AS TierLevel
    FROM
        Customers C
    LEFT JOIN
        OnlineTransactions OT ON C.CustomerID = OT.CustomerID
    LEFT JOIN
        InStoreTransactions IST ON C.CustomerID = IST.CustomerID
    LEFT JOIN
        BestLoyalty BL ON C.CustomerID = BL.CustomerID
    GROUP BY
        C.CustomerID, C.Name, BL.TierLevel
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
		WHEN CS.TierLevel IN ('Gold', 'Platinum') AND CS.TotalSpend > 0 THEN 'Loyalty Champion'
    ELSE 'Regular Customer'
END AS CustomerSegment

FROM
    CustomerSpend CS;

Select * from View_2_CustomerSegmentation;