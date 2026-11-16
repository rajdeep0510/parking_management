<?php
// PHP Terminal CRUD Execution Script
echo "\n=================================================================\n";
echo "       PHP & DATABASE CRUD OPERATIONS (TERMINAL OUTPUT)          \n";
echo "=================================================================\n\n";

$db = new SQLite3(':memory:');

// 1. CREATE TABLE
$db->exec("CREATE TABLE students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT, course TEXT)");
echo "[STEP 1] Connected to Database and created table 'students'.\n\n";

// 2. CREATE (INSERT)
echo "1. [CREATE OPERATION]\n";
$db->exec("INSERT INTO students (name, email, course) VALUES ('Alice Johnson', 'alice@example.com', 'Computer Science')");
$db->exec("INSERT INTO students (name, email, course) VALUES ('Bob Smith', 'bob@example.com', 'Information Technology')");
$db->exec("INSERT INTO students (name, email, course) VALUES ('Charlie Davis', 'charlie@example.com', 'Data Science')");
echo ">> 3 records inserted successfully!\n\n";

// 3. READ (SELECT)
echo "2. [READ OPERATION]\n";
echo sprintf("%-5s | %-18s | %-25s | %-20s\n", "ID", "Name", "Email", "Course");
echo str_repeat("-", 75) . "\n";
$res = $db->query("SELECT * FROM students");
while ($row = $res->fetchArray(SQLITE3_ASSOC)) {
    echo sprintf("%-5s | %-18s | %-25s | %-20s\n", $row['id'], $row['name'], $row['email'], $row['course']);
}
echo "\n";

// 4. UPDATE
echo "3. [UPDATE OPERATION]\n";
$db->exec("UPDATE students SET course = 'Artificial Intelligence' WHERE id = 2");
echo ">> Record ID 2 course updated to 'Artificial Intelligence'!\n\n";

// 5. DELETE
echo "4. [DELETE OPERATION]\n";
$db->exec("DELETE FROM students WHERE id = 1");
echo ">> Record ID 1 deleted successfully!\n\n";

echo ">> Final Table State after DELETE:\n";
echo sprintf("%-5s | %-18s | %-25s | %-20s\n", "ID", "Name", "Email", "Course");
echo str_repeat("-", 75) . "\n";
$res2 = $db->query("SELECT * FROM students");
while ($row = $res2->fetchArray(SQLITE3_ASSOC)) {
    echo sprintf("%-5s | %-18s | %-25s | %-20s\n", $row['id'], $row['name'], $row['email'], $row['course']);
}

echo "\n=================================================================\n";
echo "  ALL CRUD OPERATIONS (Create, Read, Update, Delete) COMPLETED!  \n";
echo "=================================================================\n";
?>
