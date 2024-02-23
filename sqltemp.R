library(RSQLite)
library(DBI)
library(sqldf)

#write.table(superbowloffensivestats_raw, "data/superbowloffensivestats.csv", sep = ",", quote = FALSE, row.names = FALSE)

# create an empty database.
# can skip this step if database already exists.
sqldf("attach superbowl as new")
# or: cat(file = "testingdb")

# read into table called iris in the testingdb sqlite database
read.csv.sql("data/superbowloffensivestats.csv", sql = "create table superbowloffensivestats_raw as select * from file", 
             dbname = "superbowl", header = TRUE, sep = "," , eol = "\n")

# look at first three lines
sqldf("CREATE TABLE IF NOT EXISTS player(
	player_id INT AUTO_INCREMENT PRIMARY KEY
    ,player VARCHAR(50) 
    ,team CHAR(3));", dbname = "superbowl")
    
sqldf("INSERT INTO player (
	player
	,team
	)
SELECT DISTINCT player
	,team
FROM superbowloffensivestats_raw;", dbname = "superbowl")

sqldf("CREATE TABLE IF NOT EXISTS stats(
	id INT PRIMARY KEY
    , player_id INT REFERENCES player(player_id)
	,year INT
	,completions INT
	,pass_attempts INT
	,passing_yards INT
	,passing_td INT
	,interception INT
	,times_sacked INT
	,sack_yards INT
	,longest_pass INT
	,qbr VARCHAR(10) 	-- EE - This was a decimal field per the diagram, but getting an error due to empty string, so I made it varchar
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
	); ", dbname = "superbowl")

sqldf("INSERT INTO stats
SELECT  id 	
	,player_id AS player 	--  player_id from player table
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
LEFT JOIN player p ON r.player = p.player
				   AND r.team = p.team;", dbname = "superbowl")

#Create account table 
sqldf("CREATE TABLE IF NOT EXISTS account(
	account_id INT AUTO_INCREMENT PRIMARY KEY
	,user_name VARCHAR(100)
	,password VARCHAR(255)
	); ", dbname = "superbowl")
    
#Inserting test user 
sqldf("INSERT INTO account (
	user_name
	,password
	)
VALUES (
	'homer_j_simpson'
	,'password'
	); ", dbname = "superbowl")

#Create account access table 
sqldf("CREATE TABLE IF NOT EXISTS account_access(
	account_id INT REFERENCES account(account_id), 
	id INT REFERENCES stats(id)
	); ", dbname = "superbowl")


# look at first three lines
sqldf("select * from stats", dbname = "superbowl")
