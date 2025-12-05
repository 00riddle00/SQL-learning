-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- SQL - Subqueries tasks Sakila (Optional)
-- 10 subqueries užduočių iš Sakila duomenų bazės su sprendimais, apimančių
-- įvairius subquery tipus: single-row, multi-row, correlated, nested, scalar
-- ----------------------------------------------

USE sakila;

-- 1. Single-row subquery
-- Rask filmus, kurių trukmė didesnė už vidutinę visų filmų trukmę.
SELECT
    f.film_id,
    f.title,
    f.length
FROM film AS f
WHERE
    f.length > (
        SELECT AVG(f2.length)
        FROM film AS f2
    )
ORDER BY f.length DESC;

-- 2. Multi-row subquery (IN)
-- Rask klientus, kurių address_id naudojamas bent vienoje nuomoje.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.address_id
FROM customer AS c
WHERE
    c.customer_id IN (
        SELECT r.customer_id
        FROM rental AS r
    )
ORDER BY
    c.last_name ASC,
    c.first_name ASC;

-- 3. Correlated subquery (nuomų skaičius)
-- Rodyk kiekvieną klientą ir kiek nuomų jis atliko.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    (
        SELECT COUNT(*)
        FROM rental AS r
        WHERE r.customer_id = c.customer_id
    ) AS rental_count
FROM customer AS c
ORDER BY rental_count DESC;

-- 4. Nested subquery (per kategoriją)
-- Rask filmus, kurie priklauso kategorijai „Comedy“.
SELECT
    f.film_id,
    f.title
FROM film AS f
WHERE
    f.film_id IN (
        SELECT fc.film_id
        FROM film_category AS fc
        WHERE fc.category_id = (
            SELECT c.category_id
            FROM category AS c
            WHERE c.name = 'Comedy'
        )
    )
ORDER BY f.title ASC;

-- 5. Scalar subquery (vidutinė trukmė)
-- Prie kiekvieno filmo parodyk vidutinę filmų trukmę.
SELECT
    f.film_id,
    f.title,
    f.length,
    (
        SELECT AVG(f2.length)
        FROM film AS f2
    ) AS avg_length_all
FROM film AS f
ORDER BY f.film_id ASC;

-- 6. EXISTS (correlated)
-- Rask klientus, kurie atliko bent vieną nuomą.
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer AS c
WHERE
    EXISTS (
        SELECT 1
        FROM rental AS r
        WHERE r.customer_id = c.customer_id
    )
ORDER BY
    c.last_name ASC,
    c.first_name ASC;

-- 7. CASE + subquery
-- Žymėk klientus pagal jų nuomų kiekį:
-- • daugiau nei 20 → 'VIP'
-- • 10–20 → 'Active'
-- • kitaip → 'New'
SELECT
    t.customer_id,
    t.first_name,
    t.last_name,
    t.rental_count,
    CASE
        WHEN t.rental_count > 20 THEN 'VIP'
        WHEN t.rental_count BETWEEN 10 AND 20 THEN 'Active'
        ELSE 'New'
    END AS customer_status
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(r.rental_id) AS rental_count
    FROM customer AS c
    LEFT JOIN rental AS r
        ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
) AS t
ORDER BY t.rental_count DESC;

-- 8. Subquery FROM dalyje (inline view)
-- Rask klientus, turinčius daugiau nei 15 nuomų.
SELECT
    t.customer_id,
    t.first_name,
    t.last_name,
    t.rental_count
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COUNT(r.rental_id) AS rental_count
    FROM customer AS c
    LEFT JOIN rental AS r
        ON c.customer_id = r.customer_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
) AS t
WHERE t.rental_count > 15
ORDER BY t.rental_count DESC;

-- 9. Multi-row subquery su NOT IN
-- Rask filmus, kurie nepriklauso jokioms kategorijoms.
SELECT
    f.film_id,
    f.title
FROM film AS f
WHERE
    f.film_id NOT IN (
        SELECT fc.film_id
        FROM film_category AS fc
    )
ORDER BY f.title ASC;

-- 10. Subquery + CAST – procentas
-- Suskaičiuok kiekvieno filmo nuomos procentą nuo visų nuomų, suapvalinti
-- iki 2 sk. po kablelio.
SELECT
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS rental_count,
    ROUND(
        100 * CAST(COUNT(r.rental_id) AS DECIMAL(10, 4)) / (
            SELECT COUNT(*)
            FROM rental
        ),
        2
    ) AS rental_percent
FROM film AS f
LEFT JOIN inventory AS i
    ON f.film_id = i.film_id
LEFT JOIN rental AS r
    ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id,
    f.title
ORDER BY rental_percent DESC;
