-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- SQL - Joins tasks
-- ----------------------------------------------
-- Atlikti žemiau aprašytas užduotis iš sakila duomenų bazės.
-- ----------------------------------------------

USE sakila;

-- 1. Suskaičiuoti, kiek yra aktorių, kurių pavardės prasideda A ir B raidėmis.
-- Rezultatas: aktorių skaičius ir pavardės pirmąją raidę.
SELECT
    LEFT(a.last_name, 1) AS last_initial,
    COUNT(*) AS actor_count
FROM actor AS a
WHERE
    a.last_name LIKE 'A%'
    OR a.last_name LIKE 'B%'
GROUP BY LEFT(a.last_name, 1)
ORDER BY last_initial;

-- 2. Suskaičiuoti kiek filmų yra nusifilmavę aktoriai.
-- Rezultatas: filmų skaičius, aktoriaus vardas ir pavardė.
-- Pateikti 10 aktorių, nusifilmavusių daugiausiai filmų (TOP 10).
SELECT
    a.actor_id,
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS film_count
FROM
    actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY film_count DESC
LIMIT 10;

-- 3. Nustatyti kokia yra minimali, maksimali ir vidutinė kaina, sumokama už
-- filmą.
-- Rezultatas: pateikti tik minimalią, maksimalią ir vidutinę kainas.
SELECT
    MIN(p.amount) AS min_amount,
    MAX(p.amount) AS max_amount,
    ROUND(AVG(p.amount), 2) AS avg_amount
FROM payment AS p;

-- 4. Suskaičiuoti, kiek kiekviena parduotuvė turi klientų.
SELECT
    store_id,
    COUNT(*) AS customer_count
FROM customer
GROUP BY store_id
ORDER BY store_id;

-- 5. Suskaičiuoti kiek yra kiekvieno žanro filmų.
-- Rezultatas: filmų skaičius ir žanro pavadinimą. Rezultatą surikiuoti pagal
-- filmų skaičių mažėjimo tvarka.
SELECT
    c.name AS genre,
    COUNT(fc.film_id) AS film_count
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
GROUP BY c.category_id, c.name
ORDER BY film_count DESC;

-- 6. Sužinoti, kuriame filme vaidino daugiausiai aktorių.
-- Rezultatas: filmo pavadinimas ir aktorių skaičius.
SELECT
    f.title,
    COUNT(fa.actor_id) AS actor_count
FROM film AS f
INNER JOIN film_actor AS fa
    ON f.film_id = fa.film_id
GROUP BY f.film_id, f.title
ORDER BY actor_count DESC
LIMIT 1;

-- 7. Pateikti filmus ir juose vaidinusius aktorius.
-- Rezultatas: filmo pavadinimas, aktoriaus vardas ir pavardė. Rezultate turi
-- būti rodomi tik filmai, kurių identifikatoriaus (film_id) reikšmė yra nuo 1
-- iki 2. Duomenys rūšiuojami pagal filmo pavadinimą, aktoriaus vardą ir
-- pavardę didėjančia tvarka.
SELECT
    f.title,
    a.first_name,
    a.last_name
FROM film AS f
INNER JOIN film_actor AS fa
    ON f.film_id = fa.film_id
INNER JOIN actor AS a
    ON fa.actor_id = a.actor_id
WHERE f.film_id BETWEEN 1 AND 2
ORDER BY
    f.title ASC,
    a.first_name ASC,
    a.last_name ASC;

-- 8. Suskaičiuoti, kiek filmų yra nusifilmavęs kiekvienas aktorius.
-- Rezultatas: aktoriaus vardas, pavardė, filmų skaičius. Rezultatą surikiuoti
-- pagal filmų skaičių mažėjančia tvarka ir pagal aktoriaus vardą didėjančia
-- tvarka.
SELECT
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS film_count
FROM actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY
    film_count DESC,
    a.first_name ASC;

-- 9. Suskaičiuoti kiek miestų prasideda A, B, C ir D raidėmis.
-- Rezultatas: miestų skaičius ir miesto pavadinimo pirmoji raidė.
SELECT
    LEFT(ci.city, 1) AS city_initial,
    COUNT(*) AS city_count
FROM city AS ci
WHERE LEFT(ci.city, 1) IN ('A', 'B', 'C', 'D')
GROUP BY LEFT(ci.city, 1)
ORDER BY city_initial;

-- 10. Suskaičiuoti, kiek kiekvienas klientas yra sumokėjęs pinigų už filmų
-- nuomą.
-- Rezultatas: kliento vardas, pavardė, adresas, apygarda (district) ir
-- sumokėta pinigų suma. Turi būti pateikiami tik tie klientai, kurie yra
-- sumokėję 170 ar didesnę pinigų sumą.
SELECT
    c.first_name,
    c.last_name,
    a.address,
    a.district,
    SUM(p.amount) AS total_paid
FROM customer AS c
INNER JOIN address AS a
    ON c.address_id = a.address_id
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    a.address,
    a.district
HAVING SUM(p.amount) >= 170
ORDER BY total_paid DESC;

-- 11. Suskaičiuoti, kiek pinigų už filmus yra sumokėję kiekvienos apygardos
-- klientai kartu.
-- Rezultatas: apygardą (district) ir išleista pinigų suma. Pateikti tik tas
-- apygardas, kurios yra išleidusios daugiau nei 700 pinigų. Duomenis
-- surūšiuoti pagal apygardą didėjančia tvarka.
SELECT
    a.district,
    SUM(p.amount) AS district_total
FROM customer AS c INNER JOIN address AS a ON c.address_id = a.address_id
INNER JOIN payment AS p ON c.customer_id = p.customer_id
GROUP BY a.district
HAVING SUM(p.amount) > 700
ORDER BY a.district ASC;

-- 12. Suskaičiuoti, kiek filmų nusifilmavo kiekvienas aktorius priklausomai
-- nuo filmo žanro (kategorijos).
-- Rezultatas: aktoriaus vardas ir pavardė, filmo žanras, filmų skaičius
-- (kategorija). Rezultatą surūšiuoti pagal aktoriaus vardą, pavardę, filmo
-- žanrą didėjančia tvarka.
SELECT
    a.first_name,
    a.last_name,
    c.name AS genre,
    COUNT(fa.film_id) AS film_count
FROM actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
INNER JOIN film_category AS fc
    ON fa.film_id = fc.film_id
INNER JOIN category AS c
    ON fc.category_id = c.category_id
GROUP BY
    a.actor_id,
    a.first_name,
    a.last_name,
    c.category_id,
    c.name
ORDER BY
    a.first_name ASC,
    a.last_name ASC,
    c.name ASC;

-- 13. Suskaičiuoti kiek filmų savo filmo aprašyme turi žodį „drama“. (Kiek
-- kartų žodis pasikartoja nėra svarbu).
-- Rezultatas: tik filmų skaičius ir filmo žanras. Pateikti tik tuos filmų
-- žanrus, kurie turi 7 ir daugiau filmų, kuriuose yra žodis „drama“ (filmo
-- aprašymui naudoti lauką iš lentos film_text).
SELECT
    c.name AS genre,
    COUNT(ft.film_id) AS drama_film_count
FROM film_text AS ft
INNER JOIN film_category AS fc ON ft.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
WHERE
    ft.description LIKE '% drama %'
    OR ft.description LIKE '% drama'
    OR ft.description LIKE 'drama %'
GROUP BY c.name
HAVING COUNT(ft.film_id) >= 7
ORDER BY drama_film_count DESC;

-- 14. Suskaičiuoti kiek klientų yra kiekvienoje šalyje.
-- Rezultatas: klientų skaičius ir šalis. Duomenis surikiuoti pagal klientų
-- skaičių mažėjančia tvarka. Pateikti tik 5 šalis, turinčias daugiausiai
-- klientų.
SELECT
    co.country,
    COUNT(c.customer_id) AS customer_count
FROM customer AS c
INNER JOIN address AS a
    ON c.address_id = a.address_id
INNER JOIN city AS ci
    ON a.city_id = ci.city_id
INNER JOIN country AS co
    ON ci.country_id = co.country_id
GROUP BY co.country_id, co.country
ORDER BY customer_count DESC
LIMIT 5;

-- 15. Suskaičiuoti kiekvienoje parduotuvėje bendrai visų klientų sumokėtą
-- sumą.
-- Rezultatas: parduotuvės identifikatorius (store_id), parduotuvės adresas,
-- miestas ir šalis, ir bendra sumokėtų mokėjimų suma.
SELECT
    st.store_id,
    a.address,
    ci.city,
    co.country,
    SUM(p.amount) AS total_amount
FROM store AS st
INNER JOIN customer AS c
    ON st.store_id = c.store_id
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
INNER JOIN address AS a
    ON st.address_id = a.address_id
INNER JOIN city AS ci
    ON a.city_id = ci.city_id
INNER JOIN country AS co
    ON ci.country_id = co.country_id
GROUP BY
    st.store_id,
    a.address,
    ci.city,
    co.country
ORDER BY st.store_id;
