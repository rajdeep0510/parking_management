<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World in PHP</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            margin-top: 80px;
            background-color: #f4f6f9;
        }
        .container {
            background-color: #ffffff;
            display: inline-block;
            padding: 40px 60px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
            border: 1px solid #e2e8f0;
        }
        h1 {
            color: #1e293b;
            font-size: 36px;
            margin-bottom: 15px;
        }
        p {
            color: #64748b;
            font-size: 16px;
            margin: 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>
            <?php
                // Display Hello, World! on the webpage
                echo "Hello, World!";
            ?>
        </h1>
        <p>Current Server Time: <?php echo date("Y-m-d H:i:s"); ?></p>
    </div>
</body>
</html>
