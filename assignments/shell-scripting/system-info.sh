#!/bin/bash

current_date=$(date)
computer_name=$(hostname)
current_user=$(whoami)
output_directory="system-info-output"
process_file="$output_directory/processes.log"

read -p "Enter your name: " name

mkdir -p "$output_directory"
touch "$process_file"
ps > "$process_file"

echo "System Information"
echo "------------------"
echo "Date: $current_date"
echo "Hostname: $computer_name"
echo "Username: $current_user"
echo
echo "Disk Usage:"
df -h
echo
echo "Running Processes:"
ps
echo
echo "Hello, $name."
echo "Process information was saved to $process_file."