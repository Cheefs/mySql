/**********************************************************************************************************************************
********************** Практическое задание по теме “Транзакции, переменные, представления” ***************************************
***********************************************************************************************************************************/

/*
	1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
    Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
*/
use shop;
START TRANSACTION;
delete from sample.users;
insert into sample.users 
SELECT * FROM users  where id = 1;
delete from users where id = 1;
Commit;

/** 
	2. Создайте представление, которое выводит название name товарной 
	позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
*/

CREATE OR REPLACE VIEW products_view AS
SELECT 
	p.id,
    p.name,
    p.description,
    p.price,
    c.name AS catalog
    from products p
    JOIN catalogs c on c.id = p.catalog_id;
    
/*
	3. (по желанию) Пусть имеется таблица с календарным полем created_at. 
    В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17.
    Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
    
    Конструкцию с Юнионами подсмотрел в интренете, пытался ее упростить но без тригеров и процедур незнаю как это сделать
*/

insert into products (name, description, price, catalog_id, created_at) values 
	('test1', 'test', 1, 1, '2018-08-01'),
    ('test2', 'test', 1, 2, '2018-08-04'),
    ('test3', 'test', 1, 3, '2018-08-16'),
    ('test4', 'test', 1, 4, '2018-08-17'),
	('test5', 'test', 1, 5, '2018-08-22');

select @start_day := '2018-08-01';
SELECT @last_day := LAST_DAY(@start_day);
select @conunt_days := datediff(@last_day, @start_day) + 1;
SELECT selected_date, 
	CASE
		when ( select created_at from products WHERE created_at = selected_date limit 1 ) THEN 1
		ELSE 0 
	END AS `exists`
 FROM 
(select adddate(@start_day, t4*10000 + t3*1000 + t2*100 + t1*10 + t0) selected_date from
 (select 0 t0 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t0,
 (select 0 t1 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t1,
 (select 0 t2 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t2,
 (select 0 t3 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t3,
 (select 0 t4 union select 1 union select 2 union select 3 union select 4 union select 5 union select 6 union select 7 union select 8 union select 9) t4) v
WHERE selected_date BETWEEN @start_day AND @last_day

/**
	4. (по желанию) Пусть имеется любая таблица с календарным полем created_at.
    Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
*/
START TRANSACTION;
DELETE from products where id not in (
	select * from (
		select id from products ORDER BY created_at DESC LIMIT 5
    ) ids
);
select * from products;
commit;

/**********************************************************************************************************************************
************* Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию) ***********************
***********************************************************************************************************************************/
/**
	Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны только запросы на чтение данных,
    второму пользователю shop — любые операции в пределах базы данных shop.
*/
DROP USER IF EXISTS shop_read;
CREATE USER shop_read IDENTIFIED WITH sha256_password BY 'pass';
DROP USER IF EXISTS shop;
CREATE USER shop IDENTIFIED WITH sha256_password BY 'pass';
SELECT User FROM mysql.user;

GRANT SELECT on shop.* TO shop_read;

SHOW GRANTS FOR shop_read;

GRANT ALL on shop.* to shop;
SHOW GRANTS FOR shop;

/**
	(по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ,
    имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
    Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.
*/
use shop;
CREATE TABLE IF NOT EXISTS accounts (
	id serial,
    name varchar(250),
    password varchar(250)
);
insert into accounts (name, password)
	values 
		('test', 'test'),
        ('test2', 'test2');

CREATE OR REPLACE VIEW username AS
SELECT a.id, a.name from accounts a;

DROP USER IF EXISTS user_read;
CREATE USER user_read IDENTIFIED WITH sha256_password BY 'pass';
GRANT SELECT on username to user_read;
SHOW GRANTS FOR user_read;

/**********************************************************************************************************************************
********************** Практическое задание по теме “Хранимые процедуры и функции, триггеры" **************************************
***********************************************************************************************************************************/
/**
	Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
    С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", 
    с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
    с 18:00 до 00:00 — "Добрый вечер", 
    с 00:00 до 6:00 — "Доброй ночи".
*/
DELIMITER //
DROP FUNCTION IF exists hello;
CREATE FUNCTION hello()
RETURNS varchar(100) DETERMINISTIC
BEGIN
	DECLARE hour_now INT;
    DECLARE res varchar(100);
    SET hour_now = DATE_FORMAT(NOW(), '%H');
   if ( hour_now >= 6 AND hour_now < 12  )
		THEN  SET res = 'Доброе утро';
   ELSEIF( hour_now >= 12 AND hour_now < 18 ) 
		THEN SET res = 'Добрый день';  
   ELSEIF( hour_now >= 18 AND hour_now <= 23)
		THEN SET res = 'Добрый вечер';
   ELSE SET res = 'Добрый ночи';  
   END IF;
   RETURN res;
END//

SELECT HELLO();
/**
	В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
    Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
    Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
    При попытке присвоить полям NULL-значение необходимо отменить операцию.
*/
use shop;
DROP TRIGGER IF EXISTS products_trigger;
DELIMITER //
CREATE TRIGGER products_trigger BEFORE INSERT ON products
FOR EACH ROW
BEGIN
DECLARE msg varchar(100);
		if  NEW.name IS null AND new.description is null
		then set msg = concat('Значения name и description не могут быть null одно и тоже время');
        signal sqlstate '45000' set message_text = msg;
     end if;
END//

insert into products (name, description) values
	(null, null)

/**
	(по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи.
    Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
    Вызов функции fib(10) должен возвращать число 55.
*/

DELIMITER //
DROP FUNCTION IF exists fib//
CREATE FUNCTION fib (n INT)
RETURNS INT DETERMINISTIC
BEGIN
  	declare a, b, counter, tmp int;
    set a = 1; set b = 1; set tmp = 0; set counter = 3;
    
    while counter <= n do
		set tmp = a + b;
        set a = b;
        set b = tmp;
        set counter = counter + 1; 
	end while;
    
	return b;
END//

Select fib(9)
