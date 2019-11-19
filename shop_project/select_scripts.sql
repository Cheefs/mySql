use brand_shop;

/** так как название браузера забыл в генераторе установить, сперва просто заполняем все поля */
update login_history SET browser = 'chrome'; 
update login_history SET browser = 'firefox' WHERE user_id % 2 = 0 ;
update login_history SET browser = 'opera' WHERE user_id % 3 = 0 ;
update login_history SET browser = 'safari' WHERE user_id % 4 = 0 ;

/** найдем всех пользователей opera, и выведем информацию о них */
select 
	up.user_id,
    concat(up.last_name, ' ', up.first_name, ' ', up.second_name) AS full_name,
    up.bio,
    up.phone,
    u.email,
    lh.browser
from users u
	JOIN users_profiles up on up.user_id = u.id
	JOIN login_history lh on lh.user_id = u.id 
WHERE lh.browser = 'opera' AND u.is_deleted <> true;

/** просто добавление новых записей, чтог после их удалить */
insert into order_statuses (alias, name) values
	('testStatus', 'test1'),
	('testStatus', 'test2');
/** удаляем только выставляя признак */    
update order_statuses 
	set is_deleted = true
    WHERE alias = 'testStatus';

/** скприп получения заказов пользователей */
SELECT 
	o.id, o.order_no, o.status_id,
    c.user_id,
    p.name AS product,
    ( select pc.category_name from products_categories pc where pc.id = p.category_id ) AS category,
    
    o.create_date
 FROM orders o 
	JOIN cart c on c.id = o.cart_id 
    JOIN cart_products cp on cp.cart_id = c.id
    JOIN products p ON p.id = cp.product_id
WHERE o.status_id in (
	select s.id from order_statuses s WHERE s.is_deleted = false
);

/** имитация добавление товара в корзину и в заказ( данная задача будет вынесена в процедуру, так как она будет частой, а входные параметры будут как для юзера так и для товара ) */    
START transaction;
	insert into users (email, password)
		VALUES ('test@test.tt', 'tttttt');
	insert into cart (user_id, products_count, price) VALUES ( (select last_insert_id()), 4, 500 );
    SELECT @cart_id := last_insert_id();
    insert into cart_products (cart_id, product_id, product_price) 
    values	( @cart_id, 1, 100 ), ( @cart_id, 2, 100 ), ( @cart_id, 4, 100 ),( @cart_id, 6, 100 );
    
	insert into orders (order_no, status_id, cart_id ) values ('18279434',1, @cart_id );
commit;
update users set is_deleted = true WHERE email LIKE '%test@test.tt%';

/** если пользователь удален, удаляем и его заказы и выставляем им статус отмененные */
START transaction;
update orders o
	set o.is_deleted = true,
		o.status_id = ( select id from order_statuses where alias = 'declined' )
WHERE o.cart_id IN (
	SELECT c.id from cart c
    join users u on u.id = c.user_id WHERE u.is_deleted = true
);
commit;

/** просмотр груп пользователя */
select * from `groups` g
JOIN users_groups ug on ug.group_id = g.id WHERE ug.user_id = 1;

/** выборка какихто продуктов по цветам */
select * from products p
JOIN product_details pd ON pd.product_id = p.id 
WHERE pd.color_id IN (
	SELECT id from colors WHERE is_deleted = false AND name like '%re%'
);

/** Аналогично с историей логина, обновим список брендов */
update brands SET `name` = 'main_brand', is_deleted = false WHERE id = 1; 
update product_details pd
	SET pd.brand_id = (
		Select id from brands where `name` = 'main_brand'
    )
WHERE pd.brand_id % 3 = 0;

/** выборка бренгдов и колличество товаров в магазине данных брендов */
SELECT 
	b.*,
    ( SELECT count(*) from products p
        JOIN product_details pd on pd.product_id = p.id
        WHERE pd.brand_id = b.id
    ) AS products_count
 from brands b 
WHERE b.is_deleted <> true	order by products_count DESC;

/** так как и discount types криво заполнены почистим их */
update discount_types SET is_deleted = false WHERE id = 1;
update discount_types SET type = 'percent' WHERE id = 2;
update discounts set  discount_type_id = 1;
update discounts set  discount_type_id = 2 WHERE id % 3 = 0;
update discounts set  discount = FLOOR( 1 + RAND( ) * 25 ) WHERE discount = 0;
update discounts set  discount = FLOOR( 1 + RAND( ) * 50 ) WHERE discount > 100 AND discount_type_id = 2;
update discounts set  discount = FLOOR( 1 + RAND( ) * 5000 ) WHERE discount > 1000;

delete from discount_types where id > 2;

/** выбераем все товары со скидкой типа процент */
SELECT 
	p.id,
	p.name,
    pd.price,
	d.discount,
    dt.type
FROM products p
	JOIN product_details pd on pd.product_id = p.id
	JOIN product_to_discounts ptd on ptd.product_id = p.id AND ptd.is_deleted = false
	join discounts d on d.id = ptd.discount_id AND d.is_deleted = false
	join discount_types dt on dt.id = d.discount_type_id AND dt.is_deleted = false AND dt.type = 'percent'
WHERE p.is_deleted = false;

/** переименуем первую группу, будет она базовая для новых пользователей */
update `groups` set name = 'admins', is_deleted = false WHERE id = 1;
update `groups` set name = 'users', is_deleted = false WHERE id = 2;