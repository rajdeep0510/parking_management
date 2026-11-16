-- Database schema for Question 15
CREATE DATABASE IF NOT EXISTS student_db;
USE student_db;

CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    course VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample records
INSERT INTO students (name, email, course) VALUES 
('Alice Johnson', 'alice@example.com', 'Computer Science'),
('Bob Smith', 'bob@example.com', 'Information Technology'),
('Charlie Davis', 'charlie@example.com', 'Data Science');
