#!/bin/bash

# Logging setup
LOG_DIR="$HOME/network_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE="$LOG_DIR/network_log_$TIMESTAMP.txt"

# Color
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}=== Network Connection Logger ===${NC}"
echo "1. All connections"
echo "2. HTTP/HTTPS connections"
echo "3. SSH connections"
echo "4. Custom port"
echo "5. Only ESTABLISHED connections"
echo "6. Exit"
echo -n "Enter your choice (1-6): "
read choice

if [ "$choice" -eq 6 ]; then
  echo "Exiting..."
  exit 0
fi

echo -n "How many times do you want to monitor? (e.g., 5): "
read loops

echo -n "Interval between checks (seconds, e.g., 5): "
read interval

if [ "$choice" -eq 4 ]; then
  echo -n "Enter custom port number: "
  read port
fi

echo -e "\nLogging to: $LOG_FILE"
echo "=== Network Monitor Started: $(date) ===" >> "$LOG_FILE"

for ((i=1; i<=loops; i++)); do
  echo -e "\n--- Snapshot $i --- $(date) ---" >> "$LOG_FILE"
  case $choice in
    1)
      ss -tulnp >> "$LOG_FILE"
      ;;
    2)
      ss -tulnp | grep -E ':80\b|:443\b' >> "$LOG_FILE"
      ;;
    3)
      ss -tulnp | grep -E ':22\b' >> "$LOG_FILE"
      ;;
    4)
      ss -tulnp | grep -E ":$port\b" >> "$LOG_FILE"
      ;;
    5)
      ss -tulnp | grep ESTAB >> "$LOG_FILE"
      ;;
    *)
      echo "Invalid choice!" >> "$LOG_FILE"
      ;;
  esac
  sleep "$interval"
done

echo -e "${CYAN}\nDone logging. Output saved to:${NC} $LOG_FILE"

