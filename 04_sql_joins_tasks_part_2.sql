-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- SQL - Joins Tasks: Part 2
-- ----------------------------------------------

USE sakila;

-- 1. Raskite, kuriame filme vaidino daugiausia aktorių.
-- Rezultatas: Filmo pavadinimas ir aktorių skaičius.
SELECT
    f.title,
    COUNT(fa.actor_id) AS actor_count
FROM film AS f
INNER JOIN film_actor AS fa
    ON f.film_id = fa.film_id
GROUP BY
    f.film_id,
    f.title
ORDER BY actor_count DESC
LIMIT 1;

-- 2. Kiek kartų filmas „Academy Dinosaur“ buvo išnuomotas parduotuvėje, kurios
-- ID yra 1?
-- Rezultatas: Išnuomotų filmų skaičius.
SELECT COUNT(r.rental_id) AS rental_count
FROM film AS f
INNER JOIN inventory AS i
    ON f.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
WHERE
    f.title = 'Academy Dinosaur'
    AND i.store_id = 1;

-- 3. Išvardinkite trijų populiariausių filmų pavadinimus.
-- Rezultatas: Filmo pavadinimas, nuomos kartai.
SELECT
    f.title,
    COUNT(r.rental_id) AS rental_count
FROM film AS f
INNER JOIN inventory AS i
    ON f.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id,
    f.title
ORDER BY rental_count DESC
LIMIT 3;

-- 4. Suskaičiuokite, kiek filmų yra nusifilmavę aktoriai.
-- Rezultatas: Filmų skaičius, aktoriaus vardas ir pavardė.
-- Papildoma sąlyga: Pateikite 10 aktorių, nusifilmavusių daugiausiai filmų
-- (Top 10).
SELECT
    a.first_name,
    a.last_name,
    COUNT(fa.film_id) AS film_count
FROM actor AS a
INNER JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
GROUP BY
    a.actor_id,
    a.first_name,
    a.last_name
ORDER BY
    film_count DESC,
    a.first_name ASC,
    a.last_name ASC
LIMIT 10;

-- 5. Suskaičiuokite, kiek yra kiekvieno žanro filmų ir kokia yra vidutinė
-- kiekvieno žanro filmo trukmė. 
-- Rezultatas: Filmų skaičius ir žanro pavadinimas.
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal vidutinę filmo trukmę
-- mažėjimo tvarka.
SELECT
    c.name AS category_name,
    COUNT(f.film_id) AS film_count,
    ROUND(AVG(f.length), 2) AS avg_length
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN film AS f
    ON fc.film_id = f.film_id
GROUP BY
    c.category_id,
    c.name
ORDER BY avg_length DESC;

-- 6. Pateikite filmus, kurių film_id reikšmė yra nuo 1 iki 5, ir juose
-- vaidinusius aktorius.
-- Rezultatas: Filmo pavadinimas, aktoriaus vardas ir pavardė.
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal filmo pavadinimą didėjimo
-- tvarka ir pagal aktoriaus vardą bei pavardę mažėjimo tvarka.
SELECT
    f.title,
    a.first_name,
    a.last_name
FROM film AS f
INNER JOIN film_actor AS fa
    ON f.film_id = fa.film_id
INNER JOIN actor AS a
    ON fa.actor_id = a.actor_id
WHERE f.film_id BETWEEN 1 AND 5
ORDER BY
    f.title ASC,
    a.first_name DESC,
    a.last_name DESC;

-- 7. Suskaičiuokite, kiek kiekvienas klientas yra sumokėjęs už filmų nuomą.
-- Rezultatas: Kliento vardas, pavardė, adresas ir sumokėta suma.
-- Papildoma sąlyga: Pateikite tik tuos klientus, kurie yra sumokėję 170 ar
-- didesnę sumą.
SELECT
    c.first_name,
    c.last_name,
    a.address,
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
    a.address
HAVING SUM(p.amount) >= 170
ORDER BY total_paid DESC;

-- 8. Raskite, kiek filmų nusifilmavo kiekvienas aktorius, priklausomai nuo
-- filmo žanro.
-- Rezultatas: Filmų skaičius, aktoriaus vardas ir pavardė, filmo žanras.
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal aktoriaus vardą, pavardę ir
-- filmo žanrą didėjimo tvarka.
SELECT
    a.first_name,
    a.last_name,
    c.name AS category_name,
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

-- 9. Suskaičiuokite, kiek klientų yra kiekvienoje šalyje.
-- Rezultatas: Šalis ir klientų skaičius.
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal klientų skaičių mažėjimo
-- tvarka. Pateikite tik 5 šalis, turinčias daugiausiai klientų.
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
GROUP BY
    co.country_id,
    co.country
ORDER BY customer_count DESC
LIMIT 5;

-- 10. Kuris filmas atnešė didžiausias pajamas?
-- Rezultatas: Filmo pavadinimas ir pajamos.
SELECT
    f.title,
    SUM(p.amount) AS total_revenue
FROM film AS f
INNER JOIN inventory AS i
    ON f.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
    ON r.rental_id = p.rental_id
GROUP BY
    f.film_id,
    f.title
ORDER BY total_revenue DESC
LIMIT 1;

-- 11. Kiek kartų buvo nuomojamasi kiekvienoje šalyje?
-- Rezultatas: Šalies pavadinimas, nuomos kartai.
-- Papildoma sąlyga: Išvardinkite tik tas šalis, kuriose buvo nuomojamasi bent
-- kartą. Rezultatus išrikiuokite pagal nuomos kartus mažėjimo tvarka.
SELECT
    co.country,
    COUNT(r.rental_id) AS rental_count
FROM country AS co
INNER JOIN city AS ci
    ON co.country_id = ci.country_id
INNER JOIN address AS a
    ON ci.city_id = a.city_id
INNER JOIN customer AS c
    ON a.address_id = c.address_id
INNER JOIN rental AS r
    ON c.customer_id = r.customer_id
GROUP BY
    co.country_id,
    co.country
HAVING COUNT(r.rental_id) >= 1
ORDER BY rental_count DESC;

-- 12. Kiek kartų kiekviena filmo kategorija buvo išnuomota?
-- Rezultatas: Kategorijos pavadinimas, nuomos kartai.
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal nuomos kartus mažėjimo
-- tvarka.
SELECT
    c.name AS category_name,
    COUNT(r.rental_id) AS rental_count
FROM category AS c
INNER JOIN film_category AS fc
    ON c.category_id = fc.category_id
INNER JOIN film AS f
    ON fc.film_id = f.film_id
INNER JOIN inventory AS i
    ON f.film_id = i.film_id
INNER JOIN rental AS r
    ON i.inventory_id = r.inventory_id
GROUP BY
    c.category_id,
    c.name
ORDER BY rental_count DESC;

-- 13. Raskite kiekvienoje parduotuvėje bendrai visų klientų sumokėtą sumą.
-- Rezultatas: Parduotuvės ID, adresas, miestas, šalis ir pajamos.
SELECT
    s.store_id,
    a.address,
    ci.city,
    co.country,
    SUM(p.amount) AS total_revenue
FROM store AS s
INNER JOIN customer AS c
    ON s.store_id = c.store_id
INNER JOIN payment AS p
    ON c.customer_id = p.customer_id
INNER JOIN address AS a
    ON s.address_id = a.address_id
INNER JOIN city AS ci
    ON a.city_id = ci.city_id
INNER JOIN country AS co
    ON ci.country_id = co.country_id
GROUP BY
    s.store_id,
    a.address,
    ci.city,
    co.country
ORDER BY s.store_id;

-- 14. Išvardinkite lankytojus, kurie nuomavosi „sci-fi“ žanro filmus daugiau
-- nei du kartus.
-- Rezultatas: Lankytojo vardas, pavardė, nuomos kartai.
-- Papildoma sąlyga: Rezultatus išrikiuokite pagal nuomos kartus didėjimo
-- tvarka.
SELECT
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS rental_count
FROM customer AS c
INNER JOIN rental AS r
    ON c.customer_id = r.customer_id
INNER JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
    ON i.film_id = f.film_id
INNER JOIN film_category AS fc
    ON f.film_id = fc.film_id
INNER JOIN category AS cat
    ON fc.category_id = cat.category_id
WHERE cat.name = 'Sci-Fi'
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(r.rental_id) > 2
ORDER BY rental_count ASC;
