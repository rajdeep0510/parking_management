<?php
// db.php: Database Connection File
$host     = "localhost";
$username = "root";       // Default MySQL user in XAMPP/WAMP
$password = "";           // Default password is blank in XAMPP
$database = "student_db";

// Create connection using MySQLi
$conn = new mysqli($host, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
