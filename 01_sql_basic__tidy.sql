-- vim:fenc=utf-8:tw=79:nu:ai:si:et:ts=4:sw=4

-- ----------------------------------------------
-- SQL - Basic
-- Atlikti žemiau aprašytas užduotis iš sakila duomenų bazės film lentelės.
-- ----------------------------------------------

USE sakila;

-- 1. Susumuoti filmų nuomos trukmes.
SELECT SUM(rental_duration) AS total_rental_duration
FROM film;

-- 2. Suskaičiuoti, kiek yra skirtingų rating reikšmių.
SELECT COUNT(DISTINCT rating) AS unique_ratings
FROM film;

-- 3. Išrinkti unikalias rating reikšmes.
SELECT DISTINCT rating
FROM film;

-- 4. Susumuoti filmų nuomos trukmes pagal rating dimensiją.
SELECT
    rating,
    SUM(rental_duration) AS total_rental_duration
FROM film
GROUP BY rating;

-- 5. Pateikti trumpiausią ir ilgiausią nuomos trukmes.
SELECT
    MIN(rental_duration) AS shortest,
    MAX(rental_duration) AS longest
FROM film;

-- 6. Išrinkti visus filmus, kurių nuomos trukmė didesnė arba lygi 6.
-- Rezultatas: film_id, title, description
SELECT
    film_id,
    title,
    description
FROM film
WHERE rental_duration >= 6;

-- 7. Kiek yra tokių filmų, kurių nuomos trukmė didesnė arba lygi 6?
SELECT COUNT(*) AS count_films
FROM film
WHERE rental_duration >= 6;

-- 8. Suskaičiuoti vidutinę nuomos trukmę, pagal dimensijas rating ir
-- special_features.
SELECT
    rating,
    special_features,
    AVG(rental_duration) AS avg_duration
FROM film
GROUP BY rating, special_features;

-- 9. Susumuoti replacement_cost pagal dimensiją special_features ir rezultatą
-- pateikti mažėjimo tvarka.
SELECT
    special_features,
    SUM(replacement_cost) AS total_replacement_cost
FROM film
GROUP BY special_features
ORDER BY total_replacement_cost DESC;

-- 10. Išrinkti filmus, kurių pavadinimas prasideda raide 'U'. 
-- Rezultatas: film_id, title, description, rating.
SELECT
    film_id,
    title,
    description,
    rating
FROM film
WHERE title LIKE 'U%';

-- 11. Išrinkti filmus, kur special_features turi reikšmę 'Deleted Scenes'.
-- Rezultatas: title, special_features.
SELECT
    title,
    special_features
FROM film
WHERE special_features LIKE '%Deleted Scenes%';

-- 12. Išrinkti filmus, kai nuomos trukmė yra 3 ir reitingas NC-17.
-- Rezultatas: film_id, title, rental_duration, rating
SELECT
    film_id,
    title,
    rental_duration,
    rating
FROM film
WHERE
    rental_duration = 3
    AND rating = 'NC-17';

-- 13. Išrinkti filmus, kai nuomos trukmė yra 4 arba 5, ir pavadinimas
-- prasideda raide 'V'.
-- Rezultatas: title, rental_duration.
SELECT
    title,
    rental_duration
FROM film
WHERE
    rental_duration IN (4, 5)
    AND title LIKE 'V%';
