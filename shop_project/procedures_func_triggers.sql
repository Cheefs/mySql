use brand_shop;

/** получение базовой группы пользователю */
DELIMITER //
DROP FUNCTION IF EXISTS get_base_group_id//
CREATE FUNCTION get_base_group_id()
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE group_name varchar(10); 
	SET group_name = 'users';
	return ( SELECT id FROM `groups` WHERE name = 'users' );
END//

/** получение фио пользователя по id */
DELIMITER //
DROP FUNCTION IF EXISTS get_user_fio//
CREATE FUNCTION get_user_fio(user_id int)
RETURNS varchar(256) DETERMINISTIC
BEGIN
	return (
		select concat(p.last_name,' ', p.first_name, ' ', p.second_name) 
        FROM users_profiles p where p.id = user_id
    );
END//

/** процедура присвоения группы пользователю */
DELIMITER //
DROP PROCEDURE IF EXISTS set_base_group//
CREATE PROCEDURE set_base_group (user_id int)
BEGIN
	INSERT INTO users_groups set 
		user_id = user_id,
		group_id = get_base_group_id();
END//

/** перед каждым занесением пользователя в базу, кодируем пароль*/
DELIMITER //
DROP TRIGGER IF EXISTS users_before_insert//
CREATE TRIGGER users_before_insert BEFORE INSERT ON users
FOR EACH ROW
BEGIN
	SET NEW.password = md5(NEW.password);
END//

/** после внесения пользователя в таблицу мы присваиваем ему базовую группу*/
DELIMITER //
DROP TRIGGER IF EXISTS users_before_insert//
CREATE TRIGGER users_before_insert after INSERT ON users
FOR EACH ROW
BEGIN
	CALL set_base_group(NEW.id);
END//
	
insert into users (email, password) values ('1241212sd3s', 'asdasd')

/** перед удалением групп проверяем что это не 'users' и не 'admins' */
DELIMITER //
DROP TRIGGER IF EXISTS groups_before_delete//
CREATE TRIGGER groups_before_delete BEFORE DELETE ON `groups`
FOR EACH ROW
BEGIN
	declare msg varchar(128);
	IF ( OLD.name IN ( 'users', 'admins' ) ) THEN 
        set msg = concat('Данная группа неможет быть удаленна');
        signal sqlstate '45000' set message_text = msg;
	end if;
END//

/** проверяем работу тригера */
insert into `groups` (name) values ('to_delete');
delete from `groups` where name = 'to_delete';
delete from `groups` where name = 'admins';

/** для проверки работы  триггера*/
insert into users (email, password) Values ('test@test.ttt', 'd');
select * from users_groups ORDER BY user_id DESC

/** процедура добавления пользователя в группу администраторы, по id */
DELIMITER //
DROP PROCEDURE IF EXISTS set_admin//
CREATE PROCEDURE set_admin (id int)
BEGIN
  SELECT @group_id := (
	SELECT g.id from `groups` g WHERE name = 'admins'
  );
  INSERT INTO users_groups (user_id, grpoup_id) VALUES
	( id , @group_id );
END//

/** процедура имитации регистрации, когда пользователь заполняет не только учетные данные
	или редактирует ( на данный момент полное обновление, предпологается что дергать процедуру будет бекенд у которого есть все данные )
 */
DELIMITER //
DROP PROCEDURE IF EXISTS  set_user_profile//
CREATE PROCEDURE set_user_profile (
		user_id int,
		new_email varchar(128), 
		new_password varchar(256), 
		new_last_name varchar(256) , 
		new_first_name varchar(256), 
		new_second_name varchar(256),
        new_bio text,
        new_phone varchar(12)
    )
BEGIN
	START TRANSACTION;
		IF user_id IS NULL
			THEN 
			INSERT INTO users 
				SET email = new_email,
				password = new_password;
			INSERT INTO users_profiles 
				SET 
					user_id = last_insert_id(),
					last_name = new_last_name,
					first_name = new_last_name,
					second_name = new_second_name,
					bio = new_bio,
					phone = new_phone;
		ELSE
			UPDATE users 
				SET email = new_email,
				password = md5(new_password)
			WHERE id = user_id;
			UPDATE users_profiles 
				SET 
					last_name = new_last_name,
					first_name = new_last_name,
					second_name = new_second_name,
					bio = new_bio,
					phone = new_phone
			WHERE user_id = user_id;
		END IF;
	COMMIT;
END//

/** проверяем нашу процедуру */
CALL set_user_profile(null, "treasdadasggfdastu", "asdas",3,4,5,6,7 );

select * from users u
JOIN users_profiles up on up.user_id = u.id
ORDER BY u.id DESC limit 10;

CALL set_user_profile(100, "32525325sds", "asdas",3,4,5,6,7 );