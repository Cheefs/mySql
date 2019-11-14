
/*
	• - Пусть задан некоторый пользователь. Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
*/
use vk;
SElect count(m.from_user_id) as count, m.from_user_id
	from messages m WHERE m.from_user_id IN (
		select initiator_user_id from friend_requests fr
			WHERE fr.initiator_user_id = m.from_user_id
			AND fr.status ='approved'
		union 
			select target_user_id from friend_requests fr
				WHERE fr.target_user_id = m.from_user_id
				AND fr.status ='approved'
	) AND m.to_user_id = 1
group by m.from_user_id order by count DESC  limit 1;
    
/*
	• - Подсчитать общее количество лайков, которые получили пользователи младше 10 лет..
*/
select count(*) from likes WHERE media_id IN (
	select m.id from media m where m.user_id IN (
		SELECT p.user_id from profiles p 
			WHERE  TIMESTAMPDIFF(year, p.birthday, now() ) < 10
    )
);

/*
 *	• - Определить кто больше поставил лайков (всего) - мужчины или женщины?
*/  
SELECT 
	CASE
		when (
			SELECT (
				SELECT COUNT(*) from likes l 
				WHERE l.user_Id 
				IN ( select p.user_id from profiles p WHERE p.gender = "f" ) 
			)
            > ( SELECT (
						SELECT COUNT(*) from likes l WHERE l.user_Id 
							IN ( select p.user_id from profiles p WHERE p.gender = "m")
					) 
			  )
		) THEN "женщины"
        ELSE "мужчины"
	END AS res;
  
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
