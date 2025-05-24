#!/bin/bash

# Run this script with sudo
LOG_FILE="/var/log/auth.log"
RESULT_COUNT=20
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ ! -f "$LOG_FILE" ]; then
  echo "Log file $LOG_FILE not found."
  exit 1
fi

section() {
  echo -e "\n${RED}=== $1 ===${NC}"
}

section "Failed Authentication Attempts"
grep -i 'fail' "$LOG_FILE" | grep -v 'invalid user' | tail -n "$RESULT_COUNT"

section "Invalid User Attempts"
grep -i 'invalid user' "$LOG_FILE" | tail -n "$RESULT_COUNT"

section "Successful Logins"
grep "session opened for user" "$LOG_FILE" | tail -n "$RESULT_COUNT"

section "Root Login Attempts"
grep "session opened for user root" "$LOG_FILE" | tail -n "$RESULT_COUNT"

section "Sudo Usage"
grep "sudo" "$LOG_FILE" | tail -n "$RESULT_COUNT"

section "User Lockouts or PAM Failures"
grep -Ei "pam_unix|authentication failure" "$LOG_FILE" | tail -n "$RESULT_COUNT"

section "SSH Login Attempts"
grep 'sshd' "$LOG_FILE" | grep -Ei 'Accepted|Failed|Invalid' | tail -n "$RESULT_COUNT"

section "New User Accounts (from /var/log/syslog)"
if [ -f /var/log/syslog ]; then
  grep 'useradd' /var/log/syslog | tail -n "$RESULT_COUNT"
else
  echo "syslog not available."
fi

