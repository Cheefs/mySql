DROP DATABASE IF EXISTS brand_shop;
CREATE DATABASE brand_shop;
USE brand_shop;

/********************************************************************************************** 
**********************  Структура работы с пользователями *************************************
***********************************************************************************************/

/* Создание базовой таблици пользователей, при регистрации заполняется в первую очередь она */
DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
    email varchar(128) unique NOT null comment 'Почта пользователя',
    `password` varchar(256) NOT NULL COMMENT 'Пароль',
    is_deleted boolean default false comment 'Флаг активности записи',
    create_date timestamp default now() comment 'Дата создания записи',
    
    INDEX user_email(email)
) comment 'Пользователи интернет магазина';

/* Таблица дополнительной информации о пользователях */
DROP TABLE IF EXISTS users_profiles;
CREATE TABLE users_profiles (
	id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
    user_id BIGINT UNSIGNED not null unique comment 'Сязь с таблицей пользователей',
	first_name varchar(128) NOT null comment 'Имя',
    second_name varchar(128) comment 'Отчество',
    last_name varchar(128) Not null comment 'Фамилия',
    bio text COMMENT 'О себе',
    phone varchar(12) not null comment 'Телефон',
	create_date timestamp default now() comment 'Дата создания записи',
    
	INDEX user_id_inx(user_id),
    FOREIGN KEY (user_id) REFERENCES users(id)
    	ON UPDATE CASCADE ON DELETE restrict
) comment 'Профили пользователей';

/* Группы для пользователей, чтоб было проще раздавать привелегии для них */
DROP TABLE IF EXISTS `groups`;
CREATE TABLE `groups` (
	id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
    `name` varchar(256) comment 'Название группы',
	is_deleted boolean default false comment 'Флаг активности записи',
    create_date timestamp default now() comment 'Дата создания записи',
    
	INDEX `group_name`(`name`)
) comment 'Список всех групп';

/* Действия ( если нужно будет группам отдельно накидывать права) */
DROP TABLE IF EXISTS actions;
CREATE TABLE actions (
	id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
    action_name varchar(256) not null unique comment 'Название действия',
    is_deleted boolean default false comment 'Флаг активности записи',
	create_date timestamp default now() comment 'Дата создания записи',
    
	INDEX `action_name_inx`(`action_name`)
) comment 'Таблица действий';

/* Действия которые доступны группам */
DROP TABLE IF EXISTS group_actions;
CREATE TABLE group_actions (
	group_id bigint unsigned not null comment 'Указатель на группу',
    action_id bigint unsigned not null comment 'Указатель на действие',
	create_date timestamp default now() comment 'Дата создания записи',

	INDEX `group_id_inx`(`group_id`),
    INDEX `action_id_inx`(`action_id`),
    FOREIGN KEY (group_id) REFERENCES `groups`(id)
		ON UPDATE CASCADE ON DELETE restrict,
	FOREIGN KEY (action_id) REFERENCES `actions`(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'Таблица связки действий и групп';

/* Связь пользователя с определенной группой */
DROP TABLE IF EXISTS users_groups;
CREATE TABLE users_groups (
    user_id BIGINT UNSIGNED not null comment 'Указатель на пользователя',
    group_id BIGINT UNSIGNED not null comment 'Указатель на группу пользователя',
	create_date timestamp default now() comment 'Дата создания записи',
    
	INDEX `user_id_inx`(`user_id`),
    INDEX `group_id_inx`(`group_id`),
    FOREIGN KEY (user_id) REFERENCES users(id)
    	ON UPDATE CASCADE ON DELETE restrict,
	 FOREIGN KEY (group_id) REFERENCES `groups`(id)
    	ON UPDATE CASCADE ON DELETE restrict
) comment 'Таблица связки групп и пользователей';

/* История авторизаций пользователя, нужна будет для сбора статистики */
DROP TABLE IF EXISTS login_history;
CREATE TABLE login_history (
    user_id BIGINT UNSIGNED not null comment 'Указатель на пользователя',
    login_time timestamp default now() comment 'Время последней авторизациина сайте',
    ip_address varchar(256) comment 'IP адресс пользователя с которой производитась авторизация',
    browser varchar(50) comment 'Браузер пользователя с которого он был авторизован',
	create_date timestamp default now() comment 'Дата создания записи',
    
	INDEX `user_id_inx`(`user_id`),
    INDEX `ip_address_inx`(`ip_address`),
	INDEX `browser_inx`(`browser`),

    FOREIGN KEY (user_id) REFERENCES users(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'История авторизаций';


/********************************************************************************************** 
**********************  Далее структура работы с товарами *************************************
***********************************************************************************************/

/* Категории товаров */
DROP TABLE IF EXISTS products_categories;
CREATE TABLE products_categories (
	 id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
     category_name varchar(256) not null unique comment 'Название категории товаров',
     is_deleted boolean default false comment 'Флаг активности записи',
	 create_date timestamp default now() comment 'Дата создания записи',
    
	INDEX `category_name_inx`(`category_name`)
) comment 'Категории товаров';

/* Таблица товаров магазина */
DROP TABLE IF EXISTS products;
CREATE TABLE products (
	 id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
     category_id bigint unsigned comment 'указание на категорию товаров',
     `name` varchar(256) not null comment 'Название товара',
     is_deleted bool DEFAULT false comment 'Флаг активности записи', 
	 create_date timestamp default now() comment 'Дата создания записи',
	INDEX `category_id_inx`(`category_id`),
    
	FOREIGN KEY (category_id) REFERENCES products_categories(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'Категории товаров';

/** справочник размеров */
DROP TABLE IF EXISTS sizes;
CREATE TABLE sizes (
	 id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
     name varchar(256) comment 'Название размера',
     is_deleted bool DEFAULT false comment 'Флаг активности записи', 
     create_date timestamp default now() comment 'Дата создания записи'
) comment 'Справочник размеров';

/** справочник цветов */
DROP TABLE IF EXISTS colors;
CREATE TABLE colors (
     id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
     name varchar(256) comment 'Название цвета',
	 is_deleted bool DEFAULT false comment 'Флаг активности записи', 
     create_date timestamp default now() comment 'Дата создания записи'
) comment 'Справочник цветов';

/** справочник брендов\производителей */
DROP TABLE IF EXISTS brands;
CREATE TABLE brands (
	id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
	name varchar(256) comment 'Название Бренда\производитель',
	logo varchar(256) comment 'Ссылка на файл с логотипом',
	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
	create_date timestamp default now() comment 'Дата создания записи'
) comment 'Справочник брендов\производителей';

/** справочник возварастных групп */
DROP TABLE IF EXISTS age_groups;
CREATE TABLE age_groups (
	id SERIAL PRIMARY KEY COMMENT 'Первичный ключь',
	name varchar(256) comment 'Название возврастной группы',
	min_age int unsigned not null comment 'Минимальный возвраст',
	max_age int unsigned comment 'Максимальный возвраст',
	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
	create_date timestamp default now() comment 'Дата создания записи'
) comment 'Справочник возварастных групп';

/* таблица хранит в себе все о товаре, */
DROP TABLE IF EXISTS product_details;
CREATE TABLE product_details (
     product_id bigint unsigned not null comment 'указание на категорию товаров',
     size_id bigint unsigned not null comment 'указатель на размер',
     color_id bigint unsigned not null comment 'указатель на цвет',
	 brand_id bigint unsigned not null comment 'указатель на бренд производитель',
     age_group_id bigint unsigned not null comment 'указатель на возврастную группу',
	 sex ENUM('man', 'woman') not null comment 'Пол',
	 `desc` varchar(256) comment 'описание товара',
	 price bigint unsigned comment 'Цена товара', 
     
     create_date timestamp default now() comment 'Дата создания записи',
     
	INDEX `sex_inx`(`sex`),
	INDEX `product_id_inx`(`product_id`),
	INDEX `size_id_inx`(`size_id`),
	INDEX `color_id_inx`(`color_id`),
    INDEX `brand_id_inx`(`brand_id`),
	INDEX `age_group_id_inx`(`age_group_id`),
	FOREIGN KEY (product_id) REFERENCES products(id)
		ON UPDATE CASCADE ON DELETE restrict,
	FOREIGN KEY (size_id) REFERENCES sizes(id)
		ON UPDATE CASCADE ON DELETE restrict,
	FOREIGN KEY (color_id) REFERENCES colors(id)
		ON UPDATE CASCADE ON DELETE restrict,
	FOREIGN KEY (brand_id) REFERENCES brands(id)
		ON UPDATE CASCADE ON DELETE restrict,
	FOREIGN KEY (age_group_id) REFERENCES age_groups(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'Таблица полной информации о товаре';

/* таблица видов скидок */
DROP TABLE IF EXISTS discount_types;
CREATE TABLE discount_types ( 
	id serial comment 'первичный ключ', 
    type ENUM('percent', 'price') comment 'тип скидки, процент от суммы, либо просто вычесть значение скидки со стоимости',
	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
	create_date timestamp default now() comment 'Дата создания записи',
    
    INDEX `type_inx`(`type`)
) comment 'Таблица видов скидок';

/* таблица скидок */
DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
	id serial comment 'первичный ключ', 
    discount bigint unsigned not null default '0' comment 'размер скидки',
    discount_type_id bigint unsigned not null comment 'тип скидки',
    
	is_deleted bool DEFAULT false comment 'Флаг активности записи',
	create_date timestamp default now() comment 'Дата создания записи',
	INDEX `discount_inx`(`discount`),
    FOREIGN KEY (discount_type_id) REFERENCES discount_types(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'таблица скидок';

/* таблица связки товара и скидки */
DROP TABLE IF EXISTS product_to_discounts;
CREATE TABLE product_to_discounts (
	product_id bigint unsigned not null comment 'указатель на товар',
    discount_id bigint unsigned not null comment 'указатель на скидку',
    
	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
    create_date timestamp default now() comment 'Дата создания записи',
    
	FOREIGN KEY (discount_id) REFERENCES discounts(id)
		ON UPDATE CASCADE ON DELETE restrict,
    FOREIGN KEY (product_id) REFERENCES products(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'Связь скидки с товаром' ;

/********************************************************************************************** 
**********************  Далее структура работы с отзывами о продукте ***************************
***********************************************************************************************/

/* Таблица колмментариев\отзывов к товару */
DROP TABLE IF EXISTS comments;
CREATE TABLE comments ( 
	id serial comment 'первичный ключ', 
    `comment` text comment 'Комментарий к товару\отзыв',
    likes bigint unsigned not null default 0 comment 'Колличество лайков\отметок что комментарий\отзыв полезный',
    dislikes bigint unsigned not null default 0 comment 'Колличество лайков\отметок что комментарий\отзыв не полезный',
	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
    create_date timestamp default now() comment 'Дата создания записи'
) comment 'Таблица колмментариев\отзывов к товару';

/* Таблица связки комментариев с продуктом и пользователем */
DROP TABLE IF EXISTS product_comments;
CREATE TABLE product_comments ( 
    user_id  bigint unsigned not null comment 'Указатель на пользовтеля',
    product_id bigint unsigned not null comment 'Указатель на продукт',
    comment_id bigint unsigned not null comment 'Указатель на комментарий к продукту',
    
	create_date timestamp default now() comment 'Дата создания записи',
    
	INDEX `comment_id_inx`(`comment_id`),
	INDEX `product_id_inx`(`product_id`),
    
    FOREIGN KEY (user_id) REFERENCES users(id)
		ON UPDATE CASCADE ON DELETE restrict,
	 FOREIGN KEY (product_id) REFERENCES products(id)
		ON UPDATE CASCADE ON DELETE restrict,
     FOREIGN KEY (comment_id) REFERENCES comments(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'Таблица связки комментариев с продуктом и пользователем ';

/********************************************************************************************** 
**********************  Далее структура работы с корзиной *************************************
***********************************************************************************************/

/* таблица корзины она у всех пользователей создается 1 раз, и активна всегда, удаляются только товары с нее через флаг deleted */
DROP TABLE IF EXISTS cart;
CREATE TABLE cart (
	id serial comment 'первичный ключ',
    user_id bigint unsigned not null comment 'Указатель на пользователя',
    products_count bigint unsigned default 0 comment 'колличество товаров',
    price varchar(256) default 0 comment 'Общая стоимость корзины',
    
	create_date timestamp default now() comment 'Дата создания записи',
    
    FOREIGN KEY (user_id) REFERENCES users(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'таблица корзины пользователей';

/* таблица связи товаров с корзиной пользователя */
DROP TABLE IF EXISTS cart_products;
CREATE TABLE cart_products (
	cart_id bigint unsigned not null comment 'указатель на корзину',
    product_id bigint unsigned not null comment 'указатель на товар',
    product_count int unsigned not null default 0 comment 'Колличество данного товара в корзине',
    product_price varchar(256) not null default 0 comment 'Колличество данного товара в корзине',

	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
    create_date timestamp default now() comment 'Дата создания записи',
    
	FOREIGN KEY (product_id) REFERENCES products(id)
		ON UPDATE CASCADE ON DELETE restrict,
	FOREIGN KEY (cart_id) REFERENCES cart(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'таблица связи товаров с корзиной пользователя';

/********************************************************************************************** 
**********************  Далее структура работы с заказом **************************************
***********************************************************************************************/

/* Таблица статусов заказа */
DROP TABLE IF EXISTS order_statuses;
CREATE TABLE order_statuses (
	id serial comment 'первичный ключ',
    alias varchar(256) not null comment 'Алиас\псевдоним который соответсвует статусу(чтоб не привызыватся к id или name поле технического характера)',
    `name` varchar(256) not null comment 'Название статуса (то что видят пользователи)',
    
	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
    create_date timestamp default now() comment 'Дата создания записи',
    
    INDEX `alias_inx`(alias)
) comment 'Статусы заказов';

/* таблица заказов */
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
	id serial comment 'первичный ключ',
    order_no varchar(500) not null unique comment 'Уникальный Номер заказа',
	status_id bigint unsigned not null comment 'Указатель на статус заказа',
    cart_id bigint unsigned not null comment 'Указатель на корзину, товарам которой соттветствует заказ',
    
	is_deleted bool DEFAULT false comment 'Флаг активности записи', 
    create_date timestamp default now() comment 'Дата создания записи',
    
	FOREIGN KEY (status_id) REFERENCES order_statuses(id)
		ON UPDATE CASCADE ON DELETE restrict,
	FOREIGN KEY (cart_id) REFERENCES cart(id)
		ON UPDATE CASCADE ON DELETE restrict
) comment 'Таблица заказов';
