CREATE OR ALTER VIEW View_3_PeakTimes AS
WITH BaseData AS (
    SELECT
        'Online' AS Channel,
        DATENAME(WEEKDAY, OT.DateTime) AS DayOfWeek,
        DATEPART(HOUR, OT.DateTime) AS HourOfDay,
        COUNT(*) AS TransactionCount
    FROM OnlineTransactions OT
    GROUP BY
        DATENAME(WEEKDAY, OT.DateTime),
        DATEPART(HOUR, OT.DateTime)

    UNION ALL

    SELECT
        'InStore' AS Channel,
        DATENAME(WEEKDAY, IST.DateTime) AS DayOfWeek,
        DATEPART(HOUR, IST.DateTime) AS HourOfDay,
        COUNT(*) AS TransactionCount
    FROM InStoreTransactions IST
    GROUP BY
        DATENAME(WEEKDAY, IST.DateTime),
        DATEPART(HOUR, IST.DateTime)
),
RankedData AS (
    SELECT *,
        RANK() OVER (PARTITION BY Channel, DayOfWeek ORDER BY TransactionCount DESC) AS HourRank
    FROM BaseData
)
SELECT
    Channel,
    DayOfWeek,
    HourOfDay,
    TransactionCount
FROM RankedData
WHERE HourRank = 1;


Select * from View_3_PeakTimes