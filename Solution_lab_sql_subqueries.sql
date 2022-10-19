-- lab-sql-subqueries (SQL Subqueries 3.03)

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT f.title, COUNT(i.inventory_id) AS number_of_copies FROM inventory AS i
JOIN film AS f
ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;
-- 6 copies

-- 2. List all films whose length is longer than the average of all the films.

SELECT film.title, film.length FROM film
WHERE length > (SELECT AVG(film.length) FROM film);


-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT a.actor_id, a.first_name, a.last_name FROM actor AS a
JOIN film_actor AS fa
ON fa.actor_id = a.actor_id
JOIN film AS f
ON f.film_id = fa.film_id
WHERE f.film_id IN (SELECT f.film_id FROM film
WHERE film.title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.

SELECT f.film_id, f.title FROM film AS f
JOIN film_category AS fc
ON f.film_id = fc.film_id
JOIN category AS c
ON c.category_id = fc.category_id 
WHERE c.category_id IN (SELECT category.category_id FROM category
WHERE category.name = 'Family');


-- 5. Get name and email from customers from Canada using subqueries.
-- Do the same with joins. Note that to create a join,
-- you will have to identify the correct tables with their primary keys and foreign keys,
-- that will help you get the relevant information.

-- SUBQUERY
SELECT cu.first_name, cu.last_name, cu.email FROM customer as cu
JOIN address AS a
ON cu.address_id = a.address_id
JOIN city AS ci
ON ci.city_id = a.city_id
JOIN country AS co
ON co.country_id = ci.country_id
WHERE ci.country_id IN (SELECT country.country_id FROM country WHERE country.country = 'Canada');

-- JOIN
SELECT cu.first_name, cu.last_name, cu.email FROM customer as cu
JOIN address AS a
ON cu.address_id = a.address_id
JOIN city AS ci
ON ci.city_id = a.city_id
JOIN country AS co
ON co.country_id = ci.country_id
WHERE co.country = 'Canada';


-- 6. Which are films starred by the most prolific actor?
-- Most prolific actor is defined as the actor that has acted in the most number of films.
-- First you will have to find the most prolific actor and
-- then use that actor_id to find the different films that he/she starred.

-- it gives us all the films, all the actors and number of films for each actor
SELECT film.film_id, film.title, sub_1.first_name, sub_1.last_name, sub_1.number_of_films FROM film
JOIN film_actor
ON film.film_id = film_actor.film_id
JOIN (SELECT 
a.actor_id AS actor_id,
a.first_name AS first_name,
a.last_name AS last_name,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY actor_id) AS sub_1
ON film_actor.actor_id = sub_1.actor_id


-- it searches for the max number of films
SELECT MAX(sub.number_of_films) FROM (SELECT 
a.actor_id AS actor_id,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY a.actor_id) AS sub;

-- then I can use it as a subquery
SELECT film.film_id, film.title, sub_1.number_of_films FROM film
JOIN film_actor
ON film.film_id = film_actor.film_id
JOIN (SELECT 
a.actor_id AS actor_id,
a.first_name AS first_name,
a.last_name AS last_name,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY actor_id) AS sub_1
ON film_actor.actor_id = sub_1.actor_id
HAVING sub_1.number_of_films = (SELECT MAX(sub.number_of_films) FROM (SELECT 
a.actor_id AS actor_id,
COUNT(f.film_id) AS number_of_films
FROM film AS f
JOIN film_actor AS fa
ON f.film_id = fa.film_id
JOIN actor AS a
ON fa.actor_id = a.actor_id
GROUP BY a.actor_id) AS sub);

-- 7. Films rented by most profitable customer. 
-- You can use the customer table and payment table to find the most profitable customer
-- ie the customer that has made the largest sum of payments

-- find total amount for each customer
SELECT c.customer_id, SUM(p.amount) AS total_amount FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id;


-- find the max total
SELECT MAX(sub_1.total_amount) as max_total_amount FROM
(SELECT c.customer_id, SUM(p.amount) AS total_amount FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id) AS sub_1;


-- Now I can use it as a subquery

SELECT f.film_id, f.title FROM film AS f
JOIN inventory AS i
ON i.film_id = f.film_id 
JOIN rental AS r
ON r.inventory_id = i.inventory_id
JOIN 
(SELECT c.customer_id, SUM(p.amount) AS total_amount FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id) AS sub_1
ON sub_1.customer_id = r.customer_id
HAVING sub_1.total_amount = (SELECT MAX(sub_1.total_amount) as max_total_amount FROM
(SELECT c.customer_id, SUM(p.amount) AS total_amount FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id) AS sub_1);


-- 8. Customers who spent more than the average payments.

SELECT c.customer_id, c.first_name, c.last_name FROM customer AS c
JOIN payment AS p
ON c.customer_id = p.customer_id
WHERE p.amount > (SELECT AVG(amount) FROM payment);