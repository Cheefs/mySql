/** view таблица для пользователей, полная информация о них */
CREATE OR REPLACE VIEW users_view AS
SELECT 
	u.id,
    u.email,
    u.password,
    u.is_deleted,
    concat(up.last_name, ' ', up.first_name, ' ', up.second_name) AS fullname,
    up.bio,
    up.phone,
    ( SELECT lh.ip_address FROM login_history lh WHERE lh.user_id = u.id order by lh.login_time DESC LIMIT 1 ) AS last_ip,
	( SELECT lh.login_time FROM login_history lh WHERE lh.user_id = u.id order by lh.login_time DESC LIMIT 1 ) AS last_login,
	( SELECT cast(GROUP_CONCAT( g.name SEPARATOR ';') AS char )
			FROM users_groups ug 
			LEFT JOIN `groups` g on g.id = ug.group_id
            WHERE ug.user_id = u.id 
	) AS `groups`
    FROM users u
    INNER JOIN users_profiles up ON up.user_id = u.id;

/** view таблица для товаров магазина */
CREATE OR REPLACE VIEW products_view AS
SELECT 
	p.id,
    p.name,
	pd.sex,
	pd.price,
    pc.category_name AS category,
    pd.`desc`,
    s.name AS size,
    c.name AS color,
    ag.name AS age_group,
    b.name AS brand
    
	FROM products p
		JOIN products_categories pc ON pc.id = p.category_id AND pc.is_deleted <> false
		JOIN product_details pd ON pd.product_id = p.id
		JOIN sizes s ON s.id = pd.size_id AND s.is_deleted <> false
		JOIN colors c ON c.id = pd.color_id AND c.is_deleted <> false
		JOIN age_groups ag ON ag.id = pd.age_group_id AND c.is_deleted <> false
		JOIN brands b ON b.id = pd.brand_id AND b.is_deleted <> false;

/** view таблица для групп, и прав этих групп*/
CREATE OR REPLACE VIEW groups_view AS
SELECT 
	g.id,
    g.name,
	( SELECT cast(GROUP_CONCAT( a.action_name SEPARATOR ';') AS char )
			FROM group_actions ga 
			LEFT JOIN actions a on a.id =  ga.action_id AND a.is_deleted = 0
            WHERE ga.group_id = g.id 
	) AS `actions`
	FROM `groups` g WHERE g.is_deleted = 0;

/** view таблица для заказов */
CREATE OR REPLACE VIEW orders_view AS
SELECT 
	o.id,
	o.order_no,
    os.name as status,
    u.id AS user_id,
    o.create_date
	FROM orders o
    JOIN order_statuses os on os.id = o.status_id
    JOIN cart c on c.id = o.cart_id
    join users u on u.id = c.user_id
    WHERE o.is_deleted = 0;
select * from orders_view;