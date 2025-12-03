-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- SQL - MySQL Subquery_CTE (Compulsory)
-- ----------------------------------------------

USE sakila;

-- 1. Raskite filmus, kurių nuomos kaina didesnė už visų filmų vidurkį.
SELECT
    f.film_id,
    f.title,
    f.rental_rate
FROM film AS f
WHERE
    f.rental_rate > (
        SELECT AVG(f2.rental_rate)
        FROM film AS f2
    )
ORDER BY f.rental_rate DESC;

-- 2. Raskite klientus, kurių vardas yra ilgesnis nei visų klientų vardų
-- vidutinė trukmė.
SELECT
    c.first_name,
    c.last_name,
    CHAR_LENGTH(c.first_name) AS name_length
FROM customer AS c
WHERE
    CHAR_LENGTH(c.first_name) > (
        SELECT AVG(CHAR_LENGTH(c2.first_name))
        FROM customer AS c2
    )
ORDER BY
    name_length DESC,
    c.first_name ASC,
    c.last_name ASC;

-- 3. Raskite filmus, kurių trukmė ilgesnė nei vidutinė jų kalbos filmų
-- trukmė.
SELECT
    f.film_id,
    f.title,
    f.language_id,
    f.length
FROM film AS f
WHERE
    f.length > (
        SELECT AVG(f2.length)
        FROM film AS f2
        WHERE f2.language_id = f.language_id
    )
ORDER BY f.length DESC;

-- 4. Raskite klientus, kurie paskutinį kartą nuomojo filmą seniau nei vidutinė
-- visų paskutinių nuomų data.
SELECT
    t.customer_id,
    t.first_name,
    t.last_name,
    t.last_rental_date
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        MAX(r.rental_date) AS last_rental_date
    FROM customer AS c
    INNER JOIN rental AS r
        ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
) AS t
WHERE
    t.last_rental_date < (
        SELECT AVG(inner_t.last_rental_date)
        FROM (
            SELECT MAX(r2.rental_date) AS last_rental_date
            FROM rental AS r2
            GROUP BY r2.customer_id
        ) AS inner_t
    )
ORDER BY t.last_rental_date ASC;

-- 5. Raskite filmus, kurių pavadinimo ilgis didesnis nei vidutinis
-- pavadinimų ilgis.
SELECT
    f.film_id,
    f.title,
    CHAR_LENGTH(f.title) AS title_length
FROM film AS f
WHERE
    CHAR_LENGTH(f.title) > (
        SELECT AVG(CHAR_LENGTH(f2.title))
        FROM film AS f2
    )
ORDER BY title_length DESC;

-- 6. Naudojant CTE, raskite kiekvieno kliento bendrą nuomų skaičių, sumą ir
-- priskirkite kategoriją: 'Lojalus', 'Vidutinis', 'Naujokas'. Naudoti Case.
WITH customer_stats AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(DISTINCT r.rental_id) AS rental_count,
        COALESCE(SUM(p.amount), 0) AS total_amount
    FROM customer AS c
    LEFT JOIN rental AS r
        ON c.customer_id = r.customer_id
    LEFT JOIN payment AS p
        ON r.rental_id = p.rental_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    cs.first_name,
    cs.last_name,
    cs.rental_count,
    cs.total_amount,
    CASE
        WHEN cs.total_amount >= 150 THEN 'Lojalus'
        WHEN cs.total_amount >= 50 THEN 'Vidutinis'
        ELSE 'Naujokas'
    END AS customer_category
FROM customer_stats AS cs
ORDER BY cs.total_amount DESC;

-- 7. Naudojant CTE, raskite kiekvieno filmo aprašymo ilgį simboliais ir
-- pažymėkite, ar jis ilgas (daugiau nei 30 simbolių). Naudoti IF.
WITH film_desc AS (
    SELECT
        f.film_id,
        f.title,
        CHAR_LENGTH(f.description) AS desc_length
    FROM film AS f
)

SELECT
    fd.film_id,
    fd.title,
    fd.desc_length,
    IF(
        fd.desc_length > 30,
        'Ilgas',
        'Trumpas'
    ) AS is_long
FROM film_desc AS fd
ORDER BY fd.desc_length DESC;

-- 8 Naudodami CTE, suskaičiuokite, kiek klientų gyvena kiekviename mieste,
-- ir pažymėkite, ar klientų skaičius viršija ar ne 10. Case
WITH city_customers AS (
    SELECT
        ci.city_id,
        ci.city,
        COUNT(c.customer_id) AS customer_count
    FROM city AS ci
    INNER JOIN address AS a
        ON ci.city_id = a.city_id
    INNER JOIN customer AS c
        ON a.address_id = c.address_id
    GROUP BY
        ci.city_id,
        ci.city
)

SELECT
    cc.city,
    cc.customer_count,
    CASE
        WHEN cc.customer_count > 10 THEN 'Viršija 10'
        ELSE 'Neviršija 10'
    END AS size_flag
FROM city_customers AS cc
ORDER BY cc.customer_count DESC;

-- 9. Naudojant CTE, raskite kiekvieno darbuotojo vidutinę nuomos sumą ir
-- pažymėkite, ar ji didesnė nei 3. IF.
WITH staff_avg AS (
    SELECT
        s.staff_id,
        s.first_name,
        s.last_name,
        AVG(p.amount) AS avg_amount
    FROM staff AS s
    INNER JOIN payment AS p
        ON s.staff_id = p.staff_id
    GROUP BY
        s.staff_id,
        s.first_name,
        s.last_name
)

SELECT
    sa.first_name,
    sa.last_name,
    sa.avg_amount,
    IF(
        sa.avg_amount > 3,
        'Didesnė nei 3',
        'Ne didesnė nei 3'
    ) AS avg_flag
FROM staff_avg AS sa
ORDER BY sa.avg_amount DESC;

-- 10. Naudodami CTE, suskaičiuokite, kiek kartų kiekvienas filmas buvo
-- išnuomotas ir priskirkite populiarumo lygį. Case.
WITH film_rentals AS (
    SELECT
        f.film_id,
        f.title,
        COUNT(r.rental_id) AS rental_count
    FROM film AS f
    LEFT JOIN inventory AS i
        ON f.film_id = i.film_id
    LEFT JOIN rental AS r
        ON i.inventory_id = r.inventory_id
    GROUP BY
        f.film_id,
        f.title
)

SELECT
    fr.film_id,
    fr.title,
    fr.rental_count,
    CASE
        WHEN fr.rental_count >= 40 THEN 'Labai populiarus'
        WHEN fr.rental_count >= 20 THEN 'Populiarus'
        WHEN fr.rental_count >= 1 THEN 'Mažai populiarus'
        ELSE 'Nenuomotas'
    END AS popularity_level
FROM film_rentals AS fr
ORDER BY fr.rental_count DESC;

-- 11. Naudojant CTE, suskaičiuokite kiekvienos kategorijos filmų vidutinę
-- trukmę ir klasifikuokite: 'Trumpi', 'Vidutiniai', 'Ilgi'.
WITH category_lengths AS (
    SELECT
        c.category_id,
        c.name AS category_name,
        AVG(f.length) AS avg_length
    FROM category AS c
    INNER JOIN film_category AS fc
        ON c.category_id = fc.category_id
    INNER JOIN film AS f
        ON fc.film_id = f.film_id
    GROUP BY
        c.category_id,
        c.name
)

SELECT
    cl.category_name,
    cl.avg_length,
    CASE
        WHEN cl.avg_length < 60 THEN 'Trumpi'
        WHEN cl.avg_length <= 120 THEN 'Vidutiniai'
        ELSE 'Ilgi'
    END AS length_category
FROM category_lengths AS cl
ORDER BY cl.avg_length ASC;

-- 12. Naudodami CTE, suskaičiuokite, kiek kiekvienas klientas sumokėjo ir ar
-- viršijo bendrą vidurkį. Case.
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(p.amount) AS total_paid
    FROM customer AS c
    INNER JOIN payment AS p
        ON c.customer_id = p.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    ct.first_name,
    ct.last_name,
    ct.total_paid,
    CASE
        WHEN ct.total_paid > (
            SELECT AVG(ct2.total_paid)
            FROM customer_totals AS ct2
        ) THEN 'Viršijo vidurkį'
        ELSE 'Neviršijo vidurkio'
    END AS above_average_flag
FROM customer_totals AS ct
ORDER BY ct.total_paid DESC;
