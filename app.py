import os
from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from dotenv import load_dotenv
from werkzeug.security import generate_password_hash, check_password_hash

# Load environment variables
load_dotenv()

# --- 1. App Setup ---
app = Flask(__name__)
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
    if 'role' in session:
        if session['role'] == 'admin':
            return redirect(url_for('admin_dashboard'))
        elif session['role'] == 'user':
            return redirect(url_for('user_dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        if username == 'admin' and password == 'admin':
            session['role'] = 'admin'
            session['username'] = 'Admin'
            return redirect(url_for('admin_dashboard'))

        conn = get_db_connection()
        if not conn:
            error = 'Database connection failed. Please try again later.'
            return render_template('login.html', error=error)
        
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT sid, fname, password FROM students WHERE sid = %s", (username,))
        student = cursor.fetchone()
        cursor.close()
        conn.close()

        if student and check_password_hash(student['password'], password):
            # Login successful! Password matches.
            session['role'] = 'user'
            session['sid'] = student['sid']
            session['username'] = student['fname'] # Greet them by first name
            return redirect(url_for('user_dashboard'))
        
        # 3. If no user found or password mismatch, show an error
        error = 'Invalid credentials. Please try again.'
    return render_template('login.html', error=error)

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        # 1. Get the minimal data from the form
        sid = request.form['sid']
        password = request.form['password']

        # 2. Store them in the session
        session['temp_sid'] = sid
        session['temp_password'] = password
        
        # 3. Redirect to the new 'fill_profile' page
        return redirect(url_for('fill_profile'))

    # If GET request, just show the signup page
    return render_template('signup.html')

@app.route('/fill_profile', methods=['GET', 'POST'])
def fill_profile():
    # Check if the user has temp data. If not, send them back to signup.
    if 'temp_sid' not in session or 'temp_password' not in session:
        return redirect(url_for('signup'))
    
    error = None
    if request.method == 'POST':
        try:
            # 1. Get the new details from the form
            fname = request.form['fname']
            lname = request.form['lname']
            department = request.form['department']
            sem = request.form['sem']
            
            # 2. Get the old details from the session
            sid = session['temp_sid']
            password = session['temp_password']
            
            # 3. Hash the password
            password_hash = generate_password_hash(password)

            conn = get_db_connection()
            cursor = conn.cursor()
            
            # 4. Insert the COMPLETE student record
            cursor.execute(
                "INSERT INTO students (sid, fname, lname, department, sem, password) VALUES (%s, %s, %s, %s, %s, %s)",
                (sid, fname, lname, department, sem, password_hash)
            )
            conn.commit()
            
            # 5. Clear the temp session data
            session.pop('temp_sid', None)
            session.pop('temp_password', None)
            
            # 6. Log the user in properly
            session['role'] = 'user'
            session['sid'] = sid
            session['username'] = fname
            
            flash(f"Welcome, {fname}! Your account is all set up.", 'success')
            return redirect(url_for('user_dashboard')) # Send them to the user dashboard

        except mysql.connector.Error as err:
            error = f"Error creating account: {err}"
        finally:
            if conn and conn.is_connected():
                cursor.close()
                conn.close()

    # If GET request or error, show the profile completion page
    return render_template('fill_profile.html', error=error) 

@app.route('/my_profile', methods=['GET', 'POST'])
def my_profile():
    # 1. Check if user is logged in
    if 'role' not in session or session['role'] != 'user':
        return redirect(url_for('login'))
    
    sid = session['sid']
    error = None
    
    if request.method == 'POST':
        # --- This is the UPDATE (POST) logic ---
        try:
            fname = request.form['fname']
            lname = request.form['lname']
            department = request.form['department']
            sem = request.form['sem']
            
            conn = get_db_connection()
            cursor = conn.cursor()
            
            cursor.execute(
                "UPDATE students SET fname = %s, lname = %s, department = %s, sem = %s WHERE sid = %s",
                (fname, lname, department, sem, sid)
            )
            conn.commit()
            flash("Profile updated successfully!", 'success')
            
        except mysql.connector.Error as err:
            flash(f"Error updating profile: {err}", 'error')
        finally:
            if conn and conn.is_connected():
                cursor.close()
                conn.close()
        
        # After updating, just redirect back to the same page
        return redirect(url_for('my_profile'))

    # --- This is the page load (GET) logic ---
    conn = get_db_connection()
    if not conn:
        return "<h1>Database connection failed.</h1>"
        
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT sid, fname, lname, department, sem FROM students WHERE sid = %s", (sid,))
    student_data = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    if not student_data:
        # This should never happen if they're logged in, but it's a good safeguard
        flash("Error: Could not find your student data.", 'error')
        return redirect(url_for('logout'))

    return render_template('my_profile.html', student=student_data)


@app.route('/register_event/<string:eid>', methods=['POST'])
def register_event(eid):
    # Check if user is a student
    if 'role' not in session or session['role'] != 'user':
        return redirect(url_for('login'))
        
    sid = session['sid']
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Insert the student's registration, default status is 'P'
        cursor.execute(
            "INSERT INTO attends (sid, eid, status) VALUES (%s, %s, 'P')",
            (sid, eid)
        )
        conn.commit()
        flash(f"Successfully registered for the event!", 'success')
        
    except mysql.connector.Error as err:
        # This will catch your database trigger if they're already registered
        flash(f"Error registering: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    # Refresh the user dashboard
    return redirect(url_for('user_dashboard'))

@app.route('/cancel_registration/<string:eid>', methods=['POST'])
def cancel_registration(eid):
    # Check if user is a student
    if 'role' not in session or session['role'] != 'user':
        return redirect(url_for('login'))
        
    sid = session['sid']
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Delete the registration
        cursor.execute(
            "DELETE FROM attends WHERE sid = %s AND eid = %s",
            (sid, eid)
        )
        conn.commit()
        flash(f"Registration successfully cancelled.", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error cancelling registration: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('user_dashboard'))

@app.route('/feedback/<string:eid>', methods=['GET', 'POST'])
def submit_feedback(eid):
    # Check if user is a student
    if 'role' not in session or session['role'] != 'user':
        return redirect(url_for('login'))
        
    sid = session['sid']
    
    if request.method == 'POST':
        # --- Handle the form submission ---
        try:
            # We need to generate a new unique Feedback ID (fbid)
            # A simple way is to count existing ones and add 1
            conn = get_db_connection()
            cursor = conn.cursor(dictionary=True)
            cursor.execute("SELECT COUNT(*) as count FROM feedback")
            count = cursor.fetchone()['count']
            fbid = f"FB{count + 1:02d}" # Formats to FB05, FB06, etc.
            
            rating = request.form['rating']
            comment = request.form['comment']
            
            cursor.execute(
                "INSERT INTO feedback (fbid, rating, event_id, comment) VALUES (%s, %s, %s, %s)",
                (fbid, rating, eid, comment)
            )
            conn.commit()
            flash("Thank you for your feedback!", 'success')
            return redirect(url_for('user_dashboard'))
            
        except mysql.connector.Error as err:
            flash(f"Error submitting feedback: {err}", 'error')
        finally:
            if conn and conn.is_connected():
                cursor.close()
                conn.close()
        
        return redirect(url_for('submit_feedback', eid=eid))

    # --- Show the feedback form (GET request) ---
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT ename FROM event WHERE eid = %s", (eid,))
    event = cursor.fetchone()
    cursor.close()
    conn.close()

    if not event:
        flash("Event not found.", 'error')
        return redirect(url_for('user_dashboard'))

    return render_template('feedback_form.html', event=event, eid=eid)

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

# --- 4. Protected Routes ---

ALLOWED_ADMIN_VIEWS = [
    'v_event_summary',
    'event',
    'v_attends_detailed',
    'v_feedback_detailed',
    'v_club_membership',
    'students',
    'club',
    'venue',
    'resource',
    'sponsor',
    'faculty',
    'attends', # Base table
    'feedback', # Base table
    'is_part_of', # Base table
    'allocated'
]

@app.route('/admin')
def admin_dashboard():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    conn = get_db_connection()
    if not conn:
        return "<h1>Database connection failed.</h1>"
    
    cursor = conn.cursor(dictionary=True)
    
    # --- 1. Get ALL Helper Data for ALL Forms ---
    cursor.execute("SELECT cid, cname FROM club ORDER BY cname")
    clubs = cursor.fetchall()
    cursor.execute("SELECT vid, vname FROM venue ORDER BY vname")
    venues = cursor.fetchall()
    cursor.execute("SELECT sid, fname, lname FROM students ORDER BY fname")
    all_students = cursor.fetchall() # Renamed
    cursor.execute("SELECT eid, ename FROM event ORDER BY actual_date DESC")
    all_events = cursor.fetchall() # Renamed
    cursor.execute("SELECT rid, type FROM resource ORDER BY type")
    resources = cursor.fetchall()
    
    event_types = ['Technical', 'Literary', 'Cultural']
    departments = ['CSE', 'ECE', 'MECH', 'CIVIL', 'GENERAL']
    
    # --- 2. Data Fetching Logic (Left Panel) ---
    requested_view = request.args.get('view')
    if not requested_view or requested_view not in ALLOWED_ADMIN_VIEWS:
        requested_view = 'v_event_summary'

    table_headers = []
    table_data = []
    try:
        query = f"SELECT * FROM {requested_view}"
        if requested_view == 'v_event_summary':
            query += " ORDER BY actual_date DESC"
        cursor.execute(query)
        table_data = cursor.fetchall()
        if table_data:
            table_headers = [col[0] for col in cursor.description]
    except mysql.connector.Error as err:
        flash(f"Error viewing table: {err}", 'error')

    # --- 3. "Edit Mode" Logic (Right Panel) ---
    item_to_edit = None
    item_club_cid = None # Special case for event form
    allocated_resources = []
    
    # Get all possible edit keys from URL
    edit_id = request.args.get('edit')
    edit_sid = request.args.get('edit_sid')
    edit_eid = request.args.get('edit_eid')
    edit_cid = request.args.get('edit_cid')

    try:
        if edit_id:
            if requested_view == 'v_event_summary' or requested_view == 'event':
                cursor.execute("SELECT * FROM event WHERE eid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
                # Get the linked club for the dropdown
                cursor.execute("SELECT cid FROM organizes WHERE eid = %s", (edit_id,))
                club_link = cursor.fetchone()
                if club_link:
                    item_club_cid = club_link['cid']
                cursor.execute(
                    """
                    SELECT a.rid, r.type, a.allocated_quantity
                    FROM allocated a
                    JOIN resource r ON a.rid = r.rid
                    WHERE a.eid = %s
                    """, (edit_id,)
                )
                allocated_resources = cursor.fetchall()
            
            elif requested_view == 'students':
                cursor.execute("SELECT * FROM students WHERE sid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
            
            elif requested_view == 'club':
                cursor.execute("SELECT * FROM club WHERE cid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
            
            elif requested_view == 'venue':
                cursor.execute("SELECT * FROM venue WHERE vid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
                
            elif requested_view == 'resource':
                cursor.execute("SELECT * FROM resource WHERE rid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
                
            elif requested_view == 'sponsor':
                cursor.execute("SELECT * FROM sponsor WHERE spid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
                
            elif requested_view == 'faculty':
                cursor.execute("SELECT * FROM faculty WHERE fid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
                
            elif requested_view == 'v_feedback_detailed' or requested_view == 'feedback':
                cursor.execute("SELECT * FROM feedback WHERE fbid = %s", (edit_id,))
                item_to_edit = cursor.fetchone()
        
        # Handle composite key for 'attends'
        elif edit_sid and edit_eid:
            cursor.execute("SELECT * FROM attends WHERE sid = %s AND eid = %s", (edit_sid, edit_eid))
            item_to_edit = cursor.fetchone()

        # Handle composite key for 'is_part_of'
        elif edit_sid and edit_cid:
            cursor.execute("SELECT * FROM is_part_of WHERE sid = %s AND cid = %s", (edit_sid, edit_cid))
            item_to_edit = cursor.fetchone()

    except mysql.connector.Error as err:
        flash(f"Error fetching item for edit: {err}", 'error')
            
    cursor.close()
    conn.close()
    
    # --- 4. Pass ALL data to the template ---
    return render_template(
        'admin_dashboard.html', 
        allowed_views=ALLOWED_ADMIN_VIEWS,
        current_view=requested_view,
        table_headers=table_headers,
        table_data=table_data,
        clubs=clubs,
        venues=venues,
        event_types=event_types,
        departments=departments,
        students=all_students, # Use the renamed variable
        events=all_events,
        resources=resources,
        allocated_resources=allocated_resources,        
        item_to_edit=item_to_edit,
        item_club_cid=item_club_cid
    )

# --- 5. ALL "CREATE" ROUTES ---

@app.route('/admin/create_event', methods=['POST'])
def create_event():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        eid = request.form['eid']
        ename = request.form['ename']
        etype = request.form['etype']
        dept = request.form['dept']
        actual_date = request.form['actual_date']
        actual_time = request.form['actual_time']
        cid = request.form['cid'] 
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.callproc('AddEvent', (
            eid, ename, etype, 
            actual_date, actual_date, 
            actual_time, actual_time, 
            dept
        ))
        
        cursor.execute("INSERT INTO organizes (cid, eid) VALUES (%s, %s)", (cid, eid))
        conn.commit()
        flash(f"Event '{ename}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating event: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

    return redirect(url_for('admin_dashboard', view='event'))

@app.route('/admin/create_student', methods=['POST'])
def create_student():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        sid = request.form['sid']
        fname = request.form['fname']
        lname = request.form['lname']
        department = request.form['department']
        sem = request.form['sem']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO students (sid, fname, lname, department, sem) VALUES (%s, %s, %s, %s, %s)",
            (sid, fname, lname, department, sem)
        )
        conn.commit()
        flash(f"Student '{fname}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating student: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='students'))

@app.route('/admin/create_club', methods=['POST'])
def create_club():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        cid = request.form['cid']
        cname = request.form['cname']
        description = request.form['description']
        domain_name = request.form['domain_name']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # FIXED: Removed domain_id from the query
        cursor.execute(
            "INSERT INTO club (cid, cname, description, domain_name) VALUES (%s, %s, %s, %s)",
            (cid, cname, description, domain_name)
        )
        conn.commit()
        flash(f"Club '{cname}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating club: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='club'))

@app.route('/admin/create_venue', methods=['POST'])
def create_venue():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        vid = request.form['vid']
        vname = request.form['vname']
        capacity = request.form['capacity']
        floor = request.form['floor']
        room = request.form['room']
        block = request.form['block']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO venue (vid, vname, capacity, floor, room, block) VALUES (%s, %s, %s, %s, %s, %s)",
            (vid, vname, capacity, floor, room, block)
        )
        conn.commit()
        flash(f"Venue '{vname}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating venue: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='venue'))

@app.route('/admin/create_resource', methods=['POST'])
def create_resource():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        rid = request.form['rid']
        type = request.form['type']
        pred_quantity = request.form['pred_quantity']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO resource (rid, type, pred_quantity, used_quantity) VALUES (%s, %s, %s, 0)",
            (rid, type, pred_quantity)
        )
        conn.commit()
        flash(f"Resource '{type}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating resource: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='resource'))

@app.route('/admin/create_sponsor', methods=['POST'])
def create_sponsor():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        spid = request.form['spid']
        sname = request.form['sname']
        contri_type = request.form['contri_type']
        contri_amt = request.form['contri_amt']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO sponsor (spid, sname, contri_type, contri_amt) VALUES (%s, %s, %s, %s)",
            (spid, sname, contri_type, contri_amt)
        )
        conn.commit()
        flash(f"Sponsor '{sname}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating sponsor: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='sponsor'))

@app.route('/admin/create_faculty', methods=['POST'])
def create_faculty():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        fid = request.form['fid']
        ffname = request.form['ffname']
        flname = request.form['flname']
        dept = request.form['dept']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO faculty (fid, ffname, flname, dept) VALUES (%s, %s, %s, %s)",
            (fid, ffname, flname, dept)
        )
        conn.commit()
        flash(f"Faculty member '{ffname}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating faculty: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='faculty'))

@app.route('/admin/create_attends', methods=['POST'])
def create_attends():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        sid = request.form['sid']
        eid = request.form['eid']
        status = request.form['status']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO attends (sid, eid, status) VALUES (%s, %s, %s)",
            (sid, eid, status)
        )
        conn.commit()
        flash(f"Registration for '{sid}' to '{eid}' created!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating registration: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='v_attends_detailed'))

@app.route('/admin/create_feedback', methods=['POST'])
def create_feedback():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        fbid = request.form['fbid']
        rating = request.form['rating']
        event_id = request.form['event_id']
        comment = request.form['comment']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO feedback (fbid, rating, event_id, comment) VALUES (%s, %s, %s, %s)",
            (fbid, rating, event_id, comment)
        )
        conn.commit()
        flash(f"Feedback '{fbid}' created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating feedback: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='v_feedback_detailed'))

@app.route('/admin/create_is_part_of', methods=['POST'])
def create_is_part_of():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        sid = request.form['sid']
        cid = request.form['cid']
        role = request.form['role']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO is_part_of (sid, cid, role) VALUES (%s, %s, %s)",
            (sid, cid, role)
        )
        conn.commit()
        flash(f"Club membership created successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error creating membership: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='v_club_membership'))

# --- USER DASHBOARD (Placeholder) ---
@app.route('/user')
def user_dashboard():
    # 1. Check if user is a student
    if 'role' not in session or session['role'] != 'user':
        return redirect(url_for('login'))
    
    # 2. Get the logged-in student's ID
    sid = session['sid']
    
    conn = get_db_connection()
    if not conn:
        return "<h1>Database connection failed.</h1>"
    
    cursor = conn.cursor(dictionary=True)
    
    # 3. Fetch all upcoming events
    # We also check if the student is already registered for them
    cursor.execute(
        """
        SELECT 
            v.*,
            (CASE WHEN a.sid IS NOT NULL THEN 1 ELSE 0 END) AS 'is_registered'
        FROM 
            v_event_summary v
        LEFT JOIN 
            attends a ON v.eid = a.eid AND a.sid = %s
        WHERE 
            v.actual_date >= CURDATE()
        ORDER BY 
            v.actual_date ASC;
        """, (sid,)
    )
    upcoming_events = cursor.fetchall()

    # 4. Fetch all of this student's registrations
    cursor.execute(
        "SELECT * FROM v_attends_detailed WHERE student_id = %s ORDER BY event_name", (sid,)
    )
    my_registrations = cursor.fetchall()
    
    cursor.close()
    conn.close()

    # 5. Send this data to the new user_dashboard.html
    return render_template(
        'user_dashboard.html', 
        upcoming_events=upcoming_events,
        my_registrations=my_registrations
    )
# --- 6. ALL "UPDATE" and "DELETE" ROUTES ---

# --- Event ---
@app.route('/admin/update_event/<string:eid>', methods=['POST'])
def update_event(eid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        # Get data from the form
        ename = request.form['ename']
        etype = request.form['etype']
        dept = request.form['dept']
        actual_date = request.form['actual_date']
        actual_time = request.form['actual_time']
        cid = request.form['cid'] 
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 1. Update the main 'event' table
        cursor.execute(
            """
            UPDATE event 
            SET ename = %s, etype = %s, actual_date = %s, actual_time = %s, dept = %s,
                opt_date = %s, opt_time = %s
            WHERE eid = %s
            """, 
            (ename, etype, actual_date, actual_time, dept, actual_date, actual_time, eid)
        )
        
        # 2. Update the 'organizes' table (delete old, insert new)
        cursor.execute("DELETE FROM organizes WHERE eid = %s", (eid,))
        cursor.execute("INSERT INTO organizes (cid, eid) VALUES (%s, %s)", (cid, eid))
        
        conn.commit()
        flash(f"Event '{ename}' updated successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error updating event: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    # Redirect back to the event summary view
    return redirect(url_for('admin_dashboard', view='v_event_summary'))

@app.route('/admin/delete_event/<string:eid>', methods=['POST'])
def delete_event(eid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Deleting from 'event' will cascade to 'organizes', 'attends', etc.
        # because of your 'ON DELETE CASCADE' rules.
        cursor.execute("DELETE FROM event WHERE eid = %s", (eid,))
        
        conn.commit()
        flash(f"Event {eid} deleted successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error deleting event: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='v_event_summary'))

# --- Student ---
@app.route('/admin/update_student/<string:sid>', methods=['POST'])
def update_student(sid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        fname = request.form['fname']
        lname = request.form['lname']
        department = request.form['department']
        sem = request.form['sem']
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE students SET fname = %s, lname = %s, department = %s, sem = %s WHERE sid = %s",
            (fname, lname, department, sem, sid)
        )
        conn.commit()
        flash(f"Student '{fname}' updated successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating student: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='students'))

@app.route('/admin/delete_student/<string:sid>', methods=['POST'])
def delete_student(sid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM students WHERE sid = %s", (sid,))
        conn.commit()
        flash(f"Student {sid} deleted successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting student: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='students'))

# --- Club ---
@app.route('/admin/update_club/<string:cid>', methods=['POST'])
def update_club(cid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        cname = request.form['cname']
        description = request.form['description']
        domain_name = request.form['domain_name']
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE club SET cname = %s, description = %s, domain_name = %s WHERE cid = %s",
            (cname, description, domain_name, cid)
        )
        conn.commit()
        flash(f"Club '{cname}' updated successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating club: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='club'))

@app.route('/admin/delete_club/<string:cid>', methods=['POST'])
def delete_club(cid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM club WHERE cid = %s", (cid,))
        conn.commit()
        flash(f"Club {cid} deleted successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting club: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='club'))

# --- Attends (Composite Key) ---
@app.route('/admin/update_attends/<string:sid>/<string:eid>', methods=['POST'])
def update_attends(sid, eid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        status = request.form['status']
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE attends SET status = %s WHERE sid = %s AND eid = %s",
            (status, sid, eid)
        )
        conn.commit()
        flash(f"Attendance for {sid} at {eid} updated!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating attendance: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='v_attends_detailed'))

@app.route('/admin/delete_attends/<string:sid>/<string:eid>', methods=['POST'])
def delete_attends(sid, eid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM attends WHERE sid = %s AND eid = %s", (sid, eid))
        conn.commit()
        flash(f"Registration for {sid} at {eid} deleted!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting registration: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='v_attends_detailed'))

# --- Venue ---
@app.route('/admin/update_venue/<string:vid>', methods=['POST'])
def update_venue(vid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        vname = request.form['vname']
        capacity = request.form['capacity']
        floor = request.form['floor']
        room = request.form['room']
        block = request.form['block']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE venue SET vname = %s, capacity = %s, floor = %s, room = %s, block = %s WHERE vid = %s",
            (vname, capacity, floor, room, block, vid)
        )
        conn.commit()
        flash(f"Venue '{vname}' updated successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating venue: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='venue'))

@app.route('/admin/delete_venue/<string:vid>', methods=['POST'])
def delete_venue(vid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM venue WHERE vid = %s", (vid,))
        conn.commit()
        flash(f"Venue {vid} deleted successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting venue: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='venue'))

# --- Resource ---
@app.route('/admin/update_resource/<string:rid>', methods=['POST'])
def update_resource(rid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        type = request.form['type']
        pred_quantity = request.form['pred_quantity']
        # You might want to add 'used_quantity' here if admin can edit it
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE resource SET type = %s, pred_quantity = %s WHERE rid = %s",
            (type, pred_quantity, rid)
        )
        conn.commit()
        flash(f"Resource '{type}' updated successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating resource: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='resource'))

@app.route('/admin/delete_resource/<string:rid>', methods=['POST'])
def delete_resource(rid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM resource WHERE rid = %s", (rid,))
        conn.commit()
        flash(f"Resource {rid} deleted successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting resource: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='resource'))

# --- Sponsor ---
@app.route('/admin/update_sponsor/<string:spid>', methods=['POST'])
def update_sponsor(spid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        sname = request.form['sname']
        contri_type = request.form['contri_type']
        contri_amt = request.form['contri_amt']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE sponsor SET sname = %s, contri_type = %s, contri_amt = %s WHERE spid = %s",
            (sname, contri_type, contri_amt, spid)
        )
        conn.commit()
        flash(f"Sponsor '{sname}' updated successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating sponsor: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='sponsor'))

@app.route('/admin/delete_sponsor/<string:spid>', methods=['POST'])
def delete_sponsor(spid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM sponsor WHERE spid = %s", (spid,))
        conn.commit()
        flash(f"Sponsor {spid} deleted successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting sponsor: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='sponsor'))

# --- Faculty ---
@app.route('/admin/update_faculty/<string:fid>', methods=['POST'])
def update_faculty(fid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        ffname = request.form['ffname']
        flname = request.form['flname']
        dept = request.form['dept']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE faculty SET ffname = %s, flname = %s, dept = %s WHERE fid = %s",
            (ffname, flname, dept, fid)
        )
        conn.commit()
        flash(f"Faculty member '{ffname}' updated successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating faculty: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='faculty'))

@app.route('/admin/delete_faculty/<string:fid>', methods=['POST'])
def delete_faculty(fid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM faculty WHERE fid = %s", (fid,))
        conn.commit()
        flash(f"Faculty {fid} deleted successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting faculty: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='faculty'))

# --- Feedback (Composite Key) ---
@app.route('/admin/update_feedback/<string:fbid>', methods=['POST'])
def update_feedback(fbid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        rating = request.form['rating']
        comment = request.form['comment']
        # You probably don't want to change the event_id, so we leave it
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE feedback SET rating = %s, comment = %s WHERE fbid = %s",
            (rating, comment, fbid)
        )
        conn.commit()
        flash(f"Feedback {fbid} updated successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating feedback: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='v_feedback_detailed'))

@app.route('/admin/delete_feedback/<string:fbid>', methods=['POST'])
def delete_feedback(fbid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM feedback WHERE fbid = %s", (fbid,))
        conn.commit()
        flash(f"Feedback {fbid} deleted successfully!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting feedback: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='v_feedback_detailed'))

# --- Is_Part_Of (Composite Key) ---
@app.route('/admin/update_is_part_of/<string:sid>/<string:cid>', methods=['POST'])
def update_is_part_of(sid, cid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        role = request.form['role']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE is_part_of SET role = %s WHERE sid = %s AND cid = %s",
            (role, sid, cid)
        )
        conn.commit()
        flash(f"Membership for {sid} in {cid} updated!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error updating membership: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='v_club_membership'))

@app.route('/admin/delete_is_part_of/<string:sid>/<string:cid>', methods=['POST'])
def delete_is_part_of(sid, cid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM is_part_of WHERE sid = %s AND cid = %s", (sid, cid))
        conn.commit()
        flash(f"Membership for {sid} in {cid} deleted!", 'success')
    except mysql.connector.Error as err:
        flash(f"Error deleting membership: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
    return redirect(url_for('admin_dashboard', view='v_club_membership'))

@app.route('/admin/allocate_resource', methods=['POST'])
def allocate_resource():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    eid = request.form['eid'] # Get the event id from the hidden input
    try:
        rid = request.form['rid']
        quantity = request.form['quantity'] 
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if this allocation already exists
        cursor.execute("SELECT * FROM allocated WHERE eid = %s AND rid = %s", (eid, rid))
        exists = cursor.fetchone()
        
        if exists:
            # If it exists, UPDATE the quantity
            cursor.execute(
                "UPDATE allocated SET allocated_quantity = allocated_quantity + %s WHERE eid = %s AND rid = %s",
                (quantity, eid, rid)
            )
            flash(f"Resource quantity updated!", 'success')
        else:
            # If it doesn't exist, INSERT a new row
            cursor.execute(
                "INSERT INTO allocated (eid, rid, allocated_quantity) VALUES (%s, %s, %s)",
                (eid, rid, quantity)
            )
            flash(f"Resource allocated successfully!", 'success')

        conn.commit()
        
    except mysql.connector.Error as err:
        flash(f"Error allocating resource: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    # Redirect back to the same edit page
    return redirect(url_for('admin_dashboard', view='v_event_summary', edit=eid))

@app.route('/admin/deallocate_resource/<string:eid>/<string:rid>', methods=['POST'])
def deallocate_resource(eid, rid):
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('login'))
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # This delete will trigger your new SQL trigger
        cursor.execute("DELETE FROM allocated WHERE eid = %s AND rid = %s", (eid, rid))
        conn.commit()
        flash(f"Resource de-allocated successfully!", 'success')
        
    except mysql.connector.Error as err:
        flash(f"Error de-allocating resource: {err}", 'error')
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()
            
    return redirect(url_for('admin_dashboard', view='v_event_summary', edit=eid))

# --- 6. Run the App ---
if __name__ == '__main__':
    app.run(debug=True)
