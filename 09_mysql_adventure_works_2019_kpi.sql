-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- MySQL tasks AdventureWorks2019_KPI
-- ----------------------------------------------

USE adv;

-- 1. Apskaičiuok bendrą pardavimų sumą, atskirai online ir
-- direct kanalams.
SELECT
    CASE
        WHEN h.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS `channel`,
    ROUND(SUM(d.LineTotal), 2) AS total_sales
FROM sales_salesorderheader AS h
INNER JOIN sales_salesorderdetail AS d
    ON h.SalesOrderID = d.SalesOrderID
GROUP BY `channel`
ORDER BY `channel` ASC;

-- 2. Apskaičiuok vidutinę užsakymo vertę pagal pardavimo kanalą.
WITH order_revenue AS (
    SELECT
        h.SalesOrderID,
        CASE
            WHEN h.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS `channel`,
        SUM(d.LineTotal) AS revenue
    FROM sales_salesorderheader AS h
    INNER JOIN sales_salesorderdetail AS d
        ON h.SalesOrderID = d.SalesOrderID
    GROUP BY h.SalesOrderID, `channel`
)

SELECT
    `channel`,
    ROUND(AVG(revenue), 2) AS avg_order_value
FROM order_revenue
GROUP BY `channel`
ORDER BY avg_order_value DESC, `channel` ASC;

-- 3. Apskaičiuok bendrą produktų pardavimo sumą (linetotal),
-- suskirstytą pagal kanalą.
SELECT
    CASE
        WHEN h.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS `channel`,
    ROUND(SUM(d.LineTotal), 2) AS total_line_sales
FROM sales_salesorderheader AS h
INNER JOIN sales_salesorderdetail AS d
    ON h.SalesOrderID = d.SalesOrderID
GROUP BY `channel`
ORDER BY total_line_sales DESC, `channel` ASC;

-- 4. Rask 5 labiausiai parduodamus produktus kiekviename kanale
-- pagal kiekį.
WITH product_sales AS (
    SELECT
        d.ProductID,
        p.Name AS product_name,
        CASE
            WHEN h.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS `channel`,
        SUM(d.OrderQty) AS total_qty
    FROM sales_salesorderheader AS h
    INNER JOIN sales_salesorderdetail AS d
        ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN production_product AS p
        ON d.ProductID = p.ProductID
    GROUP BY `channel`, d.ProductID, p.Name
),

ranked_products AS (
    SELECT
        `channel`,
        ProductID,
        product_name,
        total_qty,
        ROW_NUMBER() OVER (
            PARTITION BY `channel`
            ORDER BY total_qty DESC, ProductID ASC
        ) AS rn
    FROM product_sales
)

SELECT
    `channel`,
    ProductID,
    product_name,
    total_qty
FROM ranked_products
WHERE rn <= 5
ORDER BY `channel` ASC, total_qty DESC, ProductID ASC;

-- 5. Rask klientus, kurie bent du kartus pirko online arba
-- direct kanalu.
SELECT
    h.CustomerID,
    p.FirstName,
    p.LastName,
    CASE
        WHEN h.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS `channel`,
    COUNT(DISTINCT h.SalesOrderID) AS order_count
FROM sales_salesorderheader AS h
INNER JOIN person_person AS p
    ON h.CustomerID = p.BusinessEntityID
GROUP BY `channel`, h.CustomerID, p.FirstName, p.LastName
HAVING COUNT(DISTINCT h.SalesOrderID) >= 2
ORDER BY `channel` ASC, order_count DESC, p.LastName ASC, p.FirstName ASC;

-- 6. Naudojant CTE, rask tik online užsakymus, kurių suma
-- viršija online užsakymų vidurkį.
WITH online_orders AS (
    SELECT
        h.SalesOrderID,
        h.CustomerID,
        h.OrderDate,
        SUM(d.LineTotal) AS order_revenue
    FROM sales_salesorderheader AS h
    INNER JOIN sales_salesorderdetail AS d
        ON h.SalesOrderID = d.SalesOrderID
    WHERE h.OnlineOrderFlag = 1
    GROUP BY h.SalesOrderID, h.CustomerID, h.OrderDate
),

online_avg AS (
    SELECT AVG(order_revenue) AS avg_revenue
    FROM online_orders
)

SELECT
    o.SalesOrderID,
    o.CustomerID,
    o.OrderDate,
    o.order_revenue
FROM online_orders AS o
CROSS JOIN online_avg AS a
WHERE o.order_revenue > a.avg_revenue
ORDER BY o.order_revenue DESC, o.SalesOrderID ASC;

-- 7. Rask visus produktus, kurie buvo bent kartą parduoti, ir
-- apskaičiuok jų pelną (listprice - standardcost).
SELECT DISTINCT
    p.ProductID,
    p.Name,
    p.ListPrice,
    p.StandardCost,
    (p.ListPrice - p.StandardCost) AS profit
FROM production_product AS p
INNER JOIN sales_salesorderdetail AS d
    ON p.ProductID = d.ProductID
ORDER BY profit DESC, p.Name ASC;

-- 8. Apskaičiuok kiekvieno mėnesio pardavimų sumą, atskirai
-- pagal kanalą.
SELECT
    YEAR(h.OrderDate) AS `year`,
    MONTH(h.OrderDate) AS `month`,
    CASE
        WHEN h.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS `channel`,
    ROUND(SUM(d.LineTotal), 2) AS total_sales
FROM sales_salesorderheader AS h
INNER JOIN sales_salesorderdetail AS d
    ON h.SalesOrderID = d.SalesOrderID
GROUP BY `year`, `month`, `channel`
ORDER BY `year` ASC, `month` ASC, `channel` ASC;

-- 9. Apskaičiuok vidutinį pristatymo laiką (shipdate - orderdate)
-- tik direct kanalui.
SELECT AVG(DATEDIFF(ShipDate, OrderDate)) AS avg_ship_days_direct
FROM sales_salesorderheader
WHERE
    OnlineOrderFlag = 0
    AND ShipDate IS NOT NULL
    AND OrderDate IS NOT NULL;

-- 10. Apskaičiuok, kiek skirtingų produktų buvo parduota bent
-- kartą kiekviename kanale.
SELECT
    CASE
        WHEN h.OnlineOrderFlag = 1 THEN 'Online'
        ELSE 'Direct'
    END AS `channel`,
    COUNT(DISTINCT d.ProductID) AS distinct_products_sold
FROM sales_salesorderheader AS h
INNER JOIN sales_salesorderdetail AS d
    ON h.SalesOrderID = d.SalesOrderID
GROUP BY `channel`
ORDER BY distinct_products_sold DESC, `channel` ASC;

-- 11. Apskaičiuok bendrą pardavimų sumą pagal pardavimo
-- teritoriją.
-- (Naudoti INNER JOIN tarp sales_salesorderheader ir
-- sales_salesterritory)
SELECT
    h.TerritoryID,
    t.Name AS territory_name,
    ROUND(SUM(d.LineTotal), 2) AS total_sales
FROM sales_salesorderheader AS h
INNER JOIN sales_salesorderdetail AS d
    ON h.SalesOrderID = d.SalesOrderID
INNER JOIN sales_salesterritory AS t
    ON h.TerritoryID = t.TerritoryID
GROUP BY h.TerritoryID, t.Name
ORDER BY total_sales DESC, t.Name ASC;

-- 12. Apskaičiuok online ir direct pardavimų sumą kiekvienai
-- teritorijai atskirai.
-- (Naudoti CASE su GROUP BY territory)
SELECT
    h.TerritoryID,
    t.Name AS territory_name,
    ROUND(
        SUM(CASE WHEN h.OnlineOrderFlag = 1 THEN d.LineTotal ELSE 0 END), 2
    ) AS online_sales,
    ROUND(
        SUM(CASE WHEN h.OnlineOrderFlag = 0 THEN d.LineTotal ELSE 0 END), 2
    ) AS direct_sales
FROM sales_salesorderheader AS h
INNER JOIN sales_salesorderdetail AS d
    ON h.SalesOrderID = d.SalesOrderID
INNER JOIN sales_salesterritory AS t
    ON h.TerritoryID = t.TerritoryID
GROUP BY h.TerritoryID, t.Name
ORDER BY (online_sales + direct_sales) DESC, t.Name ASC;

-- 13. Rask teritorijas, kuriose vidutinė online užsakymo vertė
-- viršija direct.
-- (Naudoti subquery arba GROUP BY su CASE)
WITH territory_order_values AS (
    SELECT
        h.SalesOrderID,
        h.TerritoryID,
        t.Name AS territory_name,
        CASE
            WHEN h.OnlineOrderFlag = 1 THEN 'Online'
            ELSE 'Direct'
        END AS `channel`,
        SUM(d.LineTotal) AS order_revenue
    FROM sales_salesorderheader AS h
    INNER JOIN sales_salesorderdetail AS d
        ON h.SalesOrderID = d.SalesOrderID
    INNER JOIN sales_salesterritory AS t
        ON h.TerritoryID = t.TerritoryID
    GROUP BY h.SalesOrderID, h.TerritoryID, t.Name, `channel`
)

SELECT
    TerritoryID,
    territory_name,
    AVG(CASE WHEN `channel` = 'Online' THEN order_revenue END) AS avg_online,
    AVG(CASE WHEN `channel` = 'Direct' THEN order_revenue END) AS avg_direct
FROM territory_order_values
GROUP BY TerritoryID, territory_name
HAVING
    avg_online IS NOT NULL
    AND avg_direct IS NOT NULL
    AND avg_online > avg_direct
ORDER BY avg_online - avg_direct DESC, territory_name ASC;

-- 14. Apskaičiuok vidutinį pristatymo laiką kiekvienoje
-- teritorijoje (visiems užsakymams).
-- (shipdate - orderdate)
SELECT
    h.TerritoryID,
    t.Name AS territory_name,
    AVG(DATEDIFF(h.ShipDate, h.OrderDate)) AS avg_ship_days
FROM sales_salesorderheader AS h
INNER JOIN sales_salesterritory AS t
    ON h.TerritoryID = t.TerritoryID
WHERE
    h.ShipDate IS NOT NULL
    AND h.OrderDate IS NOT NULL
GROUP BY h.TerritoryID, t.Name
ORDER BY avg_ship_days DESC, t.Name ASC;

-- 15. Rask 3 teritorijas, kuriose pristatymas trunka ilgiausiai
-- (pagal vidurkį).
WITH territory_ship AS (
    SELECT
        h.TerritoryID,
        t.Name AS territory_name,
        AVG(DATEDIFF(h.ShipDate, h.OrderDate)) AS avg_ship_days
    FROM sales_salesorderheader AS h
    INNER JOIN sales_salesterritory AS t
        ON h.TerritoryID = t.TerritoryID
    WHERE
        h.ShipDate IS NOT NULL
        AND h.OrderDate IS NOT NULL
    GROUP BY h.TerritoryID, t.Name
)

SELECT
    TerritoryID,
    territory_name,
    avg_ship_days
FROM territory_ship
ORDER BY avg_ship_days DESC, territory_name ASC
LIMIT 3;

-- 16. Apskaičiuok kiekvienos teritorijos pardavimo kanalų
-- pasiskirstymą (% online vs direct).
-- (Skaičiuoti kanalų dalį iš visų užsakymų pagal teritoriją)
SELECT
    h.TerritoryID,
    t.Name AS territory_name,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN h.OnlineOrderFlag = 1 THEN 1 ELSE 0 END) AS online_orders,
    SUM(CASE WHEN h.OnlineOrderFlag = 0 THEN 1 ELSE 0 END) AS direct_orders,
    ROUND(
        100.0
        * SUM(CASE WHEN h.OnlineOrderFlag = 1 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS online_percent,
    ROUND(
        100.0
        * SUM(CASE WHEN h.OnlineOrderFlag = 0 THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS direct_percent
FROM sales_salesorderheader AS h
INNER JOIN sales_salesterritory AS t
    ON h.TerritoryID = t.TerritoryID
GROUP BY h.TerritoryID, t.Name
ORDER BY online_percent DESC, territory_name ASC;
