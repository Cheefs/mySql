/*Создайте базу данных example, 
  разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.
*/

drop database if exists example;
create database example;
use example;

create table users (
	id INT primary key unique not null,
    name varchar(128) 
);

insert into users (id, name) values
	(1, 'test1'),
    (2, 'test2')
;

SELECT * FROM users