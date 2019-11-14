/*
	Повторить все действия по доработке БД vk.Заполнить новые таблицы. Повторить все действия CRUD.
	Подобрать сервис-образец для курсовой работы.
*/

use vk;
/* вносим поле is_deleted, на уроке мы использывали его как альтернативу удалению */
Alter table users 
DROP column is_deleted, /** пока мы неумеем писать процедуры, просто удаляем колонку при перезапуске скрипта */
ADD column is_deleted bool default false comment 'флаг активности записи';

 /* повторяю первый тип селекта, в данный момент у нас нет в таблице поля is_deleted */
INSERT INTO `users` (`id`, `firstname`, `lastname`, `email`, `phone`) 
VALUES ('1000', 'One', 'Test', 'test@example.org', '1111111111');

/* 
	данный синтаксис удобен чтоб много данных заносить за 1 запрос, но если указанны не все поля, начинается ругатся что нехватает полей 
	поэтому пришлось ввести все, даже id
 */
INSERT INTO users VALUES
(1, 'Test', 'Testov', 'test1@example.org', 1111111111, false),
(2, 'Test', 'Testov', 'test2@example.org', 1111111111, false),
(3, 'Test', 'Testov', 'test3@example.org', 1111111111, true),
(4, 'Test', 'Testov', 'test4@example.org', 1111111111, false);

/* 
	но данная проблема легко решается перечислением полей которые нужны в insert,
	в таком случае автоикремент отработает, а все не заданные значение возщьмут значение по умолчанию
 */
INSERT INTO users (firstname, lastname, email) VALUES
('Test', 'Testov', 'test5@example.org' ),
('Test', 'Testov', 'test6@example.org' ),
('Test', 'Testov', 'test7@example.org' ),
('Test', 'Testov', 'test8@example.org' );

SELECT * FROM USERS;  /* просто проверка что все окей выше прошло */

/** очень удобный синтаксис если кодом формировать строку запроса */
INSERT INTO users
SET firstname = 'Иван', lastname = 'Иванов', email = 'ivan@mail.ru', phone = '987654321';

/** были еще запросы с подзапросами поэтому на этом шаге я продублировал базу, сделав vk2 как на уроке 
  и заполнил ее следующими данными 
  
    Генирацию данной базы я тут невтсвил чтоб не дублироватся, у вас она должна быть
	и чтобы не почистить ваши данные, удаляю только свои. Почему выборка по email? 
	потому что он имеет флаг уникальности, его я сам ниже ввожу им проще всего выбрать нужные записи

	Удаление произвожу используя синтаксис перечисления у условии, так удобнее, и удалю только то что там указал
 */
delete from vk2.users where email in ('vk21@example.org', 'vk22@example.org', 'vk23@example.org', 'vk24@example.org');
INSERT INTO vk2.users (firstname, lastname, email) VALUES
('vk2User1', 'vk2User1', 'vk21@example.org' ),
('vk2User2', 'vk2User2', 'vk22@example.org' ),
('vk2User3', 'vk2User3', 'vk23@example.org' ),
('vk2User4', 'vk2User4', 'vk24@example.org' );

/** проверил внов ставленные данные через синтаксис like */
select * from vk2.users where firstname LIKE '%vk2User%';
/* такое построение запроса с выборкой рассматривали на уроке, только я привязался не к id а к email  */
INSERT INTO `users` 
	(`id`, `firstname`, `lastname`, `email`, `phone`) 
select 
 	`id`, `firstname`, `lastname`, `email`, `phone`
from vk2.users
where email = 'vk21@example.org';

/* и на этом шаге, я понял, что нужно проиндексировать email , в своих запросах я часто обращаюсь к данному полю */
DROP INDEX email_inx ON users;
CREATE INDEX  email_inx ON users (email); /*  создал индекс на это полe  */

/* как говорил синтаксис SET удобный, попробую написать его с подзапросом на UPDATE */
UPDATE users
SET firstname = ( SELECT firstname from vk2.users limit 1 )
WHERE id < 3;

UPDATE users set firstname = 'firstname', lastname = 'lastname' where firstname like '%vk2user%';
SELECT * FROM  users where firstname = 'firstname';

INSERT INTO friend_requests (`initiator_user_id`, `target_user_id`, `status`)
VALUES 
('1', '4', 'requested'), 
('2', '4', 'requested'),
('3', '1', 'requested');

update friend_requests SET `status` = 'declined' WHERE
	initiator_user_id = 1 and target_user_id = 4;
--     
select initiator_user_id, target_user_id from friend_requests where `status` = 'declined';

/* очистка таблиц при необходимости */
-- truncate friend_requests;
-- delete from users;
