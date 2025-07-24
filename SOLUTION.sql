--NETFLIX Project
DROP TABLE IF EXISTS NETFLIX;
CREATE TABLE NETFLIX 
(
   show_id       VARCHAR(6),
   type          VARCHAR(10),
   title         VARCHAR(150),
   director      VARCHAR(208),
   casts          VARCHAR(1000),
   country       VARCHAR(150),
   date_added    VARCHAR(50),
   release_year  INT,
   rating        VARCHAR(10),
   duration      VARCHAR(15),
   listed_in     VARCHAR(100),
   description   VARCHAR(250)
)


SELECT * 
FROM NETFLIX;


SELECT 
    COUNT(*) AS total_content
FROM NETFLIX;


SELECT 
    DISTINCT type
FROM NETFLIX;


-- 1. Count the number of Movies vs TV Shows

SELECT 
   type,
   COUNT(*) AS total_content
FROM NETFLIX
GROUP BY type

   
-- 2. Find the most common rating for movies and TV shows

SELECT 
   type,
   rating
FROM
( SELECT 
      type,
      rating,
      COUNT(*),
      RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
  FROM NETFLIX
  GROUP BY type,rating ) AS t1
 WHERE ranking = 1
 

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT *
FROM NETFLIX
WHERE 
    type = 'Movie'
	AND release_year = 2020
     

--4. Find the top 5 countries with the most content on Netflix

SELECT 
       UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
       COUNT(show_id) AS total_content 
FROM NETFLIX
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;


--5. Identify the longest movie

SELECT * FROM NETFLIX
WHERE   
     type = 'Movie'
     AND duration = (SELECT MAX(duration) FROM NETFLIX)


--6. Find content added in the last 5 years

SELECT *
FROM NETFLIX
WHERE 
     TO_DATE(date_added , 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
	 

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT *
FROM NETFLIX
WHERE director LIKE '%Rajiv Chilaka%'

  
--8. List all TV shows with more than 5 seasons

SELECT * 
FROM NETFLIX
WHERE type = 'TV Show'
  AND duration > '5 Seasons'


--9. Count the number of content items in each genre

SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
       COUNT(show_id) as total_content
FROM NETFLIX
GROUP BY genre


--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	   COUNT(*),
       COUNT(*)::numeric /(SELECT COUNT(*) FROM NETFLIX WHERE country = 'India')::numeric * 100 AS avg_number_of_content
FROM NETFLIX
WHERE country = 'India'
GROUP BY year


--11. List all movies that are documentaries

SELECT *
FROM NETFLIX
WHERE listed_in ILIKE '%Documentaries%'


--12. Find all content without a director

SELECT *
FROM NETFLIX
WHERE director IS NULL


--13. Find how many movies actor 'Salman Khan' appeared in last 11 years!

SELECT *
FROM NETFLIX
WHERE 
  casts ILIKE '%Salman Khan%'
  AND 
  release_year > EXTRACT(YEAR FROM CURRENT_DATE)-11

  
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
       COUNT (*) AS total_content
FROM NETFLIX
WHERE country = 'India'
GROUP BY actors
ORDER BY total_content DESC
LIMIT 10


--15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

WITH new_table AS
(
SELECT *,
       CASE WHEN description ILIKE '%kill%' 
	          OR description ILIKE '%violence%' THEN 'Bad Content'
	   ELSE 'Good Content' END category
FROM NETFLIX
)
SELECT category,
       COUNT(*) AS total_content
FROM new_table
GROUP BY category
