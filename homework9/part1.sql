/**
	Создайте таблицу logs типа Archive. 
	Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs 
    помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
*/
use shop;
DROP TABLE if exists `logs`;
CREATE TABLE `logs`  (
	id serial,
	table_name VARCHAR(256),
	record_id bigint unsigned not null,
    record_name varchar(256),
    create_date datetime not null default current_timestamp
)ENGINE ARCHIVE CHARACTER SET utf8;

/** trigger to users */
DROP trigger if exists users_after_insert;
DELIMITER //
CREATE trigger users_after_insert after insert 
on users
FOR each row 
	begin
		insert into `logs` 
			SET table_name = 'users',
            record_id = new.id,
            record_name = new.name,
            create_date = new.created_at;
	end//

 /** trigger to catalogs */
DROP trigger if exists catalogs_after_insert;
CREATE trigger catalogs_after_insert after insert 
on catalogs
FOR each row 
	begin
		insert into `logs` 
			SET table_name = 'catalogs',
            record_id = new.id,
            record_name = new.name,
            create_date = now();
	end//

 /** trigger to products */
DROP trigger if exists products_after_insert;
CREATE trigger products_after_insert after insert 
on products
FOR each row 
	begin
		insert into `logs` 
			SET table_name = 'products',
            record_id = new.id,
            record_name = new.name,
            create_date = new.created_at;
	end//
    
DELIMITER ;   
insert into users (name) values ('testUSer');
insert into catalogs (name) values ('testCatalog');
insert into products (name) values ('testProduct');
select * from `logs`

/**
	(по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
*/
DELIMITER //
DROP procedure if exists fillUsers;
create procedure fillUsers()
	begin
		declare i int;
        SET i = 0;
        -- while i <= 1000000 DO  Данный запрос очень долго выполняется, и может отлететь по таймауту поэтому для примера просто уменьшил колличество итераций
        while i <= 1000 DO
			insert into users (name) values ( concat('user', i) );
            SET i = i + 1;
		end while;
    end//
  DELIMITER ; 
CALL fillUsers();
select * from users;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) COMMENT 'Имя покупателя',
  birthday_at DATE COMMENT 'Дата рождения',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) engine MyISAM COMMENT = 'Покупатели';