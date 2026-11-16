#!/usr/bin/env python3
"""
Web Technology Assignment: Question 15
Connect to Database and perform CRUD operations (Create, Read, Update, Delete)
Executable in terminal: python3 run_crud.py
"""

import sqlite3
import os
import webbrowser
import time

def main():
    print("\n" + "=" * 65)
    print("      DATABASE CRUD OPERATIONS EXECUTION (TERMINAL OUTPUT)      ")
    print("=" * 65 + "\n")

    # Connect to in-memory database
    print("[STEP 1: DATABASE CONNECTION]")
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()
    print(">> Connected to database successfully.")

    # Create table
    print("\n[STEP 2: CREATE TABLE]")
    cursor.execute("""
    CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        course TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)
    conn.commit()
    print(">> Table 'students' created successfully.")

    # 1. CREATE (INSERT)
    print("\n" + "-" * 65)
    print("1. [CREATE OPERATION - Inserting records]")
    sample_records = [
        ("Alice Johnson", "alice@example.com", "Computer Science"),
        ("Bob Smith", "bob@example.com", "Information Technology"),
        ("Charlie Davis", "charlie@example.com", "Data Science")
    ]
    cursor.executemany("INSERT INTO students (name, email, course) VALUES (?, ?, ?);", sample_records)
    conn.commit()
    print(f">> SQL: INSERT INTO students (name, email, course) VALUES (?, ?, ?)")
    print(f">> Inserted {len(sample_records)} student records successfully!")

    # 2. READ (SELECT)
    print("\n" + "-" * 65)
    print("2. [READ OPERATION - Fetching records]")
    cursor.execute("SELECT id, name, email, course FROM students;")
    rows = cursor.fetchall()
    print(">> SQL: SELECT * FROM students;")
    print(f"{'ID':<5} | {'Name':<18} | {'Email':<25} | {'Course':<22}")
    print("-" * 75)
    for row in rows:
        print(f"{row[0]:<5} | {row[1]:<18} | {row[2]:<25} | {row[3]:<22}")

    # 3. UPDATE
    print("\n" + "-" * 65)
    print("3. [UPDATE OPERATION - Modifying a record]")
    update_id = 2
    new_course = "Artificial Intelligence"
    cursor.execute("UPDATE students SET course = ? WHERE id = ?;", (new_course, update_id))
    conn.commit()
    print(f">> SQL: UPDATE students SET course = '{new_course}' WHERE id = {update_id};")
    cursor.execute("SELECT id, name, email, course FROM students WHERE id = ?;", (update_id,))
    updated_row = cursor.fetchone()
    print(f">> Updated record: ID: {updated_row[0]}, Name: {updated_row[1]}, New Course: {updated_row[3]}")

    # 4. DELETE
    print("\n" + "-" * 65)
    print("4. [DELETE OPERATION - Deleting a record]")
    delete_id = 1
    cursor.execute("DELETE FROM students WHERE id = ?;", (delete_id,))
    conn.commit()
    print(f">> SQL: DELETE FROM students WHERE id = {delete_id};")
    cursor.execute("SELECT id, name, email, course FROM students;")
    remaining = cursor.fetchall()
    print(f">> Remaining records after deleting ID {delete_id}:")
    print(f"{'ID':<5} | {'Name':<18} | {'Email':<25} | {'Course':<22}")
    print("-" * 75)
    for row in remaining:
        print(f"{row[0]:<5} | {row[1]:<18} | {row[2]:<25} | {row[3]:<22}")

    print("\n" + "=" * 65)
    print("  ALL CRUD OPERATIONS (Create, Read, Update, Delete) COMPLETED!  ")
    print("=" * 65 + "\n")

    conn.close()

    # Also automatically open the browser UI preview
    html_file = os.path.abspath("crud_output.html")
    if os.path.exists(html_file):
        print(f"[BROWSER] Opening interactive webpage: {html_file}")
        os.system(f'open "{html_file}"')

if __name__ == "__main__":
    main()
