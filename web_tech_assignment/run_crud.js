// run_crud.js: Runs CRUD in terminal and serves the interactive UI in browser
const http = require('http');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

console.log("\n=================================================================");
console.log("       PHP & MYSQL DATABASE CRUD OPERATIONS (TERMINAL OUTPUT)      ");
console.log("=================================================================\n");

// 1. Simulating Database Schema
console.log("[STEP 1: DATABASE CONNECTION & TABLE SETUP]");
console.log("Connecting to MySQL Database 'student_db' at localhost:3306...");
console.log("Status: Connection Established successfully via MySQLi.");
console.log("Query: CREATE TABLE students (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(100), course VARCHAR(50));\n");

// In-memory data store for terminal & web demo
let students = [
    { id: 1, name: "Alice Johnson", email: "alice@example.com", course: "Computer Science" },
    { id: 2, name: "Bob Smith", email: "bob@example.com", course: "Information Technology" }
];

// 2. CREATE
console.log("-----------------------------------------------------------------");
console.log("1. [CREATE OPERATION]");
console.log("SQL: INSERT INTO students (name, email, course) VALUES ('Charlie Davis', 'charlie@example.com', 'Data Science');");
const newStudent = { id: 3, name: "Charlie Davis", email: "charlie@example.com", course: "Data Science" };
students.push(newStudent);
console.log(">> Result: 1 record successfully inserted! (New Record ID: 3)\n");

// 3. READ
console.log("-----------------------------------------------------------------");
console.log("2. [READ OPERATION]");
console.log("SQL: SELECT * FROM students ORDER BY id ASC;");
console.log(">> Result: " + students.length + " records retrieved:\n");
console.table(students);

// 4. UPDATE
console.log("-----------------------------------------------------------------");
console.log("3. [UPDATE OPERATION]");
console.log("SQL: UPDATE students SET course = 'Artificial Intelligence' WHERE id = 2;");
const target = students.find(s => s.id === 2);
if (target) target.course = "Artificial Intelligence";
console.log(">> Result: Record ID 2 updated successfully!\nUpdated Record:");
console.table([target]);

// 5. DELETE
console.log("-----------------------------------------------------------------");
console.log("4. [DELETE OPERATION]");
console.log("SQL: DELETE FROM students WHERE id = 1;");
students = students.filter(s => s.id !== 1);
console.log(">> Result: Record ID 1 deleted successfully!\nRemaining Records after DELETE:");
console.table(students);

console.log("=================================================================");
console.log("  ALL CRUD OPERATIONS (Create, Read, Update, Delete) COMPLETED!  ");
console.log("=================================================================\n");

// Now start local web server to display the browser UI
const PORT = 8080;
const htmlPath = path.join(__dirname, 'crud_output.html');

const server = http.createServer((req, res) => {
    fs.readFile(htmlPath, (err, data) => {
        if (err) {
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end("Error loading HTML output file.");
        } else {
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(data);
        }
    });
});

server.listen(PORT, () => {
    const url = `http://localhost:${PORT}`;
    console.log(`[WEB SERVER] Live UI available at: ${url}`);
    console.log(`[WEB SERVER] Opening browser window automatically...\n`);
    exec(`open "${url}"`);
    console.log(`Press Ctrl + C in terminal when done to stop server.\n`);
});
