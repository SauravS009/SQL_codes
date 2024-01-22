CREATE DATABASE instagram;
use instagram;

CREATE TABLE users (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
		
		CREATE TABLE photos (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    image_url VARCHAR(255) NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id)
        REFERENCES users (id)
);
		
		CREATE TABLE comments (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    comment_text VARCHAR(255) NOT NULL,
    photo_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (photo_id)
        REFERENCES photos (id),
    FOREIGN KEY (user_id)
        REFERENCES users (id)
);
		
		CREATE TABLE likes (
    user_id INTEGER NOT NULL,
    photo_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id)
        REFERENCES users (id),
    FOREIGN KEY (photo_id)
        REFERENCES photos (id),
    PRIMARY KEY (user_id , photo_id)
);
		
		CREATE TABLE follows (
    follower_id INTEGER NOT NULL,
    followee_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (follower_id)
        REFERENCES users (id),
    FOREIGN KEY (followee_id)
        REFERENCES users (id),
    PRIMARY KEY (follower_id , followee_id)
);
		
		CREATE TABLE tags (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT NOW()
);
		
		CREATE TABLE photo_tags (
    photo_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    FOREIGN KEY (photo_id)
        REFERENCES photos (id),
    FOREIGN KEY (tag_id)
        REFERENCES tags (id),
    PRIMARY KEY (photo_id , tag_id)
);
 
 use ig_clone;
 
 -- 1 which are the oldest 5 users?
 
SELECT 
    *
FROM
    users
ORDER BY created_at
LIMIT 5;
 
 -- 2 what day of the week do most users register on?
 
SELECT 
    DAYNAME(created_at) AS day_of_week, COUNT(*) AS users_reg
FROM
    users
GROUP BY day_of_week
ORDER BY users_reg DESC;
 
 -- 2 find the users who are inactive (those who never posted a photo)
 
SELECT 
    users.id, username
FROM
    users
        LEFT JOIN
    photos ON users.id = photos.user_id
WHERE
    image_url IS NULL
ORDER BY users.id;

-- 3 who got the most likes on a single photo

SELECT 
    photo_id, COUNT(*) AS num_likes, photos.user_id, username
FROM
    likes
        JOIN
    photos ON likes.photo_id = photos.id
        JOIN
    users ON users.id = photos.user_id
GROUP BY photo_id
ORDER BY num_likes DESC
LIMIT 1;

-- another solution
select image_url,photo_id,num_likes,users.username
from users join (select image_url,photo_id, count(*) as num_likes,photos.user_id
from likes join photos on likes.photo_id = photos.id join users on users.id = likes.user_id
group by photo_id,photos.user_id
order by num_likes desc 
limit 5) as most_likes on users.id = most_likes.user_id;
 
 
-- 5 how many times does an average user posts?
    
SELECT 
    COUNT(*) / (SELECT 
            COUNT(*) AS y
        FROM
            users) AS x
FROM
    photos;
    
-- 4. top 5 most commonly used hashtags
    
SELECT 
    tag_name, COUNT(*) AS count_tags
FROM
    photo_tags
        JOIN
    tags ON tags.id = photo_tags.tag_id
GROUP BY tag_name
ORDER BY count_tags DESC
limit 7;

-- 7. find users who liked every single photo on the site ( mostly bots)

SELECT 
    id, username, COUNT(id) AS likes_count
FROM
    users
        JOIN
    likes ON users.id = likes.user_id
GROUP BY id
HAVING likes_count = (SELECT 
        COUNT(*)
    FROM
        photos);
