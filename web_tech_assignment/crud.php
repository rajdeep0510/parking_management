<?php
require_once 'db.php';

$message = "";
$update_mode = false;
$id = 0;
$name = "";
$email = "";
$course = "";

// 1. CREATE: Insert a new student record
if (isset($_POST['create'])) {
    $name = trim($_POST['name']);
    $email = trim($_POST['email']);
    $course = trim($_POST['course']);

    if (!empty($name) && !empty($email) && !empty($course)) {
        $stmt = $conn->prepare("INSERT INTO students (name, email, course) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $name, $email, $course);

        if ($stmt->execute()) {
            $message = "<div class='alert success'>Student record added successfully!</div>";
        } else {
            $message = "<div class='alert error'>Error: " . $stmt->error . "</div>";
        }
        $stmt->close();
        $name = "";
        $email = "";
        $course = "";
    } else {
        $message = "<div class='alert error'>All fields are required!</div>";
    }
}

// 2. DELETE: Remove a student record by ID
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);

    $stmt = $conn->prepare("DELETE FROM students WHERE id = ?");
    $stmt->bind_param("i", $id);

    if ($stmt->execute()) {
        header("Location: crud.php?msg=deleted");
        exit();
    } else {
        $message = "<div class='alert error'>Error deleting record: " . $stmt->error . "</div>";
    }
    $stmt->close();
}

if (isset($_GET['msg']) && $_GET['msg'] === 'deleted') {
    $message = "<div class='alert success'>Student record deleted successfully!</div>";
}

// 3. EDIT (FETCH): Load data for update into form
if (isset($_GET['edit'])) {
    $id = intval($_GET['edit']);
    $update_mode = true;

    $stmt = $conn->prepare("SELECT * FROM students WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows == 1) {
        $row = $result->fetch_assoc();
        $name = $row['name'];
        $email = $row['email'];
        $course = $row['course'];
    }
    $stmt->close();
}

// 4. UPDATE: Save modified student details
if (isset($_POST['update'])) {
    $id = intval($_POST['id']);
    $name = trim($_POST['name']);
    $email = trim($_POST['email']);
    $course = trim($_POST['course']);

    $stmt = $conn->prepare("UPDATE students SET name = ?, email = ?, course = ? WHERE id = ?");
    $stmt->bind_param("sssi", $name, $email, $course, $id);

    if ($stmt->execute()) {
        header("Location: crud.php?msg=updated");
        exit();
    } else {
        $message = "<div class='alert error'>Error updating record: " . $stmt->error . "</div>";
    }
    $stmt->close();
}

if (isset($_GET['msg']) && $_GET['msg'] === 'updated') {
    $message = "<div class='alert success'>Student record updated successfully!</div>";
}

// 5. READ: Retrieve all student records
$sql = "SELECT * FROM students ORDER BY id ASC";
$result = $conn->query($sql);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PHP & MySQL CRUD Operations</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f7f9fc;
            margin: 0;
            padding: 25px;
        }
        .container {
            max-width: 920px;
            margin: auto;
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border: 1px solid #e2e8f0;
        }
        h2 {
            color: #1e293b;
            text-align: center;
            margin-top: 0;
            margin-bottom: 20px;
        }
        h3 {
            color: #334155;
            margin-top: 30px;
        }
        .alert {
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 500;
        }
        .success {
            background-color: #dcfce7;
            color: #15803d;
            border: 1px solid #bbf7d0;
        }
        .error {
            background-color: #fee2e2;
            color: #b91c1c;
            border: 1px solid #fecaca;
        }
        form {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            justify-content: center;
            margin-bottom: 25px;
            padding: 20px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
        }
        form input[type="text"], form input[type="email"] {
            padding: 10px 14px;
            width: 230px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 14px;
        }
        .btn {
            padding: 10px 18px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-create {
            background-color: #2563eb;
            color: white;
        }
        .btn-create:hover { background-color: #1d4ed8; }
        .btn-update {
            background-color: #16a34a;
            color: white;
        }
        .btn-cancel {
            background-color: #64748b;
            color: white;
        }
        .btn-edit {
            background-color: #f59e0b;
            color: white;
            padding: 6px 12px;
            font-size: 13px;
        }
        .btn-delete {
            background-color: #ef4444;
            color: white;
            padding: 6px 12px;
            font-size: 13px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        table th, table td {
            border: 1px solid #e2e8f0;
            padding: 12px 14px;
            text-align: left;
            font-size: 14px;
        }
        table th {
            background-color: #f1f5f9;
            color: #1e293b;
            font-weight: 600;
        }
        table tr:nth-child(even) {
            background-color: #f8fafc;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Student Management System (PHP & MySQL CRUD)</h2>

    <?php echo $message; ?>

    <!-- Form for Create and Update -->
    <form action="crud.php" method="POST">
        <input type="hidden" name="id" value="<?php echo $id; ?>">

        <input type="text" name="name" placeholder="Full Name" value="<?php echo htmlspecialchars($name); ?>" required>
        <input type="email" name="email" placeholder="Email Address" value="<?php echo htmlspecialchars($email); ?>" required>
        <input type="text" name="course" placeholder="Course / Department" value="<?php echo htmlspecialchars($course); ?>" required>

        <?php if ($update_mode): ?>
            <button type="submit" name="update" class="btn btn-update">Update Student</button>
            <a href="crud.php" class="btn btn-cancel">Cancel</a>
        <?php else: ?>
            <button type="submit" name="create" class="btn btn-create">Add Student</button>
        <?php endif; ?>
    </form>

    <!-- Table to Display Records (READ) -->
    <h3>Registered Students List</h3>
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Course</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <?php if ($result && $result->num_rows > 0): ?>
                <?php while ($row = $result->fetch_assoc()): ?>
                    <tr>
                        <td><?php echo $row['id']; ?></td>
                        <td><?php echo htmlspecialchars($row['name']); ?></td>
                        <td><?php echo htmlspecialchars($row['email']); ?></td>
                        <td><?php echo htmlspecialchars($row['course']); ?></td>
                        <td><?php echo $row['created_at']; ?></td>
                        <td>
                            <a href="crud.php?edit=<?php echo $row['id']; ?>" class="btn btn-edit">Edit</a>
                            <a href="crud.php?delete=<?php echo $row['id']; ?>" class="btn btn-delete" onclick="return confirm('Are you sure you want to delete this record?');">Delete</a>
                        </td>
                    </tr>
                <?php endwhile; ?>
            <?php else: ?>
                <tr>
                    <td colspan="6" style="text-align: center; color: #64748b;">No student records found. Add one above!</td>
                </tr>
            <?php endif; ?>
        </tbody>
    </table>
</div>

</body>
</html>
<?php
$conn->close();
?>
