USE gamedb;

SET SQL_SAFE_UPDATES = 0; 

DROP USER if exists 'aiden'@'localhost';
CREATE USER 'aiden'@'localhost' IDENTIFIED BY '12345';
GRANT ALL ON gamedb.* TO 'aiden'@'localhost';

SELECT 'Connected to the DB' as STATUS;

INSERT Player( `Name`, `Password`, Email, isAdmin)
VALUES ('aiden', 'aiden', 'aiden', TRUE),
       ('user', 'user', 'user', FALSE);
       
SELECT * from Player;

#DROP PROCEDURE IF EXISTS Login;
DELIMITER $$
#CALL Login('aiden', 'aiden');
CREATE PROCEDURE Login( IN pName VARCHAR(50), IN pPassword  VARCHAR(50))
COMMENT 'Check login'
BEGIN
    DECLARE numAttempts INT DEFAULT 0;

    
    IF pName = '' OR pPassword = '' THEN
		SELECT 'Some fields are Empty, Please fill out all fields' AS MESSAGE;
	END IF;
    
	-- 'Check for valid login', 
    -- if valid then select message "Logged in" and reset Attempts to 0, 
    IF EXISTS ( SELECT * 
                FROM Player
                WHERE 
				  `Name` = pName AND
                  `Password` = pPassword 
                  and LOCKED_OUT = False)
	THEN
		UPDATE Player
        SET Attempts = 0
        WHERE
           `Name` = pName;
		SELECT 'Logged In' as Message, pName as `Name`, isAdmin FROM Player Where pName = `Name`;
    ELSE 
    -- else add to Attempts ,
        IF EXISTS(SELECT * FROM Player WHERE `Name` = pName) THEN 
        
			SELECT Attempts 
			INTO numAttempts
			FROM Player
			WHERE 
			   `Name` = pName;
			
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

#SELECT `Name`, Attempts 
#FROM Player;

#SELECT * from tblClickTarget;

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
		INSERT INTO Player(`Name`, `Password`, Email)
		VALUE (pName, pPassword, pEmail); -- Need to check the X,Y location
		SELECT 'ADDED USER NAME' AS MESSAGE, pName as `Name`, isAdmin FROM Player Where pName = `Name`;
	END IF;
    
  END IF;
  
END $$
DELIMITER ;

DROP PROCEDURE IF EXISTS DeletePlayer;
DELIMITER $$
CREATE PROCEDURE DeletePlayer(IN `pName` VARCHAR(50))
BEGIN
    DECLARE resultMessage VARCHAR(100);
    
    -- Check if the player exists
    IF EXISTS (SELECT 1 FROM Player WHERE Name = pName) THEN
        DELETE FROM Player WHERE Name = pName;
        SET resultMessage = CONCAT('Player ', pName, ' deleted successfully.');
    ELSE
        SET resultMessage = CONCAT('Player not found. You tried searching for user: ', pName);
    END IF;
    
    -- Return the result message
    SELECT resultMessage AS Message;
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


/*
DROP PROCEDURE IF EXISTS PlayerQuit;
DELIMITER $$
CREATE PROCEDURE PlayerQuit(pUserName VARCHAR(50))
BEGIN
	IF EXISTS ( SELECT * FROM tblClickTarget WHERE UserName = pUserName) THEN
     DELETE FROM tblClickTarget WHERE UserName = pUserName;
     SELECT 'QUIT' AS MESSAGE;
	ELSE
     SELECT 'PLAYER DOES NOT EXIST' AS MESSAGE;
	END IF;
END$$ -- PlayerQuit

DROP PROCEDURE IF EXISTS HitFrom$$
CREATE PROCEDURE HitFrom(pUserName varchar (50), pX integer, pY integer)
BEGIN
   IF EXISTS (SELECT * FROM tblClickTarget WHERE Username = pUserName) THEN
   BEGIN
      -- Target area is within 10 of the click at (X,Y)
      SELECT count(*) 
      FROM tblClickTarget
      WHERE 
        (pX >=  X - 10 AND pX <= X + 10 ) AND
        (pY >= Y - 10 AND pY <= Y + 10) AND 
        Username <> pUserName
	  INTO @HitCount;
      
      UPDATE tblClickTarget
      SET Strength = Strength + @HitCount
      WHERE 
            (NOT @HitCount IS NULL AND @HitCount <> 0 ) AND
            Username = pUsername;
            
	 UPDATE tblClickTarget
     Set Strength = Strength -1
     WHERE
        (pX >=  X - 10 AND pX <= X + 10 ) AND
        (pY >= Y - 10 AND pY <= Y + 10) AND 
        Username <> pUserName;
      
      DELETE FROM tblClickTarget
      WHERE Strength <= 0;
      
      SELECT 'PLAYED ' AS MESSAGE;
   END;
   ELSE
    SELECT 'PLAYER GONE' AS MESSAGE;
   END IF;
END$$


*/
DROP PROCEDURE IF EXISTS GetAllPlayers$$
DELIMITER $$
CREATE PROCEDURE GetAllPlayers()
BEGIN
	SELECT `Name`, Wins
	FROM Player ;
END$$

/*
DELIMITER $$
DROP PROCEDURE IF EXISTS Move$$
CREATE PROCEDURE Move(pMaxX INT, pMaxY INT)
BEGIN
  -- MOVES +/- 10 pixels, this might be boring, 
  -- also it does not check it the target
  -- moves out of bounds, presumes MinX and MinY are 0.
  SET @newX = ROUND(RAND() * 20) - 10;
  SET @newY = ROUND(RAND() * 20) - 10;
  
 SELECT count(*)
 FROM tblClickTarget 
 WHERE
      ((X + @newX) >= 0 AND (X + @newX) <= pMaxX) AND
      ((Y + @newY) >= 0 AND (Y + @newY) <= pMaxY)
 INTO @Count;
  
  UPDATE tblClickTarget
  SET 
      X =  X + @newX , 
      Y =  Y +  @newY 
  WHERE
     ((X + @newX) >= 0 AND (X + @newX) <= pMaxX) AND
	((Y + @newY) >= 0 AND (Y + @newY) <= pMaxY);
     
  SELECT CONCAT('Move Updated ' , @Count, ' click target positions. Within bounds  [',0,',',0,',',pMaxX,',',pMaXY,']') as Message; 
END$$

--
-- TESTING AREA

-- This procedure is "work in progress" 
DROP PROCEDURE IF EXISTS TestPlay$$
CREATE PROCEDURE TestPlay(pNumberOfPlayers INT)
BEGIN
      DECLARE counter INT DEFAULT 0;
       REPEAT
		 SET @NewName = CONCAT('Asterix', counter);
         CALL AddUserName(@NewName);
         SET counter = counter + 1;
       UNTIL counter > pNumberOfPlayers
       END REPEAT ;
END$$

DELIMITER ;
-- Call TestPlay(100);

Call AddUserName('Asterix');
Call AddUserName('Obelix');
Call AddUserName('Obelix');
Call HitFrom('Asterix',95,110);
Call HitFrom('Asterix',1,1);
Call HitFrom('Obelix',95,110);
Call HitFrom('Obelix',95,100);

Call GetAllPlayers();
CALL Move(1024,1024);

-- SELECT * 
-- FROM tblClickTarget;
Call GetAllPlayers();	

tblclicktarget
-- Call PlayerQuit('Asterix');
*/
