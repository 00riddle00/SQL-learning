-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- SQL - Basic Additional
-- ----------------------------------------------
-- Užduotims atlikti reikalingos šios sakila duomenų bazės lentelės:
-- rental, payment, film_category, film, actor, address, customer
-- ----------------------------------------------

USE sakila;

-- 1. Kiek skirtingų prekių buvo išnuomota?
SELECT COUNT(DISTINCT inventory_id) AS unique_items_rented
FROM rental;

-- 2. Top 5 klientai, kurie daugiausia kartų naudojosi nuomos paslaugomis.
SELECT
    customer_id,
    COUNT(*) AS rental_count
FROM rental
GROUP BY customer_id
ORDER BY rental_count DESC
LIMIT 5;

-- 3. Išrinkti nuomos id, kurių nuomos ir grąžinimo datos sutampa.
-- Rezultatas: nuomos id, nuomos data, grąžinimo data. Pateikti mažėjimo tvarka
-- pagal nuomos id (reikalinga papildoma date() funkcija).
SELECT
    rental_id,
    rental_date,
    return_date
FROM rental
WHERE DATE(rental_date) = DATE(return_date)
ORDER BY rental_id DESC;

-- 4. Kuris klientas išleido daugiausia pinigų nuomos paslaugoms? Pateikti tik
-- vieną klientą ir išleistą pinigų sumą
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spent
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 1;

-- 5. Kiek klientų aptarnavo kiekvienas darbuotojas, kiek nuomos paslaugų
-- pardavė ir už kokią vertę?
SELECT
    staff_id,
    COUNT(DISTINCT customer_id) AS customer_count,
    COUNT(*) AS rental_count,
    SUM(amount) AS total_amount
FROM payment
GROUP BY staff_id;

-- 6. Į ekraną išvesti visus nuomos id, kurie prasideda '9', suskaičiuoti jų
-- vertę, pateikti nuo mažiausio nuomos id. 
SELECT
    rental_id,
    SUM(amount) AS total_value
FROM payment
WHERE rental_id LIKE '9%'
GROUP BY rental_id
ORDER BY rental_id;

-- 7. Kurios kategorijos filmų yra mažiausiai?
SELECT
    c.name,
    COUNT(*) AS film_count
FROM film_category fc
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY film_count ASC
LIMIT 1;

-- 8. Į ekraną išvesti filmų aprašymus, kurių reitingas 'R' ir aprašyme yra
-- žodis 'MySQL'
SELECT
    title,
    description
FROM film
WHERE
    rating = 'R'
    AND description LIKE '%MySQL%';

-- 9. Surasti filmų id, kurių trukmė 46, 47, 48, 49, 50, 51 minutės.
-- Rezultatas: pateikiamas didėjančia tvarka pagal trukmę.
SELECT
    film_id,
    title,
    length
FROM film
WHERE length IN (46, 47, 48, 49, 50, 51)
ORDER BY length ASC;

-- 10. Į ekraną išvesti filmų pavadinimus, kurie prasideda raidė 'G' ir filmo
-- trukmė mažesnė nei 70 minučių.
SELECT title
FROM film
WHERE
    title LIKE 'G%'
    AND length < 70;

-- 11. Suskaičiuoti, kiek yra aktorių, kurių pirmoji vardo raidė yra 'A', o
-- pirmoji pavardės raidė 'W'.
SELECT COUNT(*) AS actor_count
FROM actor
WHERE
    first_name LIKE 'A%'
    AND last_name LIKE 'W%';

-- 12. Suskaičiuoti kiek yra klientų, kurių pavardėje yra dvi O raidės ('OO').
SELECT COUNT(*) AS count_customers
FROM customer
WHERE last_name LIKE '%OO%';

-- 13. Kiek rajonuose skirtingų adresų? Pateikti tuos rajonus, kurių adresų
-- skaičius didesnis arba lygus 9.
SELECT
    district,
    COUNT(*) AS address_count
FROM address
GROUP BY district
HAVING COUNT(*) >= 9;

-- 14. Į ekraną išvesti visus unikalius rajonų pavadinimus, kurie baigiasi
-- raide 'D'.
SELECT DISTINCT district
FROM address
WHERE district LIKE '%D';

-- 15. Į ekraną išvesti adresus ir rajonus, kurių telefono numeris prasideda ir
-- baigiasi skaičiumi '9'.
SELECT
    address,
    district,
    phone
FROM address
WHERE phone LIKE '9%9';
