#!/bin/bash

# Color definitions
CYAN='\033[0;36m'
NC='\033[0m' # No Color

while true; do
  clear
  echo -e "${CYAN}=== System Log Checker ===${NC}"
  echo "1. System messages (syslog)"
  echo "2. Authentication logs"
  echo "3. Kernel logs"
  echo "4. Package manager logs"
  echo "5. Apache/Nginx logs (if installed)"
  echo "6. Custom log file"
  echo "7. Exit"
  echo -n "Enter your choice (1-7): "
  read choice

  if [ "$choice" -eq 7 ]; then
    echo "Exiting..."
    break
  fi

  echo -n "How many lines to display? (default 50): "
  read line_count
  line_count=${line_count:-50}  # default to 50 if empty

  case $choice in
    1) LOG="/var/log/syslog" ;;
    2) LOG="/var/log/auth.log" ;;
    3) LOG="/var/log/kern.log" ;;
    4) LOG="/var/log/dpkg.log" ;;
    5)
        if [ -f /var/log/apache2/error.log ]; then
            LOG="/var/log/apache2/error.log"
        elif [ -f /var/log/nginx/error.log ]; then
            LOG="/var/log/nginx/error.log"
        else
            echo "Neither Apache nor Nginx logs found."
            read -n 1 -s -r -p "Press any key to return to menu..."
            continue
        fi
        ;;
    6)
        echo -n "Enter full path to log file: "
        read custom_log
        if [ -f "$custom_log" ]; then
            LOG="$custom_log"
        else
            echo "File not found!"
            read -n 1 -s -r -p "Press any key to return to menu..."
            continue
        fi
        ;;
    *) echo "Invalid choice!"
       read -n 1 -s -r -p "Press any key to return to menu..."
       continue
       ;;
  esac

  echo -e "\n${CYAN}--- Showing last $line_count lines of $LOG ---${NC}"
  sudo tail -n "$line_count" "$LOG"
  echo ""
  read -n 1 -s -r -p "Press any key to return to menu..."
done

