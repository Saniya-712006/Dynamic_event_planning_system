import os
from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# --- 1. App Setup ---
app = Flask(__name__)
# A 'secret_key' is required to use sessions
app.config['SECRET_KEY'] = 'your_super_secret_key_change_this_later'

# --- 2. Database Configuration ---
db_host = os.getenv('DB_HOST')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')
db_name = os.getenv('DB_NAME')

def get_db_connection():
    """Establishes a connection to the MySQL database."""
    try:
        conn = mysql.connector.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            database=db_name
        )
        return conn
    except mysql.connector.Error as err:
        print(f"❌ Database connection error: {err}")
        return None

# --- 3. App Routes ---

@app.route('/')
def index():
    """Home page: redirects to login or a dashboard."""
    if 'role' in session:
        if session['role'] == 'admin':
            return redirect(url_for('admin_dashboard'))
        elif session['role'] == 'user':
            return redirect(url_for('user_dashboard'))
    
    # If no session, go to login
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    """Handles the login form."""
    error = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        # --- This is our simplified login logic ---
        
        # 1. Check if it's the Admin
        # (In a real app, admin password would be hashed in the DB)
        if username == 'admin' and password == 'admin':
            session['role'] = 'admin'
            session['username'] = 'Admin'
            return redirect(url_for('admin_dashboard'))

        # 2. If not admin, check if it's a Student
        # (For now, we'll just check if the SID exists and ignore password)
        conn = get_db_connection()
        if not conn:
            error = 'Database connection failed. Please try again later.'
            return render_template('login.html', error=error)
        
        cursor = conn.cursor(dictionary=True) # dictionary=True is very useful!
        cursor.execute("SELECT sid, fname FROM students WHERE sid = %s", (username,))
        student = cursor.fetchone()
        
        cursor.close()
        conn.close()

        if student:
            # Login successful
            session['role'] = 'user'
            session['sid'] = student['sid']
            session['username'] = student['fname'] # Greet them by first name
            return redirect(url_for('user_dashboard'))
        
        # 3. If no user found, show an error
        error = 'Invalid credentials. Please try again.'

    return render_template('login.html', error=error)

@app.route('/logout')
def logout():
    """Clears the session and logs the user out."""
    session.clear()
    return redirect(url_for('login'))

# --- 4. Protected Routes ---
# These routes check if the user is logged in

@app.route('/admin')
def admin_dashboard():
    # Check if user is an admin
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    return render_template('admin_dashboard.html')

@app.route('/user')
def user_dashboard():
    # Check if user is a student
    if 'role' not in session or session['role'] != 'user':
        return redirect(url_for('login'))
    
    return render_template('user_dashboard.html')

# --- 5. Run the App ---
if __name__ == '__main__':
    app.run(debug=True)