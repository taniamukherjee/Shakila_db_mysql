-- 1a. Display the first and last names of all actors from the table actor.
USE sakila;

SELECT first_name, last_name
FROM actor; 

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT concat(first_name, ' ', last_name) AS 'Actor Name'
FROM actor; 

-- 2a. 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT *
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT *
FROM actor
WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT first_name, last_name  
FROM actor
WHERE last_name LIKE '%li%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.

ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(20) AFTER first_name; 



-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.

ALTER TABLE actor
MODIFY COLUMN middle_name BLOB; 

-- 3c. Now delete the middle_name column.

ALTER TABLE actor
DROP COLUMN middle_name; 

SELECT * FROM actor; 

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name,COUNT(*)
FROM actor
GROUP BY last_name; 

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name,COUNT(*) 
FROM actor
GROUP BY last_name
HAVING COUNT(*)>1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.

SELECT *
FROM actor 
WHERE last_name = 'williams';

UPDATE actor
SET first_name = 'HARPO'
WHERE actor_ID = 172;

SELECT *
FROM actor
WHERE actor_id = 172;


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, 
-- change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY 
-- ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_ID = 172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

DESCRIBE address; 

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:


SELECT s.first_name, s.last_name, a.address
FROM staff s
LEFT JOIN address a
ON s.address_id = a.address_id; 

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.


SELECT	s.first_name AS 'First Name', 
		s.last_name AS 'Last Name', 
        SUM(amount) AS 'Total Sales'
FROM payment p
JOIN staff s
ON p.staff_id = s.staff_id
WHERE MONTH(p.payment_date) = 8 AND YEAR(p.payment_date) = 2005
GROUP BY p.staff_ID; 

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT title AS 'Film Title',
	COUNT(actor_id) as 'Number of Actors'
FROM film f
	INNER JOIN film_actor a on
	a.film_id = f.film_id
GROUP BY title;
	

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT COUNT(inventory_id)
FROM inventory
WHERE film_id IN
(
SELECT film_id
FROM film
WHERE title = 'Hunchback Impossible'
);


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:


SELECT	c.first_name AS 'First Name', 
		c.last_name AS 'Last Name', 
        SUM(amount) AS 'Total Paid'
FROM sakila.payment p
	INNER JOIN customer c ON
	p.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name; 


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also 
-- soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title
FROM film
WHERE title LIKE 'K%'
OR title LIKE 'Q%'
AND language_id IN
(
SELECT language_id
FROM language
WHERE name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name 
FROM actor
WHERE actor_id IN 
(SELECT actor_id
FROM film_actor
WHERE film_id IN
(
SELECT film_id
FROM film
WHERE title = 'Alone Trip'
)
);
 

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this 
-- information.


SELECT 	c.first_name as 'First Name',
		c.last_name as 'Last Name',
        c.email as 'Email Address'
FROM    customer c 
	JOIN address a
		ON c.address_id = a.address_id
    JOIN city y
		ON a.city_id = y.city_id
WHERE country_id IN     
(
 Select country_id
 FROM country 
 WHERE country = "Canada"
); 	
        
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT title
FROM film
WHERE film_id IN
(
SELECT film_id
FROM film_category
WHERE category_id IN
(
SELECT category_id
FROM category
WHERE name = 'family'
)
);

-- 7e. Display the most frequently rented movies in descending order.

SELECT title AS 'Film Title',
	COUNT(rental_id) as 'Times Rented'
FROM film f
	JOIN inventory i on
	f.film_id = i.film_id
	JOIN rental r ON 
	i.inventory_id = r.inventory_id
GROUP BY title
HAVING COUNT(rental_id) > 20 
ORDER BY COUNT(rental_id) DESC;   
	

-- 7f. Write a query to display how much business, in dollars, each store brought in. 

SELECT s.store_id, SUM(amount) AS Gross
  FROM payment p
  JOIN rental r
  ON p.rental_id = r.rental_id
  JOIN inventory i
  ON i.inventory_id = r.inventory_id
  JOIN store s
  ON s.store_id = i.store_id
  GROUP BY s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id AS 'ID',
	c.city AS 'City',
    y.country AS 'Country'
	FROM store s
    JOIN address a
    ON s.address_id = a.address_id
    JOIN city c
    ON a.city_id = c.city_id
    JOIN country y
    ON c.country_id = y.country_id;
		

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, 
-- payment, and rental.)

SELECT c.name AS 'Genre', SUM(amount) AS 'Gross Revenue'
  FROM payment p
  JOIN rental r
  ON p.rental_id = r.rental_id
  JOIN inventory i
  ON i.inventory_id = r.inventory_id
  JOIN film_category f
  ON f.film_id = i.film_id
  JOIN category c
  ON c.category_id = f.category_id
  GROUP BY c.name
  ORDER BY sum(amount) DESC
  LIMIT 5; 


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem 
-- above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT c.name AS 'Genre', SUM(amount) AS 'Gross Revenue'
  FROM payment p
  JOIN rental r
  ON p.rental_id = r.rental_id
  JOIN inventory i
  ON i.inventory_id = r.inventory_id
  JOIN film_category f
  ON f.film_id = i.film_id
  JOIN category c
  ON c.category_id = f.category_id
  GROUP BY c.name
  ORDER BY sum(amount) DESC
  LIMIT 5; 

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres; 