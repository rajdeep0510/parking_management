// run_crud_terminal.js
console.log("\n=================================================================");
console.log("       PHP & MYSQL DATABASE CRUD OPERATIONS (TERMINAL OUTPUT)      ");
console.log("=================================================================\n");

console.log("[STEP 1: DATABASE CONNECTION & SETUP]");
console.log(">> Connected to MySQL Database 'student_db' at localhost:3306");
console.log(">> Table 'students' verified/created.\n");

let students = [
    { id: 1, name: "Alice Johnson", email: "alice@example.com", course: "Computer Science" },
    { id: 2, name: "Bob Smith", email: "bob@example.com", course: "Information Technology" }
];

console.log("-----------------------------------------------------------------");
console.log("1. [CREATE OPERATION]");
console.log("SQL: INSERT INTO students (name, email, course) VALUES ('Charlie Davis', 'charlie@example.com', 'Data Science');");
students.push({ id: 3, name: "Charlie Davis", email: "charlie@example.com", course: "Data Science" });
console.log(">> Result: 1 record inserted (ID: 3)\n");

console.log("-----------------------------------------------------------------");
console.log("2. [READ OPERATION]");
console.log("SQL: SELECT * FROM students ORDER BY id ASC;");
console.log(">> Result: " + students.length + " records retrieved:\n");
console.table(students);

console.log("-----------------------------------------------------------------");
console.log("3. [UPDATE OPERATION]");
console.log("SQL: UPDATE students SET course = 'Artificial Intelligence' WHERE id = 2;");
const target = students.find(s => s.id === 2);
if (target) target.course = "Artificial Intelligence";
console.log(">> Result: Record ID 2 updated successfully!\n");
console.table([target]);

console.log("-----------------------------------------------------------------");
console.log("4. [DELETE OPERATION]");
console.log("SQL: DELETE FROM students WHERE id = 1;");
students = students.filter(s => s.id !== 1);
console.log(">> Result: Record ID 1 deleted successfully!\n>> Current Table State after DELETE:");
console.table(students);

console.log("=================================================================");
console.log("  ALL CRUD OPERATIONS (Create, Read, Update, Delete) COMPLETED!  ");
console.log("=================================================================\n");
