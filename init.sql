CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    email VARCHAR(50),
    mobilenumber VARCHAR(15)
);
