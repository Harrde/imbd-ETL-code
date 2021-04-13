--dropping schema MOVIES if it exists
DROP SCHEMA IF EXISTS MOVIES CASCADE;
--creating MOVIES schema
CREATE SCHEMA MOVIES;

--dropping or deleting TITLES table if it exists
DROP TABLE IF EXISTS MOVIES.TITLES;
--creating TITLES table
CREATE TABLE MOVIES.TITLES (imdb_title_id       SERIAL NOT NULL,
							title				VARCHAR (100) NOT NULL,
							original_title      VARCHAR (100) NOT NULL,
							year				INTEGER NOT NULL,
							date_published		DATE NOT NULL,
							duration			INTEGER NOT NULL,
						    production_company  VARCHAR (100) NOT NULL,
						    description			TEXT,
						    PRIMARY KEY (imdb_title_id));
								   
--dropping or deleting FINANCES table if it exists
DROP TABLE IF EXISTS MOVIES.FINANCES;
--creating FINANCES table
CREATE TABLE MOVIES.FINANCES (imdb_title_id          SERIAL NOT NULL,
							  budget         		 FLOAT,
							  usa_gross_income		 FLOAT,
							  worldwide_gross_income FLOAT,
							  PRIMARY KEY (imdb_title_id),
							  FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));				  
							  
--dropping or deleting REVIEWS table if it exists
DROP TABLE IF EXISTS MOVIES.REVIEWS;
--creating REVIEWS table
CREATE TABLE MOVIES.REVIEWS (imdb_title_id       SERIAL NOT NULL,
							 avg_vote			 FLOAT,
							 metascore			 INTEGER,	
							 reviews_from_users	 INTEGER,
							 reviews_from_critics INTEGER,
							 PRIMARY KEY (imdb_title_id),
							 FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));
							 
--dropping or deleting LANGUAGES table if it exists
DROP TABLE IF EXISTS MOVIES.LANGUAGES;
--creating LANGUAGES table
CREATE TABLE MOVIES.LANGUAGES (language_id           SERIAL NOT NULL,
							   language_name		 VARCHAR (100) NOT NULL,
							   PRIMARY KEY (language_id));
								  								  
--dropping or deleting MOVIE_LANGUAGES table if it exists
DROP TABLE IF EXISTS MOVIES.MOVIE_LANGUAGES;
--creating MOVIE_LANGUAGES table
CREATE TABLE MOVIES.MOVIE_LANGUAGES (movie_language_id			SERIAL NOT NULL,
									 imdb_title_id      		SERIAL NOT NULL,
							  		 language_id                SERIAL NOT NULL,
							   		 PRIMARY KEY (movie_language_id),
									 FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id),
									 FOREIGN KEY (language_id) REFERENCES MOVIES.LANGUAGES (language_id));

--dropping or deleting DIRECTORS table if it exists
DROP TABLE IF EXISTS MOVIES.DIRECTORS;
--creating LANGUAGES table
CREATE TABLE MOVIES.DIRECTORS (director_id           SERIAL NOT NULL,
							   director_name		 VARCHAR (100) NOT NULL,
							   PRIMARY KEY (director_id));
								  								  
--dropping or deleting MOVIE_DIRECTORS table if it exists
DROP TABLE IF EXISTS MOVIES.MOVIE_DIRECTORS;
--creating MOVIE_DIRECTORS table
CREATE TABLE MOVIES.MOVIE_DIRECTORS (movie_director_id	SERIAL NOT NULL,
									 imdb_title_id      SERIAL NOT NULL,
							  		 director_id        SERIAL NOT NULL,
							   		 PRIMARY KEY (movie_director_id),
									 FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id),
									 FOREIGN KEY (director_id) REFERENCES MOVIES.DIRECTORS (director_id));
									 
									 
--dropping or deleting ACTORS table if it exists
DROP TABLE IF EXISTS MOVIES.ACTORS;
--creating LANGUAGES table
CREATE TABLE MOVIES.ACTORS (actor_id           SERIAL NOT NULL,
							actor_name		   VARCHAR (100) NOT NULL,
							PRIMARY KEY (actor_id));
								  								  
--dropping or deleting MOVIE_ACTORS table if it exists
DROP TABLE IF EXISTS MOVIES.MOVIE_ACTORS;
--creating MOVIE_ACTORS table
CREATE TABLE MOVIES.MOVIE_ACTORS (movie_actor_id       SERIAL NOT NULL,
								  imdb_title_id        SERIAL NOT NULL,
							  	  actor_id             SERIAL NOT NULL,
							   	  PRIMARY KEY (movie_actor_id),
								  FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id),
								  FOREIGN KEY (actor_id) REFERENCES MOVIES.ACTORS (actor_id));
								  								  
--dropping or deleting COUNTRIES table if it exists
DROP TABLE IF EXISTS MOVIES.COUNTRIES;
--creating LANGUAGES table
CREATE TABLE MOVIES.COUNTRIES (country_id           SERIAL NOT NULL,
							   country_name		    VARCHAR (100) NOT NULL,
							   PRIMARY KEY (country_id));
								  								  
--dropping or deleting MOVIE_COUNTRIES table if it exists
DROP TABLE IF EXISTS MOVIES.MOVIE_COUNTRIES;
--creating MOVIE_COUNTRIES table
CREATE TABLE MOVIES.MOVIE_COUNTRIES (movie_country_id		 SERIAL NOT NULL,
									 imdb_title_id           SERIAL NOT NULL,
							  		 country_id         	 SERIAL NOT NULL,
							   		 PRIMARY KEY (movie_country_id),
									 FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id),
									 FOREIGN KEY (country_id) REFERENCES MOVIES.COUNTRIES (country_id));

--dropping or deleting GENRES table if it exists
DROP TABLE IF EXISTS MOVIES.GENRES;
--creating LANGUAGES table
CREATE TABLE MOVIES.GENRES (genre_id           SERIAL NOT NULL,
							genre_name		   VARCHAR (100) NOT NULL,
							PRIMARY KEY (genre_id));
								  								  
--dropping or deleting MOVIE_GENRES table if it exists
DROP TABLE IF EXISTS MOVIES.MOVIE_GENRES;
--creating MOVIE_GENRES table
CREATE TABLE MOVIES.MOVIE_GENRES (movie_genre_id	 SERIAL NOT NULL,
								  imdb_title_id      SERIAL NOT NULL,
							  	  genre_id           SERIAL NOT NULL,
							   	  PRIMARY KEY (movie_genre_id),
								  FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id),
								  FOREIGN KEY (genre_id) REFERENCES MOVIES.GENRES (genre_id));

--dropping or deleting RATING_STATS table if it exists
DROP TABLE IF EXISTS MOVIES.RATING_STATS;
--creating RATING_STATS table
CREATE TABLE MOVIES.RATING_STATS (imdb_title_id          SERIAL NOT NULL,
							  	  mean_vote              FLOAT,
							      median_vote    		 FLOAT,
							      PRIMARY KEY (imdb_title_id),
							      FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting RATING_BREAKDOWN table if it exists
DROP TABLE IF EXISTS MOVIES.RATING_BREAKDOWN;
--creating RATING_BREAKDOWN table
CREATE TABLE MOVIES.RATING_BREAKDOWN (imdb_title_id          SERIAL NOT NULL,
									  total_votes			 INTEGER,
							  	      votes_10               INTEGER,
							  	      votes_9                INTEGER,
							  	      votes_8                INTEGER,
							  	      votes_7                INTEGER,
							  	      votes_6                INTEGER,
							  	      votes_5                INTEGER,
							  	      votes_4                INTEGER,
							  	      votes_3                INTEGER,
							  	      votes_2                INTEGER,
							  	      votes_1                INTEGER,
							          PRIMARY KEY (imdb_title_id),
							          FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting RATING_AGE table if it exists
DROP TABLE IF EXISTS MOVIES.RATING_AGE;
--creating RATING_AGE table
CREATE TABLE MOVIES.RATING_AGE(imdb_title_id 			 	    SERIAL NOT NULL,
							   	   allgenders_0age_avg_vote  	FLOAT,
							   	   allgenders_18age_avg_vote 	FLOAT,
							   	   allgenders_30age_avg_vote 	FLOAT,
							   	   allgenders_45age_avg_vote 	FLOAT,
							   	   PRIMARY KEY (imdb_title_id),
							   	   FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting VOTES_AGE table if it exists
DROP TABLE IF EXISTS MOVIES.VOTES_AGE;
--creating VOTES_AGE table
CREATE TABLE MOVIES.VOTES_AGE(imdb_title_id 			     SERIAL NOT NULL,
							   	  allgenders_0age_votes	     INTEGER,	
								  allgenders_18age_votes	 INTEGER,
							   	  allgenders_30age_votes	 INTEGER,
							      allgenders_45age_votes	 INTEGER,
							      PRIMARY KEY (imdb_title_id),
							      FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting RATING_MALES_AGE table if it exists
DROP TABLE IF EXISTS MOVIES.RATING_MALES_AGE;
--creating RATING_MALES_AGE table
CREATE TABLE MOVIES.RATING_MALES_AGE(imdb_title_id 			SERIAL NOT NULL,
									 males_allages_avg_vote FLOAT,
							   	   	 males_0age_avg_vote  	FLOAT,
							   	   	 males_18age_avg_vote 	FLOAT,
							   	     males_30age_avg_vote 	FLOAT,
							   	     males_45age_avg_vote 	FLOAT,
							   	     PRIMARY KEY (imdb_title_id),
							   	     FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting VOTES_MALES_AGE table if it exists
DROP TABLE IF EXISTS MOVIES.VOTES_MALES_AGE;
--creating VOTES_MALES_AGE table
CREATE TABLE MOVIES.VOTES_MALES_AGE(imdb_title_id 		 SERIAL NOT NULL,
									males_allages_votes	 INTEGER,
							   	    males_0age_votes	 INTEGER,	
								    males_18age_votes	 INTEGER,
							   	    males_30age_votes	 INTEGER,
							        males_45age_votes	 INTEGER,
							        PRIMARY KEY (imdb_title_id),
							        FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting RATING_FEMALES_AGE table if it exists
DROP TABLE IF EXISTS MOVIES.RATING_FEMALES_AGE;
--creating RATING_FEMALES_AGE table
CREATE TABLE MOVIES.RATING_FEMALES_AGE(imdb_title_id 			SERIAL NOT NULL,
									   females_allages_avg_vote FLOAT,
							   	   	   females_0age_avg_vote  	FLOAT,
							   	       females_18age_avg_vote 	FLOAT,
							   	   	   females_30age_avg_vote 	FLOAT,
							   	   	   females_45age_avg_vote 	FLOAT,
									   PRIMARY KEY (imdb_title_id),
							   	   	   FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting VOTES_FEMALES_AGE table if it exists
DROP TABLE IF EXISTS MOVIES.VOTES_FEMALES_AGE;
--creating VOTES_FEMALES_AGE table
CREATE TABLE MOVIES.VOTES_FEMALES_AGE(imdb_title_id 		 SERIAL NOT NULL,
									  females_allages_votes	 INTEGER,
							   	   	  females_0age_votes	 INTEGER,	
								      females_18age_votes	 INTEGER,
							   	      females_30age_votes	 INTEGER,
							          females_45age_votes	 INTEGER,
							          PRIMARY KEY (imdb_title_id),
							          FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting RATING_COUNTRY table if it exists
DROP TABLE IF EXISTS MOVIES.RATING_COUNTRY;
--creating RATING_COUNTRY table
CREATE TABLE MOVIES.RATING_COUNTRY(imdb_title_id 			SERIAL NOT NULL,
							   	   us_voters_rating  		FLOAT,
							   	   non_us_voters_rating	 	FLOAT,
								   PRIMARY KEY (imdb_title_id),
								   FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));

--dropping or deleting VOTES_COUNTRY table if it exists
DROP TABLE IF EXISTS MOVIES.VOTES_COUNTRY;
--creating VOTES_COUNTRY table
CREATE TABLE MOVIES.VOTES_COUNTRY(imdb_title_id 		 SERIAL NOT NULL,
							   	  us_voters_votes		 INTEGER,	
								  non_us_voters_votes	 INTEGER,
							   	  PRIMARY KEY (imdb_title_id),
							      FOREIGN KEY (imdb_title_id) REFERENCES MOVIES.TITLES (imdb_title_id));



/*
--inserting values into TITLES table
INSERT INTO MOVIES.TITLES (imdb_title_id,
						   title,
						   original_title,
						   date_published,
						   year,
						   duration,
						   production_company,
						   description)
						   
VALUES (103776,
		'Batman - Il ritorno',
		'Batman Returns',
		'09/11/1992',
		1992,
		126,
		'Warner Bros.',
		'Batman returns to the big screen when a deformed man calling himself the Penguin wreaks havoc across Gotham with the help of a cruel businessman.');
		
--inserting values into COUNTRIES table
INSERT INTO MOVIES.COUNTRIES(country_id,
							 country_name)
VALUES (1,
	   'USA'),
	   (2,
	   'UK');
	   
--inserting values into MOVIES_COUNTRIES table
INSERT INTO MOVIES.MOVIE_COUNTRIES(movie_country_id,
								   imdb_title_id,
							 	   country_id)
VALUES (1,
		103776,
		1),
	   (2,
		103776,
	   2);	   

*/