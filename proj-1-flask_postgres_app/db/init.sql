-- Create database and table for the Flask app
CREATE DATABASE devopsdb;

\c devopsdb;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO users (name) VALUES ('Alice'), ('Bob'), ('Charlie');
