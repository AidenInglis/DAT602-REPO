DROP DATABASE IF EXISTS gamedb;
CREATE DATABASE gamedb;
USE gamedb;
-- Table List in Order Here
-- Item, Player, Game, Tile, Monster, ItemInventory, PlayerChat
DELIMITER $$
CREATE PROCEDURE TablesCreation()
BEGIN
    -- Drop existing tables if they exist
    DROP TABLE IF EXISTS Item, Player, Game, Tile, Monster, ItemInventory, PlayerChat;

    -- Create tables
    CREATE TABLE Item (
        ItemID INT PRIMARY KEY AUTO_INCREMENT,
        `Name` VARCHAR(255),
        EffectType VARCHAR(255),
        EffectAmount INT
    );

    CREATE TABLE Player (
        PlayerID INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
        `Name` VARCHAR(255),
        `Password` VARCHAR(255),
        `Status` VARCHAR(255) DEFAULT 'OFFLINE',
        Email VARCHAR(255),
        Attempts INT DEFAULT 0,
        LOCKED_OUT BOOL DEFAULT FALSE,
        isAdmin BOOL DEFAULT FALSE,
        Wins INT DEFAULT 0,
        Health INT DEFAULT 100,
        Strength INT DEFAULT 10,
        X INT DEFAULT 1, 
        Y INT DEFAULT 1,
        Item VARCHAR(50)
    );

    CREATE TABLE Game (
        GameID INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
        MapID INT,
        `Status` VARCHAR(255)
    );
    
    CREATE TABLE PlayerGame (
		PlayerID INT NOT NULL,
        GameID INT NOT NULL,
        Strength INT DEFAULT 10,
        Health INT DEFAULT 100,
        `Status` VARCHAR(50) DEFAULT 'ALIVE',
        X INT DEFAULT 1,
        Y INT DEFAULT 1,
        PRIMARY KEY (PlayerID, GameID),
		FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID) ON DELETE CASCADE,
		FOREIGN KEY (GameID) REFERENCES Game(GameID) ON DELETE CASCADE
    );	

    CREATE TABLE Tile (
        TileID INT PRIMARY KEY AUTO_INCREMENT,
        MapID INT,
        `Row` INT,
        `Col` INT,
        TileType INT,
        ItemID INT,
        FOREIGN KEY (MapID) REFERENCES Game(GameID)
    );

    CREATE TABLE Monster (
        MonsterID INT PRIMARY KEY AUTO_INCREMENT,
        Health INT,
        Strength INT,
        `Status` VARCHAR(255),
        GameID INT,
        FOREIGN KEY (GameID) REFERENCES Game(GameID)
    );

    CREATE TABLE ItemInventory (
        PlayerID INT,
        GameID INT,
        ItemID INT,
        ItemType VARCHAR(255),
        PRIMARY KEY (PlayerID, GameID, ItemID),
        FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
        FOREIGN KEY (GameID) REFERENCES Game(GameID),
        FOREIGN KEY (ItemID) REFERENCES Item(ItemID)
    );

    CREATE TABLE PlayerChat (
        ChatID INT PRIMARY KEY AUTO_INCREMENT,
        `Timestamp` TIMESTAMP,
        `Text` VARCHAR(255),
        PlayerID INT,
        GameID INT,
        FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
        FOREIGN KEY (GameID) REFERENCES Game(GameID)
    );
END$$
DELIMITER ;

CALL TablesCreation();

#DROP PROCEDURE IF EXISTS InsertsCreation;
DELIMITER $$
CREATE PROCEDURE InsertsCreation()
BEGIN
-- insert statements for tables
INSERT INTO Player (`Name`, `Password`, `Status`, isAdmin, Email, Wins)
VALUES 
('Name1', '12345', 'Online', true, 'aiden@email.com', '0'),
('Name2', 'Cheese534', 'Online', false, 'miachel@email.com', '1'),
('Name3', 'Cries123', 'Offline', false, 'jay@email.com', '5');

INSERT INTO Item (`Name`, EffectType, EffectAmount)
VALUES 
('Sword', 'Damage', 15),
('Mushroom', 'Damage', 5),
('Potion', 'Health', 50);

INSERT INTO Game (MapID, `Status`)
VALUES 
(NULL, 'active'),
(NULL, 'ended'),
(NULL, 'active');

INSERT INTO Map (GameID, ItemID, MonsterNo)
VALUES 
(1, 1, 1),
(2, 2, 2);

INSERT INTO Tile (MapID, ItemID)
VALUES 
(1, 3), -- Tile -- MapID 1, ItemID 3
(2, 2);

INSERT INTO Monster (Health, Strength, `Status`, GameID, MapID)
VALUES 
(100, 30, 'Alive', 1, 1),
(150, 20, 'Alive', 2, 2);

INSERT INTO PlayerGame (GameID, PlayerID, TileID, Health, Strength)
VALUES 
(1, 1, 1, 100, 25),
(2, 2, 2, 200, 20),
(1, 3, 1, 200, 20);

INSERT INTO ItemInventory (PlayerID, GameID, ItemID, ItemType)
VALUES 
(1, 1, 1, 'Weapon'),
(2, 2, 2, 'Armor');

INSERT INTO PlayerChat (`Timestamp`, `Text`, PlayerID, GameID)
VALUES 
(NOW(), 'Hello, World!', 1, 1),
(NOW(), 'Game on!', 2, 2);
END$$
DELIMITER ;

#CALL InsertsCreation();





-- BOARD CREATION SCRIPTS




#SELECT * FROM game;

drop table if exists tblTile;
drop table if exists tblBoard;
drop procedure if exists make_a_board;

create table tblBoard (
	ID int auto_increment primary key,
    max_row int not null default 10,
    max_col int not null default 10
);

create table tblTile(
	ID int auto_increment primary key,
    `row` int,
    `col` int,
    BoardID int not null,
    TileType int not null default 0,
    foreign key(BoardID) references tblBoard(ID)
);

drop function if exists get_tile_type;
delimiter $$
create function get_tile_type() returns int
deterministic
begin
    if Round(RAND() * 10) = 9  then 
		return 1;
	elseif Round(RAND() * 10) = 8  then 
		return 2;
	else 
		return 0;
	end if;
end$$
delimiter ;


delimiter $$
create procedure make_a_board(pMaxRow INT, pMaxCol INT)
begin
    declare new_board_id int;
    declare current_row int default 1;
    declare current_col int default 1;
    declare tile_type int default 0;
    declare treasure_count int default 0;

    insert into tblBoard(max_row, max_col)
    value(pMaxRow, pMaxCol);

    set new_board_id = last_insert_id();
    
    -- Set player at (1,1)
    insert into tblTile(BoardID, `row`, `col`, TileType)
    values(new_board_id, 1, 1, 1);

    -- Set monster at (10,10)
    insert into tblTile(BoardID, `row`, `col`, TileType)
    values(new_board_id, 10, 10, 5);

    -- Place 4 treasures at random positions
    while treasure_count < 4 do
        set current_row = floor(rand() * pMaxRow) + 1;
        set current_col = floor(rand() * pMaxCol) + 1;

        -- Ensure no overlap with player and monster, will go around them.
        if not exists (select 1 from tblTile where `row` = current_row and `col` = current_col) then
            insert into tblTile(BoardID, `row`, `col`, TileType)
            values(new_board_id, current_row, current_col, 3);
            set treasure_count = treasure_count + 1;
        end if;
    end while;

    -- Fill the rest of the grid with normal tiles
    set current_row = 1;
    set current_col = 1;
    while current_row <= pMaxRow do
        while current_col <= pMaxCol do
            if not exists (select 1 from tblTile where `row` = current_row and `col` = current_col) then
                insert into tblTile(BoardID, `row`, `col`, TileType)
                values(new_board_id, current_row, current_col, 0);
            end if;
            set current_col = current_col + 1;
        end while;
        set current_col = 1;
        set current_row = current_row + 1;
    end while;

    #select 'Board created with player, monster, and treasures.' as message;
end$$
delimiter ;

call make_a_board(10,10);
#select * from tblTile;






-- USER SCRIPTS 





SET SQL_SAFE_UPDATES = 0; 

DROP USER if exists 'aiden'@'localhost';
CREATE USER 'aiden'@'localhost' IDENTIFIED BY '12345';
GRANT ALL ON gamedb.* TO 'aiden'@'localhost';

#SELECT 'Connected to the DB' as STATUS;

INSERT Player( `Name`, `Password`, Email, isAdmin)
VALUES ('aiden', 'aiden', 'aiden', TRUE),
       ('user', 'user', 'user', FALSE);
       
#SELECT * from Player;
#SELECT * from Game;

#DROP PROCEDURE IF EXISTS Login;
DELIMITER $$
CREATE PROCEDURE Login( IN pName VARCHAR(50), IN pPassword  VARCHAR(50))
COMMENT 'Check login'
BEGIN
    DECLARE numAttempts INT DEFAULT 0;
    
    IF pName = '' OR pPassword = '' THEN
		SELECT 'Some fields are Empty, Please fill out all fields' AS MESSAGE;
	END IF;
	-- 'Check for valid login', if valid then select message "Logged in" and reset Attempts to 0, 
    IF EXISTS ( 
		SELECT * FROM Player WHERE `Name` = pName AND `Password` = pPassword and LOCKED_OUT = False)-- grab valid credentials not locked out player then...
	THEN
		UPDATE Player SET Attempts = 0, `Status` = 'ONLINE' WHERE `Name` = pName;
		SELECT CONCAT('Logged In As ', pName) AS Message, pName as `Name`, isAdmin FROM Player Where pName = `Name`;
    ELSE -- else add to Attempts ,
        IF EXISTS(SELECT * FROM Player WHERE `Name` = pName) THEN 
			SELECT Attempts INTO numAttempts FROM Player WHERE `Name` = pName;
			SET numAttempts = numAttempts + 1;
			IF numAttempts > 5 THEN 
			-- if Attempts > 5 then set lockout  to true and select message 'locked out' 
				UPDATE Player
				SET LOCKED_OUT = True
				WHERE 
					 `Name` = pName ;
				 SELECT 'Locked Out, Please contact a Administrator' AS Message, pName as `Name`, isAdmin FROM Player Where pName = `Name`;
			ELSE
			-- else select message 'Bad  password'
                 UPDATE Player
                 SET Attempts = numAttempts
                 WHERE 
                    `Name` = pName;
				 SELECT 'Invalid user name and password' AS MESSAGE, pName as `Name`, isAdmin FROM Player Where pName = `Name`;
			END IF;
      ELSE 
		SELECT 'Invalid user name and password' AS MESSAGE, pName as `Name`, isAdmin FROM Player Where pName = `Name`;
      END IF;
    END IF;
END $$
DELIMITER ;


#DROP PROCEDURE IF EXISTS Logout;
DELIMITER $$
CREATE PROCEDURE Logout(IN pCurrentPlayerName VARCHAR (50))
BEGIN
	UPDATE Player
    SET `Status` = 'OFFLINE'
    WHERE `Name` = pCurrentPlayerName;
    SELECT 'Player OFFLINE' AS MESSAGE;
END $$
DELIMITER ;


#DROP PROCEDURE IF EXISTS QuitGame;
DELIMITER $$
CREATE PROCEDURE QuitGame(IN pCurrentPlayerName VARCHAR (50))
BEGIN
	UPDATE Player
    SET `Status` = 'ONLINE'
    WHERE `Name` = pCurrentPlayerName;
    SELECT 'Player ONLINE' AS MESSAGE;
END $$
DELIMITER ;


#DROP PROCEDURE IF EXISTS AddUserName;
DELIMITER $$
CREATE PROCEDURE AddUserName(IN pName VARCHAR(50), IN pPassword VARCHAR(50), IN  pEmail VARCHAR(100))
BEGIN
  IF EXISTS (SELECT * FROM Player WHERE `Name` = pName) THEN
     SELECT 'USERNAME EXISTS' AS MESSAGE;
  ELSEIF EXISTS (SELECT * FROM Player WHERE Email = pEmail) THEN
     SELECT 'EMAIL ALREADY USED' AS MESSAGE;
  ELSE 
	IF pName = '' OR pPassword = '' OR pEmail = '' THEN
		SELECT 'Some fields are Empty, Please fill out all fields' AS MESSAGE;
	ELSEIF LENGTH(pName) < 5 OR LENGTH(pPassword) < 5 OR LENGTH(pEmail) < 5 THEN
        SELECT 'All fields require at least five characters.' AS MESSAGE;
	ELSE
		INSERT INTO Player(`Name`, `Password`, Email, `Status`)
		VALUE (pName, pPassword, pEmail, 'OFFLINE');
		SELECT 'ADDED USER NAME' AS MESSAGE, pName as `Name`, isAdmin FROM Player Where pName = `Name`;
	END IF;
    
  END IF;
  
END $$
DELIMITER ;

#SELECT * FROM PlayerGame;

DROP PROCEDURE IF EXISTS DeletePlayer;
DELIMITER $$
CREATE PROCEDURE DeletePlayer(IN `pName` VARCHAR(50))
BEGIN
    DECLARE resultMessage VARCHAR(100);
    DECLARE PlayerID INT;
    -- Check if the player exists
    IF EXISTS (SELECT 1 FROM Player WHERE Name = pName AND isAdmin = FALSE) THEN
		SELECT P.PlayerID INTO PlayerID FROM Player P WHERE Name = pName;
        DELETE FROM PlayerGame WHERE PlayerID = PlayerID;
        DELETE FROM Player WHERE PlayerID = PlayerID AND isAdmin = FALSE;-- Delete the player from Player table

        SET resultMessage = CONCAT('Player ', pName, ' deleted successfully.');
    ELSE
        SET resultMessage = CONCAT('Player not found or is an Admin. You tried searching for user: ', pName);
    END IF;
    SELECT resultMessage AS Message;-- Return the result message
END $$
DELIMITER ;
#Call DeletePlayer('user');


DELIMITER $$
CREATE PROCEDURE GetPlayerByName(IN pName VARCHAR(50))
BEGIN
    SELECT Name, Password, Email
    FROM Player
    WHERE Name = pName;
END $$
DELIMITER ;
#CALL UpdatePlayer('aiden', 'aiden_new', 'newPassword', 'newEmail@example.com');
#SELECT * FROM Player WHERE Name = 'aiden_new';

DELIMITER $$
CREATE PROCEDURE UpdatePlayer(IN pName VARCHAR(50), IN pNewName VARCHAR(50), IN pPassword VARCHAR(50), IN pEmail VARCHAR(100))
BEGIN
    UPDATE Player
    SET `Password` = pPassword, Email = pEmail, `Name` = pNewName
    WHERE `Name` = pName;

    SELECT 'Player details updated successfully.' AS Message;
END $$
DELIMITER ;

#DROP PROCEDURE IF EXISTS DeleteGame;
DELIMITER $$
CREATE PROCEDURE DeleteGame(IN `pGameID` VARCHAR(50))
BEGIN
    DECLARE resultMessage VARCHAR(100);
    
    -- Check if the game exists
    IF EXISTS (SELECT 1 FROM Game WHERE GameID = pGameID) THEN
        DELETE FROM Game WHERE GameID = pGameID;
        SET resultMessage = CONCAT('Game ', pGameID, ' deleted successfully.');
    ELSE
        SET resultMessage = CONCAT('Game not found. You tried searching for game: ', pGameID);
    END IF;
    
    -- Return the result message
    SELECT resultMessage AS Message;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS CreateNewGameInDatabase;
DELIMITER $$
CREATE PROCEDURE CreateNewGameInDatabase(IN mapID INT ,IN pCurrentPlayerName VARCHAR(50))
BEGIN
	DECLARE localPlayerID INT;
    DECLARE localGameID INT;
	INSERT INTO Game(mapID, `status`)
    VALUES (mapID, 'active');
	SELECT 'game made' AS MESSAGE;
    SELECT P.PlayerID INTO localPlayerID from Player P Where `Name` = pCurrentPlayerName;-- set PlayerID
    SELECT MAX(G.GameID) INTO localGameID FROM Game G;-- set GameID
	INSERT INTO PlayerGame(PlayerID, GameID)-- create playergame instance/variable or something.
    VALUES (localPlayerID, localGameID);
	UPDATE Player
    SET `Status` = 'IN GAME'
    WHERE `Name` = pCurrentPlayerName;
END $$
DELIMITER ;


DROP PROCEDURE IF EXISTS JoinGame;
DELIMITER $$
CREATE PROCEDURE JoinGame(IN pGameID INT, IN pCurrentPlayer VARCHAR(50))
BEGIN
    DECLARE localPlayerID INT;
    
    -- Retrieve the Player ID for the current player
    SELECT PlayerID INTO localPlayerID
    FROM Player
    WHERE `Name` = pCurrentPlayer;
    
    -- Check if the player and game exist
    IF localPlayerID IS NULL THEN
        SELECT 'Player not found' AS MESSAGE;
    ELSEIF NOT EXISTS (SELECT 1 FROM Game WHERE GameID = pGameID) THEN
        SELECT 'Game not found' AS MESSAGE;
    ELSE
        -- Add the player to the game
        IF NOT EXISTS (SELECT * FROM PlayerGame WHERE PlayerID = localPlayerID) THEN
			INSERT INTO PlayerGame (GameID, PlayerID)
			VALUES (pGameID, localPlayerID);
        END IF;
        -- Confirm join success
        SELECT 'Joined Game Successfully' AS MESSAGE;
    END IF;
END $$
DELIMITER ;



DROP PROCEDURE IF EXISTS GetAllPlayers
DELIMITER $$
CREATE PROCEDURE GetAllPlayers()
BEGIN
	SELECT `Name`, Wins
	FROM Player ;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS GetAllGames
DELIMITER $$
CREATE PROCEDURE GetAllGames()
BEGIN
	SELECT GameID, MapID, `Status`
	FROM Game ;
END$$
DELIMITER ;