#!/bin/bash

# Enhanced Log Error Scanner

# Define important log files
important_logs=(
    "/var/log/syslog"
    "/var/log/auth.log"
    "/var/log/kern.log"
    "/var/log/dpkg.log"
)

# Define error keywords (case-insensitive)
error_keywords="error|fail|warning|critical"

echo "=== Scanning for Errors in Logs ==="

for log in "${important_logs[@]}"; do
    if [ -f "$log" ]; then
        echo -e "\n\e[1;34m=== Errors in $log ===\e[0m"
        grep -i -E "$error_keywords" "$log" | tail -20 || echo "No matching entries found."
    else
        echo -e "\e[1;31m[!] Log file not found: $log\e[0m"
    fi
done

