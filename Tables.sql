use gamedb;

DELIMITER $$
DROP PROCEDURE IF EXISTS TablesCreation;
CREATE PROCEDURE TablesCreation()
BEGIN

DROP TABLE IF EXISTS PlayerGame, Playerchat, Monster, Game, Tile, Item, Map, ItemInventory, Player;
-- creating all my tables
CREATE TABLE Player (
    PlayerID INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    `Name` VARCHAR(255),
    `Password` VARCHAR(255),
    `Status` VARCHAR(255),
    Email VARCHAR(255),
    isAdmin BOOL,
    Wins INT
);

CREATE TABLE Game (
    GameID INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    MapID INT,
    `Status` VARCHAR(255)
);

CREATE TABLE PlayerGame (
    GameID INT,
    PlayerID INT,
    TileID INT,
    Health INT,
    Strength INT,
    PRIMARY KEY (GameID, PlayerID),
    FOREIGN KEY (GameID) REFERENCES Game(GameID),
    FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID)
);

CREATE TABLE Item (
    ItemID INT PRIMARY KEY AUTO_INCREMENT,
    `Name` VARCHAR(255),
    EffectType VARCHAR(255),
    EffectAmount INT
);

CREATE TABLE Map (
    MapID INT PRIMARY KEY AUTO_INCREMENT,
    GameID INT,
    ItemID INT,
    MonsterNo INT,
    FOREIGN KEY (GameID) REFERENCES Game(GameID)
);

CREATE TABLE Tile (
    TileID INT PRIMARY KEY AUTO_INCREMENT,
    MapID INT,
    ItemID INT,
    FOREIGN KEY (MapID) REFERENCES Map(MapID)
);

CREATE TABLE Monster (
    MonsterID INT PRIMARY KEY AUTO_INCREMENT,
    Health INT,
    Strength INT,
    `Status` VARCHAR(255),
    GameID INT,
    MapID INT,
    FOREIGN KEY (GameID) REFERENCES Game(GameID),
    FOREIGN KEY (MapID) REFERENCES Map(MapID)
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

 END;

Call TablesCreation();
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