suppressWarnings(suppressMessages(library(RPostgreSQL))) 
suppressWarnings(suppressMessages(library(sqldf)))
suppressWarnings(suppressMessages(library(tidyr)))
suppressWarnings(suppressMessages(library(stringr)))
suppressWarnings(suppressMessages(library(stringi)))
suppressWarnings(suppressMessages(library(openxlsx)))
suppressWarnings(suppressMessages(library(lubridate)))
suppressWarnings(suppressMessages(library(tidyverse)))

########### Data Extraction: movies, xchange, and ratings files ###########

#Setting the input directors
Inputpath <- paste("C:/Users/dr_an/OneDrive/Desktop/APAN 5310 - SQL & RELATIONAL DATABASES/Homework/Project",sep = "")
setwd(Inputpath)

#Reading the input files
movies <- read.csv('IMDB movies.csv')
ratings <- read.csv('IMDB Ratings.csv')
xchange <- read.xlsx('Exchange Rate.xlsx', sheet = "ExchangeRate", rowNames = FALSE, colNames = TRUE)

########### Data Transformation: movies and xchange files ###########

#renaming column names
colnames(xchange) <- paste(c("currency_code",
                             "usd_conversion_rate"))

#Converting factors to characters in movies dataframe
movies <- movies %>%
  mutate_if(is.factor, as.character)

#Removing "tt" pre-fix from the imdb_title_id column of the movies dataframe
movies$imdb_title_id <- substr(movies$imdb_title_id, 3,10)


### Titles Table ###

#Selecting all the varibles in Titles table
Titles <- movies%>%
  select(imdb_title_id,
         title,
         original_title,
         year,
         date_published,
         duration,
         production_company,
         description)

Titles$date_published <- as.Date(Titles$date_published, origin = "1899-12-30")
Titles$year <- as.numeric(Titles$year)

### Finances Table ###

#Selecting all the varibles in Finances table
Finances <- movies%>%
  select(imdb_title_id,
         budget,
         usa_gross_income,
         worlwide_gross_income)

Finances$budget_numeric <- as.integer(gsub("[^0-9.]", "",  Finances$budget))
Finances$usa_gross_income_numeric <- as.integer(gsub("[^0-9.]", "",  Finances$usa_gross_income))
Finances <- Finances %>%
  mutate(worldwide_gross_income_numeric = as.integer(str_extract(worlwide_gross_income, "[0-9]+")))  

Finances$budget_currency <- sub("^([[:alpha:]]*).*", "\\1", Finances$budget)
Finances$usa_gross_income_currency <- sub("^([[:alpha:]]*).*", "\\1", Finances$usa_gross_income)
Finances <- Finances %>%
   mutate(worldwide_gross_income_currency = case_when(
          imdb_title_id %in% c('0139876', '0213969', '0220656', '0242256', '0262037', '0285665', '0294264',
                                '0320134', '0323546', '0366180', '0376144', '0449869', '0458050', '0463939',
                                '0888503', '1417299', '1582519', '1661031', '1754394', '1772989', '1889440',
                                '2071613', '2235858', '2355791', '2362778', '2644178', '2856674', '2950296',
                                '2988020', '3232156', '3399462', '3555036', '3565264', '3569788', '3802668',
                                '3824432', '3916762', '3982448', '4010302', '4087850', '4195522', '4305752',
                                '4305766', '4337414', '4384242', '4442758', '4679210', '4980272', '4992086',
                                '5119108', '5128328', '5277266', '5523174', '5559528', '5934894', '6203302',
                                '6417204', '6568474') ~ "INR",
          imdb_title_id %in% c('4635548') ~ "PKR",
          imdb_title_id %in% c('0032359') ~ "GBP",
          imdb_title_id %in% c('3638644') ~ "NPR",
          TRUE ~ ""))

Finances <- Finances %>%
  left_join(., xchange, by = c("budget_currency"="currency_code"))

colnames(Finances)[11] <- "budget_usd_conversion_rate"

Finances <- Finances %>%
  left_join(.,xchange, by = c("usa_gross_income_currency"="currency_code"))

colnames(Finances)[12] <- "usa_gross_income_usd_conversion_rate"

Finances <- Finances %>%
  left_join(.,xchange, by = c("worldwide_gross_income_currency"="currency_code"))

colnames(Finances)[13] <- "worldwide_gross_income_usd_conversion_rate"

Finances <- Finances %>%
  mutate(budget_usd = budget_numeric * budget_usd_conversion_rate,
         usa_gross_income_usd = usa_gross_income_numeric * usa_gross_income_usd_conversion_rate,
         worldwide_gross_income_usd = worldwide_gross_income_numeric * worldwide_gross_income_usd_conversion_rate)

Finances <- Finances %>%
  select(imdb_title_id,
         budget_usd,
         usa_gross_income_usd,
         worldwide_gross_income_usd)

colnames(Finances) <- paste(c("imdb_title_id",
                               "budget",
                               "usa_gross_income",
                               "worlwide_gross_income"))

### Reviews Table ###

#Selecting all the varibles in Reviews table
Reviews <- movies %>%
  select(imdb_title_id,
         avg_vote,
         metascore,
         votes,
         reviews_from_users,
         reviews_from_critics)

### Language Tables ###

#Extracting all unique languages and storing it as a dataframe
lang <- movies %>%
  select(imdb_title_id,language) %>%
  unique()

#Transposing rows with multiple records and storing it as a new dataframe
lg <- separate_rows(lang, language, sep = ",")
lg$language <- trimws(lg$language, "left")

#Extracting final unique list of languages and storing it as a new dataframe
language_final <- lg %>%
  select(language) %>%
  unique () %>%
  arrange(language)

#Assigning id to the language_id column in the "language_final" dataframe
language_final$language_id <- seq_along(language_final[,1])

#Changing the order of the "language_final" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
language_final <- language_final %>%
  select(language_id,
         language)

colnames(language_final) <- paste(c("language_id",
                                    "language_name"))

#Joining two dataframes to create "movies language" dataframe
movies_languages <- lg %>%
  left_join(.,language_final, by=c("language"="language_name")) %>%
  select(imdb_title_id, language_id)

##Assigning id to the language_id column in the "movies_languages" dataframe
movies_languages$movie_language_id <- seq_along(movies_languages[,1])

#Changing the order of the "movies_languages" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
movies_languages <- movies_languages %>%
  select(movie_language_id,
         imdb_title_id,
         language_id)

### Genre Tables ###

#Extracting all unique genres and storing it as a dataframe
genr <- movies %>%
  select(imdb_title_id,genre) %>%
  unique()

#Transposing rows with multiple records and storing it as a new dataframe
gen <- separate_rows(genr, genre, sep = ",")
gen$genre <- trimws(gen$genre, "left")

#Extracting final unique list of genres and storing it as a new dataframe
genre_final <- gen %>%
  select(genre) %>%
  unique () %>%
  arrange(genre)

#Assigning id to the genre_id column in the "genre_final" dataframe
genre_final$genre_id <- seq_along(genre_final[,1])

#Changing the order of the "genre_final" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
genre_final <- genre_final %>%
  select(genre_id,
         genre)

colnames(genre_final) <- paste(c("genre_id",
                                 "genre_name"))

#Joining two dataframes to create "movies genre" dataframe
movies_genres <- gen %>%
  left_join(.,genre_final, by=c("genre" = "genre_name")) %>%
  select(imdb_title_id, genre_id)

#Assigning id to the genre_id column in the "movies_genres" dataframe
movies_genres$movie_genre_id <- seq_along(movies_genres[,1])

#Changing the order of the "movies_genres" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
movies_genres <- movies_genres %>%
  select(movie_genre_id,
         imdb_title_id,
         genre_id)

### Country Tables ###

#Extracting all unique country and storing it as a dataframe
count <- movies %>%
  select(imdb_title_id,country) %>%
  unique()

#Transposing rows with multiple records and storing it as a new dataframe
cou <- separate_rows(count, country, sep = ",")
cou$country <- trimws(cou$country, "left")

#Extracting final unique list of country and storing it as a new dataframe
country_final <- cou %>%
  select(country) %>%
  unique () %>%
  arrange(country)

#Assigning id to the country_id column in the "country_final" dataframe
country_final$country_id <- seq_along(country_final[,1])

#Changing the order of the "country_final" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
country_final <- country_final %>%
  select(country_id,
         country)

colnames(country_final) <- paste(c("country_id",
                                   "country_name"))

#Joining two dataframes to create "movies countries" dataframe
movies_countries <- cou %>%
  left_join(.,country_final, by=c("country"="country_name")) %>%
  select(imdb_title_id, country_id)

##Assigning id to the country_id column in the "movies_countries" dataframe
movies_countries$movie_country_id <- seq_along(movies_countries[,1])

#Changing the order of the movies_countries dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
movies_countries <- movies_countries %>%
  select(movie_country_id,
         imdb_title_id,
         country_id)

### Director Tables ###

#Extracting all unique director and storing it as a dataframe
Direct <- movies %>%
  select(imdb_title_id,director) %>%
  unique()

#Transposing rows with multiple records and storing it as a new dataframe
Di <- separate_rows(Direct, director, sep =",")
Di$director <- trimws(Di$director, "left")

#Extracting final unique list of director and storing it as a new dataframe
director_final <- Di %>%
  select(director) %>%
  unique () %>%
  arrange(director)

#Assigning id to the director_id column in the "director_final" dataframe
director_final$director_id <- seq_along(director_final[,1])

#Changing the order of the "director_final" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
director_final <- director_final %>%
  select(director_id,
         director)

colnames(director_final) <- paste(c("director_id",
                                    "director_name"))

#Joining two dataframes to create "movies director" dataframe
movies_director <- Di %>%
  left_join(.,director_final, by=c("director"="director_name")) %>%
  select(imdb_title_id, director_id)

#Assigning id to the genre_id column in the "movies_director" dataframe
movies_director$movie_director_id <- seq_along(movies_director[,1])

#Changing the order of the movies_director dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
movies_director <- movies_director %>%
  select(movie_director_id,
         imdb_title_id,
         director_id)

### Writer Tables ###

#Extracting all unique writers and storing it as a dataframe
Write <- movies %>%
  select(imdb_title_id,writer) %>%
  unique()

#Transposing rows with multiple records and storing it as a new dataframe
Wi <- separate_rows(Write, writer, sep =",")
Wi$writer <- trimws(Wi$writer, "left")

#Extracting final unique list of writers and storing it as a new dataframe
writer_final <- Wi %>%
  select(writer) %>%
  unique () %>%
  arrange(writer)

#Assigning id to the writer_id column in the "writer_final" dataframe
writer_final$writer_id <- seq_along(writer_final[,1])

#Changing the order of the "director_final" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
writer_final <- writer_final %>%
  select(writer_id,
         writer)

colnames(writer_final) <- paste(c("writer_id",
                                    "writer_name"))

#Joining two dataframes to create "movies writer" dataframe
movies_writer <- Wi %>%
  left_join(.,writer_final, by=c("writer"="writer_name")) %>%
  select(imdb_title_id, writer_id)

##Assigning id to the genre_id column in the "movies_writer" dataframe
movies_writer$movie_writer_id <- seq_along(movies_writer[,1])

#Changing the order of the movies_writer dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
movies_writer <- movies_writer %>%
  select(movie_writer_id,
         imdb_title_id,
         writer_id)

### Actor Tables ###

#Extracting all unique actors and storing it as a dataframe
acto <- movies %>%
  select(imdb_title_id,actors) %>%
  unique()

#Transposing rows with multiple records and storing it as a new dataframe
act <- separate_rows(acto, actors, sep = ",")
act$actors <- trimws(act$actors, "left")

#Extracting final unique list of actors and storing it as a new dataframe
actors_final <- act %>%
  select(actors) %>%
  unique () %>%
  arrange(actors)

#Assigning id to the actor_id column in the "actor_final" dataframe
actors_final$actor_id <- seq_along(actors_final[,1])

#Changing the order of the actor_final dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
actors_final <- actors_final %>%
  select(actor_id,
         actors)

colnames(actors_final) <- paste(c("actor_id",
                                  "actor_name"))

#Joining two dataframes to create "movies actors" dataframe
movies_actors <- act %>%
  left_join(.,actors_final, by=c("actors"="actor_name")) %>%
  select(imdb_title_id, actor_id)

#Assigning id to the genre_id column in the "movies_actors" dataframe
movies_actors$movie_actor_id <- seq_along(movies_actors[,1])

#Changing the order of the "movies_actors" dataframe to upload to Postgres: Ready for Uploading to PostgreSQL Table
movies_actors <- movies_actors %>%
  select(movie_actor_id,
         imdb_title_id,
         actor_id)

########### Data Transformation: ratings file ###########

#Converting factors to characters
ratings <- ratings %>%
  mutate_if(is.factor, as.character)

#Removing "tt" pre-fix from the imdb_title_id column
ratings$imdb_title_id <- substr(ratings$imdb_title_id, 3,10)

#Creating Table for Rating_Stats
RATING_STATS <- ratings %>%
  select(imdb_title_id, 
         mean_vote, 
         median_vote)

#Creating table for Rating_Breakdown
RATING_BREAKDOWN <- ratings %>%
  select(imdb_title_id, 
         total_votes, 
         votes_10, 
         votes_9, 
         votes_8, 
         votes_7, 
         votes_6, 
         votes_5, 
         votes_4, 
         votes_3, 
         votes_2, 
         votes_1)

#Creating table for RATING_ALL_AGE
RATING_ALL_AGE <- ratings %>%
  select(imdb_title_id, 
         allgenders_0age_avg_vote,
         allgenders_18age_avg_vote, 
         allgenders_30age_avg_vote, 
         allgenders_45age_avg_vote)

#Creating table for VOTES_ALL_AGE
VOTES_ALL_AGE <- ratings %>%
  select(imdb_title_id, 
         allgenders_0age_votes,
         allgenders_18age_votes,
         allgenders_30age_votes,
         allgenders_45age_votes)

#Creating table for RATING_MALES_AGE
RATING_MALES_AGE <- ratings%>%
  select(imdb_title_id, 
         males_allages_avg_vote, 
         males_0age_avg_vote,
         males_18age_avg_vote, 
         males_30age_avg_vote, 
         males_45age_avg_vote)

#Creating table VOTES_MALES_AGE
VOTES_MALES_AGE <- ratings %>% 
  select(imdb_title_id, 
         males_allages_votes,
         males_0age_votes,
         males_18age_votes, 
         males_30age_votes, 
         males_45age_votes)

#Creating Table RATING_FEMALES_AGE
RATING_FEMALES_AGE <- ratings%>%
  select(imdb_title_id, 
         females_allages_avg_vote, 
         females_0age_avg_vote,
         females_18age_avg_vote, 
         females_30age_avg_vote, 
         females_45age_avg_vote)

#Creating table VOTES_FEMALES_AGE
VOTES_FEMALES_AGE <- ratings %>%
  select(imdb_title_id, 
         females_allages_votes, 
         females_0age_votes,
         females_18age_votes, 
         females_30age_votes, 
         females_45age_votes)

#Creating table RATING_COUNTRY
RATING_COUNTRY <- ratings%>%
  select(imdb_title_id, 
         us_voters_rating, 
         non_us_voters_rating)

#creating table VOTES_COUNTRY
VOTES_COUNTRY <- ratings %>%
  select(imdb_title_id, 
         us_voters_votes, 
         non_us_voters_votes)

########### Data Uploading ###########

#Connecting to PostrgreSQL Server
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv, dbname = 'IMDB',
                 host = 'localhost', port = 5432,
                 user = 'postgres', password = '123')

#Uploading tables to PostgreSQL Server tables: Movies File
dbWriteTable(con, c('movies','titles'), value = Titles, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','finances'), value = Finances, overwrite = T, append = F, row.names = FALSE)
dbWriteTable(con, c('movies','reviews'), value = Reviews, overwrite = T, append = F, row.names = FALSE)
dbWriteTable(con, c('movies','languages'), value = language_final, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','movie_languages'), value = movies_languages, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','genres'), value = genre_final, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','movie_genres'), value = movies_genres, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','countries'), value = country_final, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','movie_countries'), value = movies_countries, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','actors'), value = actors_final, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','movie_actors'), value = movies_actors, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','directors'), value = director_final, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','movie_directors'), value = movies_director, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','writers'), value = writer_final, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','movie_writers'), value = movies_writer, overwrite = F, append = T, row.names = FALSE)

#Uploading tables to PostgreSQL Server tables: Ratings File
dbWriteTable(con, c('movies','rating_stats'), value = RATING_STATS, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','rating_breakdown'), value = RATING_BREAKDOWN, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','rating_all_age'), value = RATING_ALL_AGE, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','votes_all_age'), value = VOTES_ALL_AGE, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','rating_males_age'), value = RATING_MALES_AGE, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','votes_males_age'), value = VOTES_MALES_AGE, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','rating_females_age'), value = RATING_FEMALES_AGE, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','votes_females_age'), value = VOTES_FEMALES_AGE, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','rating_country'), value = RATING_COUNTRY, overwrite = F, append = T, row.names = FALSE)
dbWriteTable(con, c('movies','votes_country'), value = VOTES_COUNTRY, overwrite = F, append = T, row.names = FALSE)

#Closing the connections to the PostgreSQL Server
lapply(dbListConnections(drv = dbDriver("PostgreSQL")), function(x) {dbDisconnect(conn = x)})
dbUnloadDriver(drv)