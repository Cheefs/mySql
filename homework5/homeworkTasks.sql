/* 
	1) Пусть в таблице users поля created_at и updated_at оказались незаполненными.
	Заполните их текущими датой и временем.
    для данного задания, я изменил код заполнения, внеся null в эти поля
 */
 use sample;
 update users set 
	created_at = now(), 
    updated_at = now() 
Where created_at is null && created_at Is null;
  
/* 
	Таблица users была неудачно спроектирована. 
	Записи created_at и updated_at были заданы типом VARCHAR и 
	в них долгое время помещались значения в формате "20.10.2017 8:10". 
	Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
*/

/** подготовка к условию задачи, делаю неверный формат, сам тип VARCHAR сменил еще на этапе создания таблиц  */
update users set 
	created_at = DATE_FORMAT(CURRENT_TIMESTAMP, '%d.%m.%Y %H:%i:%s'), 
    updated_at = DATE_FORMAT(CURRENT_TIMESTAMP, '%d.%m.%Y %H:%i:%s');
 
alter table users 
Add column craeted_at_new DATETIME DEFAULT CURRENT_TIMESTAMP,
Add column updated_at_new DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

UPDATE users 
	set 
    craeted_at_new = STR_TO_DATE(  REPLACE(created_at, '.', '-'), '%Y-%m-%d %H%i:%s' ),
    updated_at_new = STR_TO_DATE(  REPLACE(updated_at, '.', '-'), '%Y-%m-%d %H%i:%s' );

alter table users 
DROP COLUMN created_at,
DROP COLUMN updated_at,
CHANGE COLUMN craeted_at_new craeted_at DATETIME,
CHANGE COLUMN updated_at_new updated_at DATETIME;

select* from users

/* В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, 
 если товар закончился и выше нуля,если на складе имеются запасы.
 Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
 Однако, нулевые запасы должны выводиться в конце, после всех записей.
 */
 
 select * from storehouses_products Order by storehouse_id, value = 0 ASC, value != 0 DESC
 
/* (по желанию) 
	Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
    Месяцы заданы в виде списка английских названий ('may', 'august') 
*/
SELECT * FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');

/* 
	(по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
	Отсортируйте записи в порядке, заданном в списке IN. 
*/
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD (id, 5,1,2);

/* Подсчитайте средний возраст пользователей в таблице users */
select  round( 
		avg( 
			TIMESTAMPDIFF(YEAR, birthday_at, now() ) 
		)
	) AS age from users 

/* 
	Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
    Следует учесть, что необходимы дни недели текущего года, а не года рождения.
*/
-- select DAY(birthday_at) from users

select 
	 ( SELECT count(birthday_at) FROM users WHERE DAYOFWEEK(birthday_at) = 1 ) as Sunday, 
	 ( SELECT count(birthday_at) FROM users WHERE DAYOFWEEK(birthday_at) = 2 ) as Monday,
     ( SELECT count(birthday_at) FROM users WHERE DAYOFWEEK(birthday_at) = 3 ) as Saturday,
     ( SELECT count(birthday_at) FROM users WHERE DAYOFWEEK(birthday_at) = 4 ) as Wednesday,
     ( SELECT count(birthday_at) FROM users WHERE DAYOFWEEK(birthday_at) = 5 ) as Thursday,
     ( SELECT count(birthday_at) FROM users WHERE DAYOFWEEK(birthday_at) = 6 ) as Friday,
     ( SELECT count(birthday_at) FROM users WHERE DAYOFWEEK(birthday_at) = 7 ) as Saturday;
     
/* (по желанию) Подсчитайте произведение чисел в столбце таблицы */
select round( exp(sum(log(value))) ) AS total from storehouses_products where value > 0;

 
