#!/bin/bash

# --- Signal Trap Logic ---
cleanup_on_interrupt() {
    echo -e "\n\n[!] Interrupt detected (SIGINT)."
    if [[ -d "$PARENT_DIR" ]]; then
        ARCHIVE_DIR="${PARENT_DIR}_archive"
        echo "Moving current state to directory: $ARCHIVE_DIR..."
        rm -rf "$ARCHIVE_DIR"
        mv "$PARENT_DIR" "$ARCHIVE_DIR"
    fi
    echo "Exiting safely. Incomplete workspace cleaned."
    exit 1
}

trap cleanup_on_interrupt SIGINT

# 1. Get user input for version
read -p "Enter the version (e.g., v1): " version

if [[ -z "$version" ]]; then
    echo "Error: Version input cannot be empty."
    exit 1
fi

PARENT_DIR="attendance_tracker_${version}"

if [[ -d "$PARENT_DIR" ]]; then
    echo "Error: Directory '$PARENT_DIR' already exists."
    exit 1
fi

# 2. Create Structure
echo "Creating structure for $PARENT_DIR..."
if mkdir -p "${PARENT_DIR}/Helpers" "${PARENT_DIR}/reports"; then
    
    # --- Write the Python Script ---
    cat << 'EOF' > "${PARENT_DIR}/attendance_checker.py"
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

    # --- Write Initial Config Data ---
    cat << 'EOF' > "${PARENT_DIR}/Helpers/config.json"
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

    # --- Threshold Configuration Logic ---
    while true; do
        read -p "Do you want to update the attendance thresholds? (y/n): " choice
        case "$choice" in 
            [yY]* )
                read -p "Enter Warning threshold % (default 75): " user_warn
                read -p "Enter Failure threshold % (default 50): " user_fail
                [[ -n "$user_warn" ]] && sed -i "s/\"warning\": 75/\"warning\": $user_warn/" "${PARENT_DIR}/Helpers/config.json"
                [[ -n "$user_fail" ]] && sed -i "s/\"failure\": 50/\"failure\": $user_fail/" "${PARENT_DIR}/Helpers/config.json"
                break
                ;;
            [nN]* ) 
                echo "Keeping default thresholds."
                break
                ;;
            * ) 
                echo "Invalid input. Please enter 'y' for yes or 'n' for no."
                ;;
        esac
    done

    # --- Write CSV Data ---
    cat << 'EOF' > "${PARENT_DIR}/Helpers/assets.csv"
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
tendai@example.com,Tendai Mtakiwa,4,1
EOF

    # --- Write Initial Log Data ---
    cat << 'EOF' > "${PARENT_DIR}/reports/reports.log"
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

    # --- Health Check ---
    echo "--------------------------------"
    echo "Running Health Check..."
    
    # Check Python 3
    if command -v python3 &>/dev/null; then
        PY_VER=$(python3 --version)
        echo "[SUCCESS] $PY_VER found."
    else
        echo "[WARNING] python3 is not installed. You will need it to run the tracker."
    fi

    # Verify Directory Structure
    REQUIRED_PATHS=(
        "$PARENT_DIR/attendance_checker.py"
        "$PARENT_DIR/Helpers/assets.csv"
        "$PARENT_DIR/Helpers/config.json"
        "$PARENT_DIR/reports/reports.log"
    )

    ALL_FOUND=true
    for path in "${REQUIRED_PATHS[@]}"; do
        if [[ ! -e "$path" ]]; then
            echo "[ERROR] Missing component: $path"
            ALL_FOUND=false
        fi
    done

    if [ "$ALL_FOUND" = true ]; then
        echo "[SUCCESS] Application directory structure is correct."
        echo "--------------------------------"
        echo "Setup complete! Navigate to ${PARENT_DIR} and run 'python3 attendance_checker.py'"
    else
        echo "[ERROR] Setup failed to create all components."
        exit 1
    fi

else
    echo "Error: Failed to create directories."
    exit 1
fi
