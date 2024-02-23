-- EE - our app has a really long name, so I shortened it to sbos (super bowl offensive stats) 
CREATE DATABASE IF NOT EXISTS sbos_app;
USE sbos_app;

/* 
EE - Please note** I've loaded the raw data file from Kaggle to table 'superbowloffensivestats_raw'
in sbos_app database. If youve loaded it to another table, please find + replace that table name. 

Double checking for data in raw table 
SELECT * FROM superbowloffensivestats_raw;
*/ 
 -- EE - Adding a DROP IF EXISTS to make it repeatable
DROP TABLE IF EXISTS player;
CREATE TABLE IF NOT EXISTS player(
	player_id INT AUTO_INCREMENT PRIMARY KEY
    ,player VARCHAR(50) 
    ,team CHAR(3));
    
-- populate player dimension 
INSERT INTO player (
	player
	,team
	)
SELECT DISTINCT player
	,team
FROM superbowloffensivestats;

-- Create stats table
DROP TABLE IF EXISTS stats;
CREATE TABLE IF NOT EXISTS stats(
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
	);

-- Populate stats table 
-- NP: had to switch the player_id and year columns, they were inserting the wrong values. Verified with queries below.
INSERT INTO stats
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
FROM superbowloffensivestats r
LEFT JOIN player p ON r.player = p.player
				   AND r.team = p.team;

-- Create account table 
DROP TABLE IF EXISTS account;
CREATE TABLE IF NOT EXISTS account(
	account_id INT AUTO_INCREMENT PRIMARY KEY
	,user_name VARCHAR(100)
	,password VARCHAR(255)
	);
    
-- Inserting test user 
INSERT INTO account (
	user_name
	,password
	)
VALUES (
	'homer_j_simpson'
	,'password'
	);

-- Create account access table 
DROP TABLE IF EXISTS account_access;
CREATE TABLE IF NOT EXISTS account_access(
	account_id INT REFERENCES account(account_id), 
	id INT REFERENCES stats(id)
	);
    
-- Creating a test access record 
INSERT INTO account_access 
VALUES (1, 1)
	,(1, 5)
	,(1, 10)
    ,(1, 28);

-- Queries
-- NP - making the following queries:
-- SELECTing user saved players
-- Search players on name
-- Delete user saved entry

-- Selecting user saved players based on 'current' user
SELECT p.player, p.team, s.year
FROM account_access AS aa
INNER JOIN account AS a ON aa.account_id = a.account_id
INNER JOIN stats AS s ON s.id = aa.id
INNER JOIN player AS p ON p.player_id = s.player_id
WHERE a.account_id = 1;

-- Search players
-- This would be a query where users are searching for a specific player. Here, a user is searching for player name Tom.
SELECT p.player, p.team, s.year
FROM player AS p
INNER JOIN stats AS s ON p.player_id = s.player_id
WHERE p.player LIKE '%Tom%';

-- Deleting a user saved player entry
-- Here the current user is deleting their saved entry for Tom Brady
DELETE FROM account_access
WHERE account_id = 1 and id = 28;


-- JS Finding team offensive stat averages over the years they played in the super bowl
-- Here a user is finding the average total rushing yards and yards per carry of every Patriots Player that performed a running play
SELECT s.year, p.team, p.player, AVG(s.rushing_yards) AS avg_rushing_yards, (s.rushing_yards/s.rush_attempts) AS yards_per_carry
FROM player AS p
INNER JOIN stats AS s ON p.player_id = s.player_id
WHERE p.team = 'NWE' AND s.rush_attempts != 0
GROUP BY s.year, yards_per_carry, p.player;


-- JS Here a user is finding the quarterback with the highest passing yards from the past 4 years
SELECT s.year, p.player, s.passing_yards
FROM player AS p
INNER JOIN stats AS s ON p.player_id = s.player_id
WHERE passing_yards IN (
SELECT DISTINCT MAX(passing_yards)
FROM stats
GROUP BY year
) AND s.passing_yards != 0 AND s.year > 2017
GROUP BY s.year, p.player, passing_yards
ORDER BY s.year;

-- JS Below is an example of a function that would allow users (or back end support) to update information in the stats table
-- The case below would be updaing if Joe Burrow threw an interception in the 2021 SuperBowl
/*
UPDATE stats
SET interception = 1, qbr = 97.6
WHERE player_id = 1
*/

-- JS This is a similar update function that would update if Kurt Warner had thrown for 2 more pass of 10 yards each in the 1999 SuperBowl
/*
UPDATE stats
SET completions = 26, pass_attempts = 47, passing_yards = 434, qbr = 101.8
WHERE player_id = 422
*/
