/*For each director, return the director_id, director_name, average avg_vote 
from all movies directed by that director. Present the result on a 5-row 
sliding window (2 before, 2 after) based on descending director_id.*/
SELECT id, name, AVG(vote) OVER
	(ORDER BY director_id DESC BETWEEN 2 PRECEDING AND 2 FOLLOWING)
FROM
(SELECT D.director_id id, D.director_name name, MD.imdb_title_id movie_id, R.avg_vote vote
FROM MOVIES.Directors D, Movies.Movie_Directors MD, Movies.Reviews R
WHERE D.director_id = MD.director_id AND MD.imdb_title_id = R.imdb_title_id) A

/*What 3 genre of movies have on average the highest number of user reviews (not critic reviews)?*/
SELECT genre, AVG(reviews) avg_rev
(SELECT R.reviews_from_users reviews, G.genre_id id, G.genre_name genre, MG.imdb_title_id movie
FROM MOVIES.Reviews R, MOVIES.Genres G, MOVIES.Movie_Genres MG
WHERE R.imdb_title_id = MG.imdb_title_id AND G.genre_id = MG.genre_id) B
GROUP BY genre 
ORDER BY avg rev DESC
LIMIT 3

/*What genre has the highest critic review to user review ratio on average?*/
SELECT genre, critics/users
(SELECT AVG(R.reviews_from_users) users, AVG(R.reviews_from_critics) critics, G.genre_id id, G.genre_name genre, MG.imdb_title_id movie
FROM MOVIES.Reviews R, MOVIES.Genres G, MOVIES.Movie_Genres MG
WHERE R.imdb_title_id = MG.imdb_title_id AND G.genre_id = MG.genre_id
GROUP BY id, genre) B
GROUP BY genre 
ORDER BY avg rev DESC
LIMIT 1

/* Which 10 movies are the most popular amoung viewers under 18 years old based on average vote?*/
SELECT AVG(R.allgenders_0age_avg_vote) vote, T.title
FROM MOVIES.Reviews R 
INNER JOIN MOVIES.Titles T
ON R.imdb_title_id = T.imdb_title_id
ORDER BY vote DESC
LIMIT 10

/*Find all movies that are more popular (highest average vote) for young adults (age 18-30) than any other age groups*/
SELECT title
FROM 
(SELECT T.title title, R.allgenders_0age_avg_vote children, R.allgenders_18age_avg_vote young_adult, 
R.allgenders_30age_avg_vote adult, R.allgenders_45age_avg_vote old
FROM MOVIES.Titles T AND MOVIES.Reviews R
WHERE T.imdb_title_id = R.imdb_title_id) C
WHERE young_adult>children AND young_adult>adult AND young_adult>old


/*Get the top 5 actors who've been in the most movies*/
SELECT actor_name, COUNT(actor_name) actor_freq
FROM MOVIES.titles t
LEFT JOIN MOVIES.movie_actors ma ON ma.imdb_title_id= t.imdb_title_id
LEFT JOIN MOVIES.actors a ON a.actor_id = ma.actor_id
GROUP BY actor_name
ORDER BY actor_freq DESC
LIMIT 5;

/*Get the top 10 movie genres with the highest rating in USA*/
SELECT genre_name, AVG(us_voters_rating) us_avg_rating , AVG(non_us_voters_rating) non_us_avg_rating 
FROM MOVIES.titles t
LEFT JOIN MOVIES.rating_country rc ON rc.imdb_title_id= t.imdb_title_id
LEFT JOIN MOVIES.movie_genres mg ON mg.imdb_title_id= t.imdb_title_id
LEFT JOIN MOVIES.genres g ON g.genre_id= mg.genre_id
GROUP BY genre_name
ORDER BY us_avg_rating DESC
LIMIT 10;

/*Get the top 5 production companies with the highest budget*/
ALTER TABLE MOVIES.finances
	ALTER COLUMN imdb_title_id TYPE INT
	USING imdb_title_id::integer;

CREATE TABLE MOVIES.movie_finance AS
SELECT *
FROM MOVIES.titles
INNER JOIN MOVIES.finances USING (imdb_title_id);

SELECT production_company, SUM(budget) total_budget
FROM MOVIES.movie_finance
WHERE budget IS NOT NULL
GROUP BY production_company
ORDER BY total_budget DESC
LIMIT 5;

/*Get the movies with votes by descendign order*/
ALTER TABLE MOVIES.reviews
	ALTER COLUMN imdb_title_id TYPE INT
	USING imdb_title_id::integer;

CREATE TABLE MOVIES.movie_review AS
SELECT *
FROM MOVIES.titles
INNER JOIN MOVIES.reviews USING (imdb_title_id);

SELECT title, votesD
FROM MOVIES.movie_review
GROUP BY title, votes
ORDER BY votes DESC;

/*Get the movie with the average voting rate greater than 9 in all ages*/
SELECT title, allgenders_0age_avg_vote, allgenders_18age_avg_vote, allgenders_30age_avg_vote, allgenders_45age_avg_vote
FROM MOVIES.titles t
LEFT JOIN MOVIES.rating_all_age raa ON raa.imdb_title_id= t.imdb_title_id
GROUP BY title, allgenders_0age_avg_vote, allgenders_18age_avg_vote, allgenders_30age_avg_vote, allgenders_45age_avg_vote
HAVING allgenders_0age_avg_vote > 9 AND allgenders_18age_avg_vote >9 AND allgenders_30age_avg_vote >9 AND allgenders_45age_avg_vote>9
ORDER BY title ASC;