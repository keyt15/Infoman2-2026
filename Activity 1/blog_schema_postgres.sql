-- PostgreSQL Schema

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS comments (
    id SERIAL PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- -- Data for the tables
-- INSERT INTO users (username) VALUES ('alice'), ('bob');

-- INSERT INTO posts (user_id, title, body) VALUES
-- (1, 'First Post!', 'This is the body of the first post.'),
-- (2, 'Bob''s Thoughts', 'A penny for my thoughts.');

-- INSERT INTO comments (post_id, user_id, comment) VALUES
-- (1, 2, 'Great first post, Alice!'),
-- (2, 1, 'Interesting thoughts, Bob.');

-- Data for users table
INSERT INTO users (username) VALUES
('charlie'),
('bag-oyen'),
('navor'),
('fiona'),
('george');


-- Data for posts table
INSERT INTO posts (user_id, title, body) VALUES
(4, 'Hello World', 'This is Charlie''s first blog post.'),
(5, 'Daily Life', 'Sharing some daily experiences.'),
(6, 'Tech Talk', 'Let''s talk about technology today.'),
(7, 'Food Blog', 'I love cooking and eating food.'),
(8, 'Random Ideas', 'Just some random thoughts.');


-- Data for comments table
INSERT INTO comments (post_id, user_id, comment) VALUES
(3, 4, 'Nice introduction!'),
(4, 5, 'Very relatable post.'),
(5, 6, 'I agree with your points.'),
(6, 7, 'Now I am hungry 😂'),
(7, 3, 'Keep posting more content!');
