#!/bin/bash

# Requirement: Signal Handling (Graceful exit on Ctrl+C)
trap 'echo -e "\nSetup interrupted."; exit 1' SIGINT

# Requirement: Get the {input} string from the user
echo "Enter the version name (e.g., v1):"
read USER_INPUT

# Requirement: Define the Parent Directory
PARENT_DIR="attendance_tracker_$USER_INPUT"

# Requirement: Create Directory Architecture
# -p creates subfolders (Helpers/reports) inside the parent at once
mkdir -p "$PARENT_DIR/Helpers" "$PARENT_DIR/reports"

# Requirement: Bootstrap the files into the correct structure
touch "$PARENT_DIR/attendance_checker.py"
touch "$PARENT_DIR/Helpers/assets.csv"
touch "$PARENT_DIR/Helpers/config.json"
touch "$PARENT_DIR/reports/reports.log"

echo "------------------------------------------"
echo "Project Factory Complete: $PARENT_DIR created."
