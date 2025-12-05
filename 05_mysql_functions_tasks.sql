-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- SQL - MySQL functions Tasks
-- BONUS už gražų kodą ir gerą formatavimą, įvairius kodų variantus,
-- kūrybiškumą
-- ----------------------------------------------

USE sakila;

-- 1. Raskite aktorių vardus, kurių pavardė prasideda raide „A“, ir pridėkite
-- simbolių skaičių prie kiekvieno jų vardo.
SELECT
    a.first_name,
    LENGTH(a.first_name) AS name_length
FROM actor AS a
WHERE a.last_name LIKE 'A%';

-- 2. Apskaičiuokite kiekvieno kliento nuomos mokesčio vidurkį.
SELECT
    c.first_name,
    c.last_name,
    ROUND(AVG(p.amount), 2) AS avg_payment
FROM customer AS c
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    c.last_name ASC,
    c.first_name ASC;

-- 3. Sugrupuokite nuomas pagal metus ir mėnesį bei parodykite jų skaičių.
SELECT
    YEAR(r.rental_date) AS rental_year,
    MONTH(r.rental_date) AS rental_month,
    COUNT(*) AS rental_count
FROM rental AS r
GROUP BY
    YEAR(r.rental_date),
    MONTH(r.rental_date)
ORDER BY
    rental_year ASC,
    rental_month ASC;

-- 4. Parodykite klientų vardus su jų bendrais mokėjimais, apvalinant iki
-- dviejų skaitmenų po kablelio.
SELECT
    c.first_name,
    c.last_name,
    ROUND(SUM(p.amount), 2) AS total_paid
FROM customer AS c
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_paid DESC;

-- 5. Rodyti kiekvieną filmą, id, pavadinimo pirmus 2 žodžius ir ar jo
-- trukmė ilgesnė nei vidutinė (IF)
-- !!! Turi SUBQUERY vidurkiui apskaičiuoti: SELECT AVG(...) FROM ...
SELECT
    f.film_id,
    SUBSTRING_INDEX(f.title, ' ', 2) AS first_two_words,
    IF(
        f.length > (
            SELECT AVG(f2.length)
            FROM film AS f2
        ),
        'Longer than average',
        'Not longer than average'
    ) AS length_vs_average
FROM film AS f;

-- 6. Išveskite visas kategorijas ir skaičių filmų, priklausančių
-- kiekvienai kategorijai, bendrą pelną, vidutinį nuomos įkainį.
SELECT
    c.name AS category_name,
    COUNT(DISTINCT f.film_id) AS film_count,
    SUM(p.amount) AS total_revenue,
    ROUND(AVG(f.rental_rate), 2) AS avg_rental_rate
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN film AS f
    ON fc.film_id = f.film_id
LEFT JOIN inventory AS i
    ON f.film_id = i.film_id
LEFT JOIN rental AS r
    ON i.inventory_id = r.inventory_id
LEFT JOIN payment AS p
    ON r.rental_id = p.rental_id
GROUP BY
    c.category_id,
    c.name
ORDER BY category_name ASC;

-- 7. Raskite visų nuomų, kurios įvyko darbo dienomis ir savaitgaliais, skaičių
-- ir generuotas sumas
SELECT
    CASE
        WHEN DAYOFWEEK(r.rental_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(r.rental_id) AS rental_count,
    SUM(p.amount) AS total_amount
FROM rental AS r
INNER JOIN payment AS p
    ON r.rental_id = p.rental_id
GROUP BY day_type
ORDER BY day_type ASC;

-- 8. Išveskite aktorius, kurių vardai yra ilgesni nei 6 simboliai.
SELECT
    a.first_name,
    a.last_name
FROM actor AS a
WHERE LENGTH(a.first_name) > 6
ORDER BY
    a.first_name ASC,
    a.last_name ASC;

-- 9. Išveskite filmų pavadinimus kartu su jų kategorijomis, sudarytą viename
-- stulpelyje.
SELECT CONCAT(f.title, ' (', c.name, ')') AS title_with_category
FROM film AS f
INNER JOIN film_category AS fc
    ON f.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id
ORDER BY title_with_category ASC;

-- 10. Raskite aktoriaus pilną vardą ir kiek filmų jis (ji) suvaidino.
SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS full_name,
    COUNT(fa.film_id) AS film_count
FROM actor AS a
LEFT JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY
    a.actor_id,
    full_name
ORDER BY
    film_count DESC,
    full_name ASC;

-- 11. Parodykite nuomų, kurios buvo grąžintos vėluojant 3 dienas ar daugiau,
-- skaičių.
SELECT COUNT(*) AS late_rental_count
FROM rental AS r
INNER JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
    ON i.film_id = f.film_id
WHERE DATEDIFF(r.return_date, r.rental_date) >= f.rental_duration + 3;

-- 12. Raskite visų filmų pavadinimų raidžių skaičių vidurkį.
SELECT ROUND(AVG(CHAR_LENGTH(title)), 2) AS avg_title_length
FROM film;

-- 13. Išveskite klientus, kurių vardai prasideda raide „M“, ir parodykite jų
-- mokėjimų sumą.
SELECT
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_paid
FROM customer AS c
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
WHERE c.first_name LIKE 'M%'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_paid DESC;

-- 14. Apskaičiuokite, kokią pajamų dalį sudaro nuomos, kurios truko mažiau nei
-- 5 dienas.
SELECT
    SUM(
        CASE
            WHEN
                r.return_date IS NOT NULL
                AND DATEDIFF(r.return_date, r.rental_date) < 5
                THEN p.amount
            ELSE 0
        END
    ) / SUM(p.amount) AS short_rental_share
FROM rental AS r
INNER JOIN payment AS p
    ON r.rental_id = p.rental_id;

-- 15. Parodykite filmų trukmes, sugrupuotas pagal intervalus (pvz., 0-60 min,
-- 61-120 min ir t. t.).
SELECT
    CASE
        WHEN f.length BETWEEN 0 AND 60 THEN '0-60'
        WHEN f.length BETWEEN 61 AND 120 THEN '61-120'
        WHEN f.length BETWEEN 121 AND 180 THEN '121-180'
        ELSE '181+'
    END AS length_interval,
    COUNT(*) AS film_count
FROM film AS f
GROUP BY
    CASE
        WHEN f.length BETWEEN 0 AND 60 THEN '0-60'
        WHEN f.length BETWEEN 61 AND 120 THEN '61-120'
        WHEN f.length BETWEEN 121 AND 180 THEN '121-180'
        ELSE '181+'
    END
ORDER BY length_interval ASC;

-- 16. Klientai su paskutine nuomos data ir jos mėnesiu
SELECT
    c.first_name,
    c.last_name,
    MAX(r.rental_date) AS last_rental_date,
    MONTH(MAX(r.rental_date)) AS last_rental_month
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY last_rental_date DESC;

-- 17. Kiek nuomų atliko kiekvienas klientas (vardas pavardė sujungti)
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
LEFT JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    full_name
ORDER BY rental_count DESC;

-- 18. Rodyti kiekvienos nuomos trukmę dienomis
SELECT
    r.rental_id,
    DATEDIFF(r.return_date, r.rental_date) AS rental_days
FROM rental AS r
WHERE r.return_date IS NOT NULL
ORDER BY r.rental_id ASC;

-- 19. Priskirti klientui kategoriją pagal jų generuotas sumas (CASE)
SELECT
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_paid,
    CASE
        WHEN SUM(p.amount) < 50 THEN 'Low'
        WHEN SUM(p.amount) BETWEEN 50 AND 150 THEN 'Medium'
        ELSE 'High'
    END AS customer_category
FROM customer AS c
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_paid DESC;
