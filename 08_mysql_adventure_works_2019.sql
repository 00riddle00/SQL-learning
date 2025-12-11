-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- AdventureWorks2019 MySQL duomenų bazės apžvalga
-- ----------------------------------------------

USE adv;

-- 1. Išveskite visų klientų vardus ir pavardes iš person_person.
SELECT
    BusinessEntityID,
    FirstName,
    LastName
FROM person_person
ORDER BY LastName ASC, FirstName ASC;

-- 2. Suskaičiuokite kiek įrašų yra lentelėje person_person.
SELECT COUNT(*) AS person_count
FROM person_person;

-- 3. Išveskite visus miestus iš person_address, nesikartojančius.
SELECT DISTINCT City
FROM person_address
ORDER BY City ASC;

-- 4. Raskite kiek žmonių turi el. paštą (naudokite emailaddress).
SELECT COUNT(DISTINCT BusinessEntityID) AS people_with_email
FROM person_emailaddress;

-- 5. Išveskite pirmus 10 produktų iš production_product.
SELECT
    ProductID,
    Name,
    ListPrice
FROM production_product
ORDER BY ProductID ASC
LIMIT 10;

-- 6. Raskite visus produktus, kurių svoris yra didesnis nei 100.
SELECT
    ProductID,
    Name,
    Weight
FROM production_product
WHERE Weight > 100
ORDER BY Weight DESC, ProductID ASC;

-- 7. Raskite visas šalis, kurios prasideda raide 'C', naudokite LIKE.
SELECT
    CountryRegionCode,
    Name
FROM person_countryregion
WHERE Name LIKE 'C%'
ORDER BY Name ASC;

-- 8. Išveskite dabartinę datą naudodami CURRENT_DATE().
SELECT CURRENT_DATE() AS today;

-- 9. Raskite, kiek produktų neturi nurodyto svorio (weight IS NULL).
SELECT COUNT(*) AS products_without_weight
FROM production_product
WHERE Weight IS NULL;

-- 10. Suskaičiuokite, kiek darbuotojų yra lentelėje
-- humanresources_employee.
SELECT COUNT(*) AS employee_count
FROM humanresources_employee;

-- 11. Raskite visus darbuotojus, kurių gimimo data po 1980 metų.
SELECT
    e.BusinessEntityID,
    p.FirstName,
    p.LastName,
    e.BirthDate
FROM humanresources_employee AS e
INNER JOIN person_person AS p
    ON e.BusinessEntityID = p.BusinessEntityID
WHERE e.BirthDate >= '1980-01-01'
ORDER BY e.BirthDate ASC, p.LastName ASC, p.FirstName ASC;

-- 12. Raskite visus produktus, kurių pavadinime yra žodis "Helmet".
SELECT
    ProductID,
    Name,
    ListPrice
FROM production_product
WHERE Name LIKE '%Helmet%'
ORDER BY ListPrice DESC, Name ASC;

-- 13. Rūšiuokite produktus pagal kainą mažėjančia tvarka.
SELECT
    ProductID,
    Name,
    ListPrice
FROM production_product
ORDER BY ListPrice DESC, ProductID ASC;

-- 14. Apskaičiuokite vidutinę produkto kainą.
SELECT AVG(ListPrice) AS avg_list_price
FROM production_product;

-- 15. Konvertuokite produkto pavadinimą į didžiąsias raides.
SELECT
    ProductID,
    Name,
    UPPER(Name) AS name_upper
FROM production_product
ORDER BY Name ASC;

-- 16. Raskite miestus, kurių pavadinimas ilgesnis nei 10 simbolių.
SELECT DISTINCT City
FROM person_address
WHERE LENGTH(City) > 10
ORDER BY LENGTH(City) DESC, City ASC;

-- 17. Apskaičiuokite kiek žmonių gyvena kiekviename mieste.
SELECT
    City,
    COUNT(*) AS people_count
FROM person_address
GROUP BY City
ORDER BY people_count DESC, City ASC;

-- 18. Raskite visus darbuotojus, kurių pavardė baigiasi 'son'.
SELECT
    e.BusinessEntityID,
    p.FirstName,
    p.LastName
FROM humanresources_employee AS e
INNER JOIN person_person AS p
    ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.LastName LIKE '%son'
ORDER BY p.LastName ASC, p.FirstName ASC;

-- 19. Sujunkite person_person ir emailaddress, kad gautumėte žmogų
-- su jo el. paštu.
SELECT
    p.BusinessEntityID,
    p.FirstName,
    p.LastName,
    e.EmailAddress
FROM person_person AS p
INNER JOIN person_emailaddress AS e
    ON p.BusinessEntityID = e.BusinessEntityID
ORDER BY p.LastName ASC, p.FirstName ASC, e.EmailAddress ASC;

-- 20. Suskirstykite produktus į grupes pagal ProductSubcategoryID
-- ir suskaičiuokite, kiek jų kiekvienoje.
SELECT
    p.ProductSubcategoryID,
    sc.Name AS subcategory_name,
    COUNT(*) AS product_count
FROM production_product AS p
LEFT JOIN production_productsubcategory AS sc
    ON p.ProductSubcategoryID = sc.ProductSubcategoryID
GROUP BY p.ProductSubcategoryID, sc.Name
ORDER BY product_count DESC, p.ProductSubcategoryID ASC;

-- 21. Naudodami INNER JOIN, parodykite klientų vardus ir miestus.
SELECT
    p.BusinessEntityID,
    p.FirstName,
    p.LastName,
    a.City
FROM person_person AS p
INNER JOIN person_businessentityaddress AS ba
    ON p.BusinessEntityID = ba.BusinessEntityID
INNER JOIN person_address AS a
    ON ba.AddressID = a.AddressID
ORDER BY p.LastName ASC, p.FirstName ASC, a.City ASC;

-- 22. Sujunkite produktų ir jų kategorijų lenteles, parodykite
-- produktų pavadinimus ir kategorijų pavadinimus.
SELECT
    p.ProductID,
    p.Name AS product_name,
    sc.Name AS subcategory_name,
    c.Name AS category_name
FROM production_product AS p
LEFT JOIN production_productsubcategory AS sc
    ON p.ProductSubcategoryID = sc.ProductSubcategoryID
LEFT JOIN production_productcategory AS c
    ON sc.ProductCategoryID = c.ProductCategoryID
ORDER BY c.Name ASC, sc.Name ASC, p.Name ASC;

-- 23. Raskite 5 brangiausius produktus.
SELECT
    ProductID,
    Name,
    ListPrice
FROM production_product
ORDER BY ListPrice DESC, ProductID ASC
LIMIT 5;

-- 24. Naudokite CASE, kad pažymėtumėte produktus kaip 'Lengvas',
-- 'Vidutinis', 'Sunkus' pagal svorį.
SELECT
    ProductID,
    Name,
    Weight,
    CASE
        WHEN Weight < 50 THEN 'Lengvas'
        WHEN Weight BETWEEN 50 AND 100 THEN 'Vidutinis'
        ELSE 'Sunkus'
    END AS svoris
FROM production_product
WHERE Weight IS NOT NULL
ORDER BY Weight DESC, Name ASC;

-- 25. Naudokite IF() funkciją produkto kainos analizei – ar viršija 500.
SELECT
    ProductID,
    Name,
    ListPrice,
    IF(ListPrice > 500, 'Taip', 'Ne') AS virsija_500
FROM production_product
ORDER BY ListPrice DESC, Name ASC;

-- 26. Raskite klientus, kurie turi daugiau nei vieną adresą
-- (naudokite GROUP BY ir HAVING).
SELECT
    ba.BusinessEntityID,
    p.FirstName,
    p.LastName,
    COUNT(*) AS address_count
FROM person_businessentityaddress AS ba
INNER JOIN person_person AS p
    ON ba.BusinessEntityID = p.BusinessEntityID
GROUP BY ba.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(*) > 1
ORDER BY address_count DESC, p.LastName ASC, p.FirstName ASC;

-- 27. Sukurkite CTE, kuris grąžina visus produktus, kurių kaina
-- viršija vidurkį.
WITH avg_price_cte AS (
    SELECT AVG(ListPrice) AS avg_price
    FROM production_product
)

SELECT
    p.ProductID,
    p.Name,
    p.ListPrice
FROM production_product AS p
INNER JOIN avg_price_cte AS a
    ON p.ListPrice > a.avg_price
ORDER BY p.ListPrice DESC, p.ProductID ASC;

-- 28. Naudokite subquery, kad rastumėte produktus, brangesnius už
-- visų produktų medianą.
WITH ordered_prices AS (
    SELECT
        ListPrice,
        ROW_NUMBER() OVER (ORDER BY ListPrice) AS rn,
        COUNT(*) OVER () AS total_rows
    FROM production_product
    -- Pasirinktina: paprastai neįtraukiame 0 kainų, kad medianos skaičiavimas
    -- būtų tikslesnis
    WHERE ListPrice > 0
),

median_calc AS (
    -- Naudojame AVG(), kad teisingai apdorotume lyginio ilgio duomenų
    -- rinkinius. AVG() užtikrina, kad išvestyje bus tik 1 eilutė, todėl žemiau
    -- esanti sub-užklausa yra 100% saugi (gausime tik vieną medianos reikšmę).
    SELECT AVG(ListPrice) AS median_price
    FROM ordered_prices
    WHERE rn IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
)

SELECT
    p.ProductID,
    p.Name,
    p.ListPrice
FROM production_product AS p
WHERE p.ListPrice > (SELECT m.median_price FROM median_calc AS m)
ORDER BY p.ListPrice DESC, p.ProductID ASC;

-- 29. Raskite šalis, kuriose gyvena daugiau nei 5 žmonės
-- (pagal adresus).
SELECT
    cr.CountryRegionCode,
    cr.Name AS country_name,
    COUNT(*) AS people_count
FROM person_address AS a
INNER JOIN person_stateprovince AS sp
    ON a.StateProvinceID = sp.StateProvinceID
INNER JOIN person_countryregion AS cr
    ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.CountryRegionCode, cr.Name
HAVING COUNT(*) > 5
ORDER BY people_count DESC, cr.Name ASC;

-- 30. Apskaičiuokite bendrą visų užsakymų pardavimo sumą iš
-- sales_salesorderheader.
SELECT SUM(TotalDue) AS total_sales
FROM sales_salesorderheader;

-- 31. Raskite kiek klientų pateikė bent vieną užsakymą.
SELECT COUNT(DISTINCT CustomerID) AS customers_with_orders
FROM sales_salesorderheader;

-- 32. Raskite kiekvieno kliento visų užsakymų sumą
-- (vardas, pavardė, suma).
SELECT
    h.CustomerID,
    p.FirstName,
    p.LastName,
    SUM(h.TotalDue) AS suma
FROM sales_salesorderheader AS h
INNER JOIN person_person AS p
    ON h.CustomerID = p.BusinessEntityID
GROUP BY h.CustomerID, p.FirstName, p.LastName
ORDER BY suma DESC, p.LastName ASC, p.FirstName ASC;

-- 33. Apskaičiuokite kiek užsakymų buvo pateikta kiekvieną mėnesį.
SELECT
    YEAR(OrderDate) AS order_year,
    MONTH(OrderDate) AS order_month,
    COUNT(*) AS order_count
FROM sales_salesorderheader
GROUP BY order_year, order_month
ORDER BY order_year ASC, order_month ASC;

-- 34. Išveskite 10 dažniausiai parduodamų produktų pagal kiekį.
SELECT
    d.ProductID,
    p.Name,
    SUM(d.OrderQty) AS qty
FROM sales_salesorderdetail AS d
INNER JOIN production_product AS p
    ON d.ProductID = p.ProductID
GROUP BY d.ProductID, p.Name
ORDER BY qty DESC, d.ProductID ASC
LIMIT 10;

-- 35. Raskite visus klientus, kurių pirkimo suma viršija vidutinę
-- visų klientų sumą. (su subquery/CTE)
WITH customer_totals AS (
    SELECT
        CustomerID,
        SUM(TotalDue) AS sum_total
    FROM sales_salesorderheader
    GROUP BY CustomerID
),

avg_total_calc AS (
    SELECT AVG(sum_total) AS avg_total FROM customer_totals
)

SELECT
    ct.CustomerID,
    p.FirstName,
    p.LastName,
    ct.sum_total AS suma
FROM customer_totals AS ct
INNER JOIN person_person AS p
    ON ct.CustomerID = p.BusinessEntityID
INNER JOIN avg_total_calc AS atc
    ON ct.sum_total > atc.avg_total
ORDER BY ct.sum_total DESC, p.LastName ASC, p.FirstName ASC;

-- 36. Parodykite kiekvieno produkto pavadinimą ir jo bendrą
-- pardavimų sumą (naudoti INNER JOIN su sales_salesorderdetail).
SELECT
    p.ProductID,
    p.Name,
    SUM(d.LineTotal) AS total_sales
FROM sales_salesorderdetail AS d
INNER JOIN production_product AS p
    ON d.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY total_sales DESC, p.ProductID ASC;

-- 37. Naudokite CASE, kad parodytumėte, ar produktas yra 'Pigus',
-- 'Vidutinės kainos', ar 'Brangus' (pagal ListPrice).
SELECT
    p.ProductID,
    p.Name,
    p.ListPrice,
    CASE
        WHEN p.ListPrice < 100 THEN 'Pigus'
        WHEN p.ListPrice BETWEEN 100 AND 500 THEN 'Vidutinės kainos'
        ELSE 'Brangus'
    END AS kategorija
FROM production_product AS p
ORDER BY p.ListPrice DESC, p.Name ASC;

-- 38. Išveskite užsakymus, kurių pristatymo kaina didesnė nei 10 %
-- nuo visos užsakymo sumos (CASE ar IF su skaičiavimu).
SELECT
    SalesOrderID,
    CustomerID,
    OrderDate,
    TotalDue,
    Freight,
    (Freight / TotalDue) AS freight_ratio
FROM sales_salesorderheader
WHERE Freight > (TotalDue * 0.10)
ORDER BY freight_ratio DESC, SalesOrderID ASC;

-- 39. Raskite klientus, kurie pateikė daugiau nei 5 užsakymus.
SELECT
    h.CustomerID,
    p.FirstName,
    p.LastName,
    COUNT(*) AS order_count
FROM sales_salesorderheader AS h
INNER JOIN person_person AS p
    ON h.CustomerID = p.BusinessEntityID
GROUP BY h.CustomerID, p.FirstName, p.LastName
HAVING COUNT(*) > 5
ORDER BY order_count DESC, p.LastName ASC, p.FirstName ASC;

-- 40. Parodykite visų produktų sąrašą ir pažymėkite, ar jie kada
-- nors buvo parduoti (CASE WHEN EXISTS (...) THEN 'Taip'
-- ELSE 'Ne').
SELECT
    p.ProductID,
    p.Name,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM sales_salesorderdetail AS d
            WHERE d.ProductID = p.ProductID
        ) THEN 'Taip'
        ELSE 'Ne'
    END AS parduotas
FROM production_product AS p
ORDER BY parduotas DESC, p.Name ASC;

-- 41. Apskaičiuokite pelną kiekvienam produktui
-- (kaina - standarto kaina), parodykite tik tuos, kurių pelnas > 0.
SELECT
    p.ProductID,
    p.Name,
    p.ListPrice,
    p.StandardCost,
    (p.ListPrice - p.StandardCost) AS pelnas
FROM production_product AS p
WHERE (p.ListPrice - p.StandardCost) > 0
ORDER BY pelnas DESC, p.ProductID ASC;

-- 42. Parodykite klientus, kurie pirko prekes už daugiau nei 1000.
SELECT
    h.CustomerID,
    p.FirstName,
    p.LastName,
    SUM(h.TotalDue) AS suma
FROM sales_salesorderheader AS h
INNER JOIN person_person AS p
    ON h.CustomerID = p.BusinessEntityID
GROUP BY h.CustomerID, p.FirstName, p.LastName
HAVING SUM(h.TotalDue) > 1000
ORDER BY suma DESC, p.LastName ASC, p.FirstName ASC;

-- 43. Parodykite produktus, kurie yra brangesni nei bet kuris
-- "Helmet" tipo produktas. (su ANY ar subquery)
SELECT
    p.ProductID,
    p.Name,
    p.ListPrice
FROM production_product AS p
WHERE
    p.ListPrice > (
        SELECT MAX(sub_p.ListPrice)
        FROM production_product AS sub_p
        WHERE sub_p.Name LIKE '%Helmet%'
    )
ORDER BY p.ListPrice DESC, p.ProductID ASC;

-- 44. Parodykite kiekvienos produktų subkategorijos pardavimo sumą.
SELECT
    sc.ProductSubcategoryID,
    sc.Name AS subcategory_name,
    SUM(d.LineTotal) AS total_sales
FROM sales_salesorderdetail AS d
INNER JOIN production_product AS p
    ON d.ProductID = p.ProductID
LEFT JOIN production_productsubcategory AS sc
    ON p.ProductSubcategoryID = sc.ProductSubcategoryID
GROUP BY sc.ProductSubcategoryID, sc.Name
ORDER BY total_sales DESC, sc.Name ASC;

-- 45. Parodykite tik tuos produktus, kurių buvo parduota daugiau
-- nei 100 vienetų.
SELECT
    d.ProductID,
    p.Name,
    SUM(d.OrderQty) AS qty
FROM sales_salesorderdetail AS d
INNER JOIN production_product AS p
    ON d.ProductID = p.ProductID
GROUP BY d.ProductID, p.Name
HAVING SUM(d.OrderQty) > 100
ORDER BY qty DESC, d.ProductID ASC;

-- 46. Apskaičiuokite kiek produktų yra kiekvienoje kainos
-- kategorijoje: <100, 100–500, >500.
SELECT
    CASE
        WHEN p.ListPrice < 100 THEN '<100'
        WHEN p.ListPrice BETWEEN 100 AND 500 THEN '100-500'
        ELSE '>500'
    END AS price_category,
    COUNT(*) AS product_count
FROM production_product AS p
GROUP BY price_category
ORDER BY price_category ASC;

-- 47. Parodykite darbuotojus, kurie dirba daugiau nei metus,
-- 5 metus ir daugiau nei 10 metų (skaičiuoti su DATEDIFF()).
SELECT
    e.BusinessEntityID,
    p.FirstName,
    p.LastName,
    e.HireDate,
    DATEDIFF(CURRENT_DATE(), e.HireDate) AS days_worked,
    CASE
        WHEN DATEDIFF(CURRENT_DATE(), e.HireDate) > 3650 THEN '>10 years'
        WHEN DATEDIFF(CURRENT_DATE(), e.HireDate) > 1825 THEN '>5 years'
        WHEN DATEDIFF(CURRENT_DATE(), e.HireDate) > 365 THEN '>1 year'
        ELSE '<=1 year'
    END AS tenure_category
FROM humanresources_employee AS e
INNER JOIN person_person AS p
    ON e.BusinessEntityID = p.BusinessEntityID
WHERE DATEDIFF(CURRENT_DATE(), e.HireDate) > 365
ORDER BY days_worked DESC, p.LastName ASC, p.FirstName ASC;

-- 48. Raskite, kurie produktai generavo didžiausią pardavimų
-- pajamų sumą.
SELECT
    p.ProductID,
    p.Name,
    SUM(d.LineTotal) AS total_sales
FROM sales_salesorderdetail AS d
INNER JOIN production_product AS p
    ON d.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY total_sales DESC, p.ProductID ASC;
