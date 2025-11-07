# Dynamic Event Planning & Analytics System

A full-stack web application built with **Flask** and **MySQL** that not only manages university events but also learns from user behavior to optimize resource allocation and analyze attendee preferences.

This project features a complete, secure Admin C.R.U.D. (Create, Read, Update, Delete) dashboard, a separate student sign-up and registration portal, and a backend analytics engine that runs in a background thread.

## Core Features

This project is divided into three main components: a powerful admin dashboard, a secure student portal, and a backend analytics engine.

###  Admin Dashboard
* **Full C.R.U.D. Functionality:** Create, Read, Update, and Delete capabilities for **all** database tables (`event`, `student`, `club`, `resource`, etc.).
* **Dynamic 2-Panel Layout:** A responsive, draggable, and resizable divider (using vanilla JavaScript) allows the admin to comfortably manage data.
* **Contextual Actions Panel:** The right-hand "Admin Actions" panel is smart. It contextually shows the correct "Create" or "Update" form based on the table being viewed in the left panel.
* **Master-Detail Management:** Seamlessly manage complex relationships. For example, when updating an event, the admin can **allocate resources (with quantity)** and **assign sponsors** directly from the event's "Update" page.
* **Secure & Abstracted:** All database operations are handled by the Flask backend. The admin *never* writes SQL.
* **Dynamic Table Viewer:** The admin can select any table or "sensible" `VIEW` from a dropdown to display its contents.

###  Student (User) Dashboard
* **Secure Authentication:** A full user sign-up and login system.
    * **Sign-up:** A "progressive" two-stage sign-up flow (credentials first, then profile details).
    * **Login:** Passwords are fully **hashed** and **salted** using `werkzeug.security`.
* **Profile Management:** Students can create and update their own profiles (name, semester, etc.).
* **Full Event Lifecycle:**
    * View all upcoming events (with dates, times, and organizing clubs).
    * **Register** for an event (runs an `INSERT INTO attends...`).
    * **Cancel** a registration (runs a `DELETE FROM attends...`).
    * **Submit Feedback** (with a 5-star rating and comment) for events they have attended (admin-verified).
* **Data Integrity:** Students *cannot* mark their own attendance. This must be done by an admin, ensuring the integrity of the analytics data.

###  Analytics & Machine Learning (The "Unique Twist")
This is the core "intelligence" of the project, run from a dedicated "Analytics" page on the admin dashboard.

* **Asynchronous Reporting:** To prevent the UI from freezing, heavy analytics reports are run in a separate **Python `threading` background thread**. The admin can continue using the app while the report generates.
* **Preference Learning (ML):** The report runs a query that compares a student's **"Stated Preference"** (from the `student_preferences` table) with their **"Revealed Preference"** (the event type they *actually* attend the most, calculated from `v_attends_detailed`).
* **Resource Optimization:** The report analyzes the `variance` (`pred_quantity - used_quantity`) for all items in the `resource` table. This helps admins "learn" from past events to stop over- or under-ordering.
* **Data Export:** All generated reports can be downloaded as a `.csv` file for use in other tools like Excel.

---

##  Tech Stack

* **Backend:** **Flask** (a Python web framework)
* **Database:** **MySQL**
* **Frontend:** HTML5, CSS3, and vanilla JavaScript
* **Key Python Libraries:**
    * `mysql-connector-python` (for database communication)
    * `werkzeug.security` (for password hashing)
    * `python-dotenv` (for secure credential management)
    * `threading` (for asynchronous tasks)
    * `csv` & `io` (for CSV exports)

---

##  Database Structure

The complete database schema, including all tables, advanced **SQL `VIEW`s**, **Triggers** (for automatically updating resource counts), and **Stored Procedures** (for abstracting complex queries) is defined in the `db/project_schema_v2.sql` file.

[View the Database Schema File](/db/project_schema_v2.sql)

---

##  Getting Started

To run this project locally, you will need Python 3 and a local MySQL server.

**1. Clone the Repository**

git clone [https://github.com/Saniya-712006/Dynamic_event_planning_system.git](https://github.com/Saniya-712006/Dynamic_event_planning_system.git)
cd Dynamic_event_planning_system


**2. Set Up a Virtual Environment (Recommended)**
# Windows
python -m venv venv
.\venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate

**3. Install Dependencies**
pip install -r requirements.txt

**4. Set Up the Database**
Ensure your MySQL server is running.
* Log in to MySQL as your root user:

    mysql -u root -p

* Create a new, secure user for the Flask app (this is our "Front Desk Clerk").
    CREATE USER 'flask_app_user'@'localhost' IDENTIFIED BY 'a_strong_password_123!';

* Create the database:
    CREATE DATABASE dynamic_event_planning;

* Grant privileges to your new user only on this database:
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON dynamic_event_planning.* TO 'flask_app_user'@'localhost';
    FLUSH PRIVILEGES;
    quit;

* Import the schema: Run this command from your terminal (not the mysql> prompt). It will load all tables, views,  and data.

    mysql -u flask_app_user -p dynamic_event_planning < db/project_schema_v2.sql

**5. Create the Environment File (.env)**
* Copy and paste the following, replacing the values with your new user's credentials.

    DB_HOST=localhost
    DB_USER=flask_app_user
    DB_PASSWORD=a_strong_password_123!
    DB_NAME=dynamic_event_planning

**6. Set Up Dummy Passwords for Existing Users**

* a. Add the password column
    USE dynamic_event_planning;
    ALTER TABLE students ADD password VARCHAR(255);

* b. Generate the Password Hash
    python -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('123'))"

* c. Update the Database:

    UPDATE students SET password = 'PASTE_YOUR_NEW_HASH_HERE' WHERE password IS NULL;

* d. Secure the Column
    ALTER TABLE students MODIFY password VARCHAR(255) NOT NULL;
    quit;

**7. Run the Application**
    python app.py

**8. How to Use**
* **Admin**
Username: admin

Password: admin

Navigate to the Admin Dashboard to manage all tables.

Click "Edit" on an event (from v_event_summary) to test the master-detail "Manage Resources" feature.

Navigate to Analytics to run and download reports.

* **Student**
Existing Student: Log in with an ID like S001 and the default password 123.

New Student: Click "Sign up here" and create a new account (e.g., S006, mypassword). You will be guided through the two-step profile creation.

Once logged in, you can register/cancel events and submit feedback.