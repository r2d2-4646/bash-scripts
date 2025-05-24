#!/bin/bash
# Master System Monitoring Script
# Version 1.0
# Author: Linux Sysadmin - "r2d2-4646"

# Configuration
REPORT_FILE="/var/log/system_report_$(date +%Y%m%d).log"
ALERT_EMAIL="admin@example.com"
ALERT_THRESHOLDS=(
    ["CPU"]=90
    ["MEMORY"]=85
    ["DISK"]=90
)

# Header
echo "===== SYSTEM MONITORING REPORT =====" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "Hostname: $(hostname)" >> $REPORT_FILE
echo "===================================" >> $REPORT_FILE

# 1. System Information
function system_info {
    echo "" >> $REPORT_FILE
    echo "--- SYSTEM INFORMATION ---" >> $REPORT_FILE
    echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)" >> $REPORT_FILE
    echo "Kernel: $(uname -r)" >> $REPORT_FILE
    echo "Uptime: $(uptime -p)" >> $REPORT_FILE
    echo "Last Boot: $(who -b | awk '{print $3,$4}')" >> $REPORT_FILE
}

# 2. CPU Monitoring
function cpu_monitor {
    echo "" >> $REPORT_FILE
    echo "--- CPU USAGE ---" >> $REPORT_FILE
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "Current CPU Usage: ${CPU_USAGE}%" >> $REPORT_FILE
    CPU_CORES=$(nproc)
    echo "CPU Cores: $CPU_CORES" >> $REPORT_FILE
    CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}')
    echo "Load Average: $CPU_LOAD" >> $REPORT_FILE
    
    if (( $(echo "$CPU_USAGE > ${ALERT_THRESHOLDS[CPU]}" | bc -l) )); then
        echo "ALERT: High CPU usage detected!" >> $REPORT_FILE
        echo "High CPU usage detected on $(hostname): ${CPU_USAGE}%" | mail -s "CPU Alert" $ALERT_EMAIL
    fi
}

# 3. Memory Monitoring
function memory_monitor {
    echo "" >> $REPORT_FILE
    echo "--- MEMORY USAGE ---" >> $REPORT_FILE
    MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
    MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
    MEM_PERCENT=$((MEM_USED*100/MEM_TOTAL))
    echo "Total Memory: ${MEM_TOTAL}MB" >> $REPORT_FILE
    echo "Used Memory: ${MEM_USED}MB (${MEM_PERCENT}%)" >> $REPORT_FILE
    
    if [ $MEM_PERCENT -gt ${ALERT_THRESHOLDS[MEMORY]} ]; then
        echo "ALERT: High memory usage detected!" >> $REPORT_FILE
        echo "High memory usage detected on $(hostname): ${MEM_PERCENT}%" | mail -s "Memory Alert" $ALERT_EMAIL
    fi
    
    # Swap info
    SWAP_TOTAL=$(free -m | awk '/Swap:/ {print $2}')
    if [ $SWAP_TOTAL -gt 0 ]; then
        SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')
        SWAP_PERCENT=$((SWAP_USED*100/SWAP_TOTAL))
        echo "Swap Usage: ${SWAP_USED}MB (${SWAP_PERCENT}%)" >> $REPORT_FILE
    fi
}

# 4. Disk Monitoring
function disk_monitor {
    echo "" >> $REPORT_FILE
    echo "--- DISK USAGE ---" >> $REPORT_FILE
    df -h | grep -v tmpfs >> $REPORT_FILE
    
    # Check each filesystem
    df -P | awk '0+$5 >= 10 {print}' | while read line; do
        PARTITION=$(echo $line | awk '{print $1}')
        USAGE=$(echo $line | awk '{print $5}' | tr -d '%')
        
        if [ $USAGE -gt ${ALERT_THRESHOLDS[DISK]} ]; then
            echo "ALERT: Partition $PARTITION is ${USAGE}% full!" >> $REPORT_FILE
            echo "Partition $PARTITION on $(hostname) is ${USAGE}% full" | mail -s "Disk Space Alert" $ALERT_EMAIL
        fi
    done
}

# 5. Network Monitoring
function network_monitor {
    echo "" >> $REPORT_FILE
    echo "--- NETWORK INFORMATION ---" >> $REPORT_FILE
    echo "IP Addresses:" >> $REPORT_FILE
    ip -br addr show | grep -v "lo" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    echo "Active Connections:" >> $REPORT_FILE
    ss -tulnp | grep -v "127.0.0.1" >> $REPORT_FILE
}

# 6. Service Monitoring
function service_monitor {
    echo "" >> $REPORT_FILE
    echo "--- SERVICE STATUS ---" >> $REPORT_FILE
    SERVICES=("sshd" "nginx" "mysql" "crond")
    
    for service in "${SERVICES[@]}"; do
        if systemctl is-active --quiet $service; then
            echo "$service: RUNNING" >> $REPORT_FILE
        else
            echo "$service: NOT RUNNING" >> $REPORT_FILE
            echo "Service $service is not running on $(hostname)" | mail -s "Service Alert" $ALERT_EMAIL
        fi
    done
}

# 7. Security Checks
function security_checks {
    echo "" >> $REPORT_FILE
    echo "--- SECURITY CHECKS ---" >> $REPORT_FILE
    # Check for failed login attempts
    FAILED_LOGINS=$(grep "Failed password" /var/log/auth.log | wc -l)
    echo "Failed login attempts: $FAILED_LOGINS" >> $REPORT_FILE
    
    if [ $FAILED_LOGINS -gt 10 ]; then
        echo "ALERT: Multiple failed login attempts detected!" >> $REPORT_FILE
        echo "Multiple failed logins detected on $(hostname): $FAILED_LOGINS attempts" | mail -s "Security Alert" $ALERT_EMAIL
    fi
    
    # Check for root SSH access
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
        echo "WARNING: Root SSH login is enabled!" >> $REPORT_FILE
    fi
}

# 8. Temperature Monitoring (if sensors are installed)
function temp_monitor {
    if command -v sensors &> /dev/null; then
        echo "" >> $REPORT_FILE
        echo "--- TEMPERATURE INFORMATION ---" >> $REPORT_FILE
        sensors >> $REPORT_FILE
    fi
}

# Main execution
system_info
cpu_monitor
memory_monitor
disk_monitor
network_monitor
service_monitor
security_checks
temp_monitor

# Footer
echo "" >> $REPORT_FILE
echo "===== END OF REPORT =====" >> $REPORT_FILE

# Optional: Send report via email
# mail -s "System Monitoring Report for $(hostname)" $ALERT_EMAIL < $REPORT_FILE

echo "System monitoring report generated: $REPORT_FILE"
