USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name 
FROM actor;


-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(concat(first_name, " ", last_name)) AS actor_name 
FROM actor;


-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT * 
FROM actor 
WHERE first_name = 'joe';


-- 2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE '%gen%';


-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor 
WHERE last_name LIKE "%li%"
ORDER BY last_name, first_name;


-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE `actor` 
ADD COLUMN `description` BLOB NULL AFTER `last_update`;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE `actor` 
DROP COLUMN `description`;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS count
FROM actor
GROUP BY last_name;


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS name_count
FROM actor
GROUP BY last_name
HAVING COUNT(last_name)> 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address
FROM address a
inner join staff s
on a.address_id = s.address_id;


-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) AS total_amount
FROM staff s
INNER JOIN payment p
on s.staff_id = p.staff_id
WHERE payment_date like '2005-08%'
GROUP BY first_name, last_name;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(actor_id) as actor_count
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY title;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) as hunchback_count
FROM inventory i
INNER JOIN film f
on i.film_id = f.film_id
WHERE title = 'hunchback impossible';


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- 	![Total amount paid](Images/total_payment.png)
SELECT first_name, last_name, sum(amount) as `Total Amount Paid`
FROM customer c
INNER JOIN payment p
on c.customer_id = p.customer_id
GROUP BY first_name, last_name
ORDER BY last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT * FROM film;
SELECT * FROM language;
SELECT title 
FROM film f 
WHERE language_id = (SELECT language_id 
				  FROM language
                  WHERE name = 'english')
AND title like 'K%' OR title like'Q%';
                    

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor 
WHERE actor_id in (SELECT actor_id
				  FROM film_actor
                  WHERE film_id = (SELECT film_id
								   FROM film 
                                   WHERE title = 'alone trip'));


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT  first_name, last_name, email
FROM customer c
INNER JOIN address a
ON c.address_id = a.address_id
INNER JOIN city 
ON a.city_id = city.city_id
INNER JOIN country 
on country.country_id = city.country_id
WHERE country = 'canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title AS family_films
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE c.name = 'family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, count(rental_id) as rental_count
FROM film f
INNER JOIN inventory i
on f.film_id = i.film_id
INNER JOIN rental r
on r.inventory_id = i.inventory_id
GROUP BY title
ORDER BY count(rental_id) DESC;


-- 7f. Write a query to display how much business, in dollars?, each store brought in.
SELECT s.store_id, CONCAT('$', FORMAT(SUM(amount), 2)) AS total_sales
FROM store s
INNER JOIN inventory i
on s. store_id = i.store_id
INNER JOIN rental r
on i.inventory_id = r. inventory_id
INNER JOIN payment p
on r.rental_id = p.rental_id
GROUP BY s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM store s
INNER JOIN address a
ON s.address_id = a.address_id
INNER JOIN city 
on city.city_id = a.city_id
INNER JOIN country c
on c.country_id = city.country_id;



-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT  name, SUM(amount) AS revenue
FROM category c
INNER JOIN film_category fc
on c.category_id = fc.category_id
INNER JOIN inventory i
on i. film_id = fc.film_id
INNER JOIN  rental r
on r.inventory_id = i.inventory_id
INNER JOIN payment p
on r.rental_id = p.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS 
SELECT  name, SUM(amount) AS revenue
FROM category c
INNER JOIN film_category fc
on c.category_id = fc.category_id
INNER JOIN inventory i
on i. film_id = fc.film_id
INNER JOIN  rental r
on r.inventory_id = i.inventory_id
INNER JOIN payment p
on r.rental_id = p.rental_id
GROUP BY name
ORDER BY SUM(amount) DESC LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;