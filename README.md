Project: Automated Project Bootstrapping & Process Management

This project helps you set up a system to track attendance. It creates all the folders you need and includes a Python script to check who is missing too many classes.

What it does :
1. Creates all folders and files for you automatically.
2 . You can choose your own passing and failing grades, e.g., failure below 50 and a pass is above 75
3. If you stop the script early, it cleans up and atomatically save the mess in an archive folder
4. When you run the file,e it sends a report

How to use it :
1. Start the setup 
./setup_attendance.sh
2. Follow the instructions 
Type v1 
3. Run the tracker 
cd attendance_tracker_v1
python3 attendance_checker.py
4. Check for the tree structure, it should have 

attendance_checker.py: The main program.

Helpers/: Stores your list of names (assets.csv) and your settings (config.json).

reports/: Stores the final results and alerts
5. Interrupting the script 
Press Ctrl+C
it moves everything to the folder 
