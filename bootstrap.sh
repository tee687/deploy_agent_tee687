#!/bin/bash

# Signal Handling
trap 'echo -e "\nSetup interrupted."; exit 1' SIGINT

# Get the {input} string from the user
echo "Enter the version name (e.g., v1):"
read USER_INPUT

# Define the Parent Directory
PARENT_DIR="attendance_tracker_$USER_INPUT"

# Create Directory Architecture
# -p creates subfolders (Helpers/reports) inside the parent at once
mkdir -p "$PARENT_DIR/Helpers" "$PARENT_DIR/reports"

# Bootstrap the files 
touch "$PARENT_DIR/attendance_checker.py"
touch "$PARENT_DIR/Helpers/assets.csv"
touch "$PARENT_DIR/Helpers/config.json"
touch "$PARENT_DIR/reports/reports.log"

# Default values into configaration
echo '{"Warning": "75%", "Failure": "50%"}' > "$PARENT_DIR/Helpers/config.json"

# Prompt for new values
echo "Update attendance thresholds? (Press Enter for defaults)"
read -p "Enter Warning threshold (e.g., 80%): " NEW_WARNING
read -p "Enter Failure threshold (e.g., 45%): " NEW FAILURE

# Defaults if user leaves input empty
NEW_WARNING=${NEW_WARNING:-75%}
NEW_FAILURE=${NEW_FAILURE:-50%}

# Replacing the default values with new inputs
sed -i "s/\"Warning\": \".*\"/\"Warning\": \"$NEW_WARNING\"/" "$PARENT_DIR/Helpers/config.json"
sed -i "s/\"Failure\": \".*\"/\"Failure\": \"$NEW_FAILURE\"/" "$PARENT_DIR/Helpers/config.json"

echo "------------------------------------------"
echo "Project Factory Complete: $PARENT_DIR created."  


