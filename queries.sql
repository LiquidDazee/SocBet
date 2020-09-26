CREATE DATABASE matchBot;

CREATE TABLE users(
user_id INT AUTO_INCREMENT,
username VARCHAR(30),
coins INT,
PRIMARY KEY(user_id)
);

CREATE TABLE fixtures(
fixture_id INT AUTO_INCREMENT,
home VARCHAR(30),
home_evens FLOAT,
away VARCHAR(30),
away_evens FLOAT,
draw_evens FLOAT,
m_starts DATETIME,
m_ends DATETIME,
RESULT VARCHAR(1),
league_id INT,
PRIMARY KEY(fixture_id)
);

ALTER TABLE fixtures
ADD COLUMN isPostponed bool;

SELECT * FROM fixtures;

SELECT * FROM bets;

SELECT * FROM users;

DELETE FROM bets WHERE betAmount<0;

INSERT INTO bets VALUES (5, 9, 2, 10, 592155, 'H', 0);

UPDATE fixtures SET home_evens = NULL WHERE isPostponed = 1;

UPDATE bets SET successful = NULL WHERE bet_id = 2;

SELECT COUNT(*) FROM bets WHERE user_id = '9' AND successful is NULL;

CREATE TABLE bets(
bet_id INT AUTO_INCREMENT,
user_id INT,
betEvens FLOAT,
betAmount INT,
fixture_id INT,
bet_on VARCHAR(1),
successful bool,
PRIMARY KEY(bet_id),
FOREIGN KEY(user_id) REFERENCES users(user_id),
FOREIGN KEY(fixture_id) REFERENCES fixtures(fixture_id)
);

SELECT * FROM fixtures where isPostponed = 1;

UPDATE users SET coins = 99999 where user_id = 9;

DELETE FROM bets WHERE bet_id = 5;

CREATE OR REPLACE VIEW v_next_matches AS SELECT a.* FROM fixtures a JOIN
    (
    SELECT
        fixture_id,
        MIN(STR_TO_DATE(m_starts, '%Y-%m-%d')) AS next_fixture_date
    FROM
        fixtures
    WHERE
        m_starts>NOW()
    GROUP BY
        fixture_id
    ) 
    b
    ON  a.fixture_id = b.fixture_id
    AND STR_TO_DATE(a.m_starts, '%Y-%m-%d') = b.next_fixture_date
    ORDER BY m_starts;

SELECT * FROM v_next_matches LIMIT 3;

SELECT * FROM v_next_matches where m_starts>NOW();


DROP TRIGGER update_bets;
DROP TRIGGER update_amount;

UPDATE fixtures SET result = null where fixture_id = '592155';

UPDATE fixtures SET result = "H" where fixture_id = '592154';

UPDATE fixtures SET result = "H" where fixture_id = '592155';

UPDATE users SET coins = 100;

DELETE FROM bets;

CREATE TRIGGER update_bets AFTER UPDATE ON fixtures 
FOR EACH ROW 
	UPDATE bets
    SET successful = CASE
		WHEN bets.bet_on = NEW.result THEN 1
        ELSE 0
        END
    WHERE bets.fixture_id = NEW.fixture_id;
    
CREATE TRIGGER update_amount AFTER UPDATE ON bets
FOR EACH ROW
	UPDATE users
    SET coins = IF(NEW.successful = 1, coins + NEW.betAmount * NEW.betEvens, coins)
		WHERE users.user_id = NEW.user_ID;
    
    
CREATE USER 'neelak'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'neelak'@'%' WITH GRANT OPTION;
    
FLUSH PRIVILEGES;
--     
--     UPDATE users
--     SET coins = IF(bets.successful = 1, coins + bets.betAmount * bets.betEvens, coins)
--     WHERE user_id = (SELECT user_id FROM bets WHERE fixture_id = NEW.fixture_id);
-- END;

-- SELECT * FROM fixtures WHERE m_starts > DATE_SUB(NOW(), INTERVAL 1 WEEK) ORDER BY fixture_id DESC;

select * from fixtures where YEARWEEK(m_starts)= YEARWEEK(CURRENT_DATE());


SELECT home,away,m_starts, fixture_id, home_evens, away_evens, draw_evens FROM v_next_matches WHERE home LIKE 'Wolverhampton' or away LIKE 'Wolverhampton' LIMIT 1;

SELECT * FROM fixtures WHERE m_starts > CURRENT_DATE() AND m_starts < (CURRENT_DATE() + INTERVAL 7 DAY);