library(RSQLite)
library(DBI)
library(shiny)
library(shinyWidgets)
library(sqldf)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(tidyverse)
library(fpp3)
library(GGally)
library(sugrrants)
library(rjson)
library(shiny)
library(fable)
library(data.table)
library(DT)

# Init variables
sqlite <- "DB/sbos_app.sqlite"
raw_data <- ("DB/superbowloffensivestats.csv") 

# Connect/create database
db <- dbConnect(SQLite(), sqlite)


createdb <- function(){
  # Use this query to see if tables already have data
  testdf <- dbGetQuery(db, "SELECT * FROM sqlite_master WHERE type='table' AND name='stats'")
  
  if (nrow(testdf) == 0) {
    # Load raw data into SQLite table
    raw <- read.csv(raw_data)
    dbWriteTable(db, name = "superbowloffensivestats_raw", 
                 value = raw, 
                 overwrite = TRUE)
    
    # Create team table
    query <- "DROP TABLE IF EXISTS team;"
    dbExecute (db, query)  
    
    query <- "CREATE TABLE IF NOT EXISTS team(
    team_id INTEGER PRIMARY KEY
    ,team CHAR(3));"
    dbExecute (db, query)
    
    # Populate team table
    query <- "INSERT INTO team (
    team
    )
    SELECT DISTINCT team
    FROM superbowloffensivestats_raw;"
    dbExecute (db, query)
    
    # Create player table
    query <- "DROP TABLE IF EXISTS player;"
    dbExecute (db, query)  
    
    query <- "CREATE TABLE IF NOT EXISTS player(
    player_id INTEGER PRIMARY KEY
    ,player VARCHAR(50) 
    ,team_id INT REFERENCES team(team_id));"
    dbExecute (db, query)
    
    # Populate player table 
    query <- "INSERT INTO player (
    player
    ,team_id
    )
    SELECT DISTINCT player
    ,t.team_id
    FROM superbowloffensivestats_raw as r
    LEFT JOIN team t on t.team = r.team;"
    dbExecute (db, query)
    
    # Create stats table
    query <- "DROP TABLE IF EXISTS stats;"
    dbExecute (db, query)  
    
    query <- "CREATE TABLE IF NOT EXISTS stats(
    id INTEGER PRIMARY KEY
    ,player_id INT REFERENCES player(player_id)
    ,year INT
    ,completions INT
    ,pass_attempts INT
    ,passing_yards INT
    ,passing_td INT
    ,interception INT
    ,times_sacked INT
    ,sack_yards INT
    ,longest_pass INT
    ,qbr VARCHAR(10) 	
    ,rush_attempts INT
    ,rushing_yards INT
    ,rushing_td INT
    ,longest_run INT
    ,receptions INT
    ,receiving_yards INT
    ,receiving_td INT
    ,longest_reception INT
    ,fumble INT
    ,fumbles_lost INT
    );"
    dbExecute (db, query)
    
    # Populate stats table 
    query <- "INSERT INTO stats(
    player_id
    ,year
    ,completions
    ,pass_attempts
    ,passing_yards
    ,passing_td
    ,interception
    ,times_sacked
    ,sack_yards
    ,longest_pass
    ,qbr 	-- EE - This was a decimal field per the diagram, but getting an error due to empty string, so I made it varchar
    ,rush_attempts
    ,rushing_yards
    ,rushing_td
    ,longest_run
    ,receptions
    ,receiving_yards
    ,receiving_td
    ,longest_reception
    ,fumble
    ,fumbles_lost
    )
    SELECT  	
    player_id
    ,year
    ,completions
    ,pass_attempts
    ,passing_yards
    ,passing_td
    ,interception
    ,times_sacked
    ,sack_yards
    ,longest_pass
    ,qbr
    ,rush_attempts
    ,rushing_yards
    ,rushing_td
    ,longest_run
    ,receptions
    ,receiving_yards
    ,receiving_td
    ,longest_reception
    ,fumble
    ,fumbles_lost
    FROM superbowloffensivestats_raw r
    INNER JOIN player AS p ON p.player = r.player
    INNER JOIN team AS t on t.team = r.team AND p.team_id = t.team_id;"
    dbExecute (db, query)
    
    
    # Create account table 
    query <- "CREATE TABLE IF NOT EXISTS account(
    account_id INTEGER PRIMARY KEY
    ,user_name VARCHAR(100)
    ,password VARCHAR(255)
    );"
    dbExecute (db, query)
    
    # Create account access table 
    query <- "CREATE TABLE IF NOT EXISTS favorite_team(
    account_id INT REFERENCES account(account_id), 
    team_id INT REFERENCES team(team_id)
    );"
    dbExecute (db, query)
    
    # Drop Raw Table
    query <- "DROP TABLE superbowloffensivestats_raw"
    dbExecute (db, query)
  }
  
}

createdb()

getFavoriteTeam <- function(account_id){
  
  return(dbGetQuery(db, "SELECT t.team, t.team_id
                    FROM favorite_team as f
                    INNER JOIN team as t on t.team_id = f.team_id
                    WHERE account_id = ?",params = account_id))
}

getPlayersByYear <- function(year){
  
  return(dbGetQuery(db, "SELECT p.player, s.player_id, s.year
                    FROM stats as s
                    LEFT JOIN player as p ON p.player_id = s.player_id
                    WHERE year = ?",params = year))
}

getStatsByYear <- function(){
  
  return(dbGetQuery(db, "SELECT year AS Year, SUM(completions) as 'Completion Sum', SUM(pass_attempts) as 'Pass Attempt Sum',SUM(passing_yards) as 'Passing Yards Sum',
                    SUM(passing_td) as 'Passing TD Sum',SUM(interception) as 'Interception Sum',SUM(times_sacked) as 'Times Sacked Sum',SUM(sack_yards) as 'Sack Yards Sum',
                    SUM(longest_pass) as 'Longest Pass Sum',SUM(qbr) as 'QBR Sum',SUM(rush_attempts) as 'Rush Attempts Sum',SUM(rushing_yards) as 'Rushing Yards Sum',
                    SUM(rushing_td) as 'Rushing TD Sum',SUM(longest_run) as 'Longest Run Sum',SUM(receptions) as 'Receptions Sum',SUM(receiving_yards) as 'Receiving Yards Sum',
                    SUM(receiving_td) as 'Receiving TD Sum',SUM(longest_reception) as 'Longest Reception Sum',SUM(fumble) as 'Fumble Sum',SUM(fumbles_lost) as 'Fumbles Lost Sum'
                    FROM stats as s
                    GROUP BY year"))
}

teams <- dbGetQuery(db, 'SELECT team FROM team;')

# getTeam <- function(team) {
#   
#   return(dbGetQuery(db, "SELECT t.team as Team, COUNT(s.year) as 'Number of Appearances', s.year as 'Last Appearance'
#                     FROM stats AS s
#                     LEFT JOIN player as p ON p.player_id = s.player_id
#                     LEFT JOIN team as t ON p.team_id = t.team_id
#                     WHERE t.team = ?", param = team1)
#                     )
# }
# 
# getPlayer <- function(param1, param2){
#   
#   return(dbGetQuery(db, "SELECT p.player AS Player, s.year AS Year, s.completions AS Completions, s.pass_attempts AS 'Pass Attempts', s.passing_yards AS 'Passing Yards', s.passing_td AS 'Passing Touchdowns', s.rush_attempts AS 'Rush Attempts', 
#                           s.rushing_yards AS 'Rushing Yards', s.rushing_td AS 'Rushing Touchdowns'
#                     FROM stats as s
#                     LEFT JOIN player as p ON p.player_id = s.player_id
#                     WHERE p.player IN (?, ?)", params = param1, param2))
#}

bg <- 'https://i.postimg.cc/hvRSR6Ys/Vector-1.png'