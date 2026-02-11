CREATE INDEX idx_posts_author_published
ON posts (author_id, published_at DESC);

CREATE INDEX idx_posts_title
ON posts(title);

CREATE INDEX idx_posts_published_at
ON posts (published_at);

CREATE INDEX idx_posts_author_date
ON posts (author_id, date DESC);
