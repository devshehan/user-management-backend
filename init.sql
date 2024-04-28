DROP SCHEMA IF EXISTS firstschema CASCADE;
CREATE SCHEMA firstschema;

CREATE TABLE IF NOT EXISTS pulseusers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    user_name VARCHAR(50),
    email VARCHAR(50),
    mobile_number VARCHAR(15)
);

INSERT INTO pulseusers (name, user_name, email, mobile_number) VALUES
('John Doe', 'johndoe', 'johndoe@example.com', '1234567890'),
('Jane Doe', 'janedoe', 'janedoe@example.com', '0987654321'),
('Alice Smith', 'alicesmith', 'alicesmith@example.com', '1122334455'),
('Bob Johnson', 'bobjohnson', 'bobjohnson@example.com', '5566778899'),
('Charlie Brown', 'charliebrown', 'charliebrown@example.com', '9988776655');
