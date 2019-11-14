/* Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине. */
-- join
use shop;
select * from users u
INNER JOIN orders o ON u.id = o.user_id;

-- подзапрос
select user_id From orders where user_id IN (
	SELECT id from users where id = user_id
);

/* Выведите список товаров products и разделов catalogs, который соответствует товару. ( постановка задания непонятна ) */
SELECT p.id,p.name, p.description, p.price, c.name as catalog  FROM products p
INNER JOIN catalogs c on c.id = p.catalog_id
WHERE p.id = 2;

/*
(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
 Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.
*/

DROP table if exists flights;
CREATE TABLE flights (
	id serial,
    `from` varchar(150),
    `to` varchar(150)
);

insert into flights (`from`, `to`) values 
	('moscow', 'omsk'),
    ('novgorod', 'kazan'),
    ('irkutsk', 'moscow'),
    ('omsk', 'irkutsk'),
	('moscow', 'kazan');
    
DROP table if exists cities;
CREATE TABLE cities (
    `label` varchar(150),
    `name` varchar(150)
);

insert into cities values 
	('moscow', 'Москва'),
    ('irkutsk', 'Иркутск'),
    ('novgorod', 'Новгород'),
    ('kazan', 'Казань'),
	('omsk', 'Омск');
    
SELECT id, 
	( select name from cities where label = `from`) as `from`,
	( select name from cities where label = `to`) as `to`
FROM flights;
    
    
    
