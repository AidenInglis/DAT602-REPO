use gamedb;

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

        -- Ensure no overlap with player and monster
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

    select 'Board created with player, monster, and treasures.' as message;
end$$
delimiter ;

call make_a_board(10,10);
select * from tblTile;
