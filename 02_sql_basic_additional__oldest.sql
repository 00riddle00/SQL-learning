-- ----------------------------------------------
-- SQL - 1 Basic Additional.pdf
-- ----------------------------------------------
-- Užduotims atlikti reikalingos šios sakila duomenų bazės lentelės:
-- rental, payment, film_category, film, actor, address, customer
-- ----------------------------------------------

USE sakila;

-- 1. Kiek skirtingų prekių buvo išnuomota?
SELECT COUNT(DISTINCT inventory_id) AS unique_items_rented
FROM rental;

-- 2. Top 5 klientai pagal nuomos kartų skaičių
SELECT customer_id, COUNT(*) AS rental_count
FROM rental
GROUP BY customer_id
ORDER BY rental_count DESC
LIMIT 5;

-- 3. Nuomos ID, kurių nuomos ir grąžinimo datos sutampa
-- (reikia date() funkcijos)
SELECT rental_id, rental_date, return_date
FROM rental
WHERE DATE(rental_date) = DATE(return_date)
ORDER BY rental_date DESC;

-- 4. Kuris klientas išleido daugiausia pinigų nuomos paslaugoms?
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       SUM(p.amount) AS total_spent
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- 5. Kiek klientų aptarnavo kiekvienas darbuotojas + kiek pinigų surinko?
SELECT staff_id,
       COUNT(DISTINCT customer_id) AS unique_customers,
       SUM(amount) AS total_amount
FROM payment
GROUP BY staff_id;

-- 6. Visi nuomos ID, kurie prasideda „9“, skaičiuoti vertę ir rikiuoti mažėjančiai
SELECT rental_id,
       (SELECT rental_duration FROM film f
        JOIN inventory i ON i.film_id = f.film_id
        WHERE i.inventory_id = r.inventory_id) AS duration_value
FROM rental r
WHERE rental_id LIKE '9%'
ORDER BY duration_value DESC;
-- (Jeigu norite, galiu pateikti paprastesnę alternatyvą.)

-- 7. Kuri kategorija turi mažiausiai filmų?
SELECT c.name, COUNT(*) AS film_count
FROM film_category fc
JOIN category c ON c.category_id = fc.category_id
GROUP BY c.name
ORDER BY film_count ASC
LIMIT 1;

-- 8. Filmų aprašymai, kurių rating = 'R' ir description turi 'MySQL'
SELECT title, description
FROM film
WHERE rating = 'R'
  AND description LIKE '%MySQL%'
ORDER BY length(description);

-- 9. Surasti filmus, kurių trukmė 46, 47, 48, 49, 50, 51 minutė
SELECT film_id, title, length
FROM film
WHERE length IN (46,47,48,49,50,51)
ORDER BY length ASC;

-- 10. Filmų pavadinimai, prasidedantys „G“ ir trukmė < 70 min
SELECT title
FROM film
WHERE title LIKE 'G%'
  AND length < 70;

-- 11. Kiek yra aktorių, kurių pavardė prasideda ‘A’ arba baigiasi ‘W’?
SELECT COUNT(*) AS actor_count
FROM actor
WHERE last_name LIKE 'A%'
   OR last_name LIKE '%W';

-- 12. Kiek klientų, kurių pavardėje dviguba O („OO“)?
SELECT COUNT(*) AS count_customers
FROM customer
WHERE last_name LIKE '%OO%';

-- 13. Kiek rajonų turi skirtingus adresus?
-- Pateikti tuos rajonus, kuriuose adresų skaičius didesnis nei 9.
SELECT district, COUNT(*) AS address_count
FROM address
GROUP BY district
HAVING COUNT(*) > 9;

-- 14. Unikalūs rajonai, kurie baigiasi raide „D“
SELECT DISTINCT district
FROM address
WHERE district LIKE '%D';

-- 15. Adresai ir rajonai, kur telefono numeris prasideda ir baigiasi '9'
SELECT address, district, phone
FROM address
WHERE phone LIKE '9%9';
