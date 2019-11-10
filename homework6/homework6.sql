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
	END AS res