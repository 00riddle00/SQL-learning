-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- [#1] 28. Raskite produktus, brangesnius už visų produktų medianą
-- (Pratybos, 2025-12-10).
WITH ordered_prices AS (
    SELECT
        ListPrice,
        ROW_NUMBER() OVER (ORDER BY ListPrice) AS row_num,
        COUNT(*) OVER () AS total_rows
    FROM production_product
    -- Pasirinktina: paprastai neįtraukiame 0 kainų, kad medianos skaičiavimas
    -- būtų tikslesnis
    WHERE ListPrice > 0
),

median_calc AS (
    SELECT AVG(ListPrice) AS median_price
    FROM ordered_prices
    WHERE row_num IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2))
)

SELECT
    p.ProductID,
    p.Name,
    p.ListPrice
FROM production_product AS p
CROSS JOIN median_calc AS m
WHERE p.ListPrice > m.median_price
ORDER BY p.ListPrice DESC, p.ProductID ASC;

-- [#2] 28. Raskite produktus, brangesnius už visų produktų medianą
-- (Paskaitos pavyzdys nr.1, 2025-12-10).
select * from production_product;
SELECT p1.*
FROM production_product p1
WHERE (
  SELECT COUNT(*) 
  FROM production_product p2
  WHERE p2.ListPrice < p1.ListPrice
) >= (
  SELECT COUNT(*) 
  FROM production_product
) / 2;


-- [#3] 28. Raskite produktus, brangesnius už visų produktų medianą
-- (Paskaitos pavyzdys nr.2, 2025-12-10).
WITH ordered_prices AS (
  SELECT listprice,
         ROW_NUMBER() OVER (ORDER BY listprice) AS rn,
         COUNT(*) OVER () AS total
  FROM production_product
),
median_price AS (
  SELECT listprice
  FROM ordered_prices
  WHERE rn = FLOOR((total + 1)/2)
)
SELECT * 
FROM production_product
WHERE listprice > (SELECT listprice FROM median_price);

-- [#4] 28. Raskite produktus, brangesnius už visų produktų medianą
-- (Galutinė versija, Pratybos, 2025-12-11).
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
    ProductID,
    Name,
    ListPrice
FROM production_product
WHERE ListPrice > (SELECT m.median_price FROM median_calc AS m)
ORDER BY ListPrice DESC;
