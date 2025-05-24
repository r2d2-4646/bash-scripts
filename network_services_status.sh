#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log file setup
LOG_DIR="$HOME/network_health_logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE="$LOG_DIR/network_health_report_$TIMESTAMP.txt"

echo -e "${YELLOW}=== Network Services Status ===${NC}" > "$LOG_FILE"

# Default services
services=("sshd" "apache2" "nginx" "postfix" "mysql" "docker")

# Optional: allow user to add services
echo "Would you like to add custom services to check? (y/n): "
read add_custom

if [[ "$add_custom" =~ ^[Yy]$ ]]; then
  echo "Enter service names separated by space (e.g., fail2ban php-fpm):"
  read -a custom_services
  services+=("${custom_services[@]}")
fi

# Check each service
for service in "${services[@]}"; do
  if systemctl list-unit-files | grep -q "^$service.service"; then
    status=$(systemctl is-active "$service")
    enabled=$(systemctl is-enabled "$service" 2>/dev/null)

    # Colorize output and add to log file
    if [[ "$status" == "active" ]]; then
      echo -e "$service: ${GREEN}active${NC} (${enabled})" | tee -a "$LOG_FILE"
    else
      echo -e "$service: ${RED}$status${NC} (${enabled})" | tee -a "$LOG_FILE"
      
      # Check if service is failed or inactive, and try to start it
      if [[ "$status" == "failed" || "$status" == "inactive" ]]; then
        echo -e "Attempting to start $service..." | tee -a "$LOG_FILE"
        sudo systemctl start "$service" && echo "$service started successfully." | tee -a "$LOG_FILE"
        
        # Check logs for failed services
        if [[ "$status" == "failed" ]]; then
          echo -e "Logs for failed service $service:" | tee -a "$LOG_FILE"
          sudo journalctl -u "$service" --since "1 hour ago" | tail -n 20 | tee -a "$LOG_FILE"
        fi
      fi
    fi

    # Show PID and resource info for active services
    if [[ "$status" == "active" ]]; then
      pid=$(systemctl show -p MainPID "$service" | cut -d= -f2)
      if [[ -n "$pid" ]]; then
        echo -e "PID for $service: $pid" | tee -a "$LOG_FILE"
        ps -p "$pid" -o pid,%cpu,%mem,command | tee -a "$LOG_FILE"
      fi
    fi
  else
    echo -e "$service: ${RED}Not installed or unknown service${NC}" | tee -a "$LOG_FILE"
  fi
done

# Listening ports
echo -e "\n${YELLOW}=== Listening Ports ===${NC}" | tee -a "$LOG_FILE"
if command -v ss &> /dev/null; then
  sudo ss -tulnp | grep LISTEN | tee -a "$LOG_FILE"
else
  sudo netstat -tulnp | grep LISTEN | tee -a "$LOG_FILE"
fi

echo -e "\nNetwork health report saved to: $LOG_FILE"


