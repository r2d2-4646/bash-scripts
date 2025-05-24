#!/bin/bash

# Ubuntu Server Security Audit Script
# Generates a comprehensive security report

REPORT_FILE="/var/log/ubuntu_security_audit_$(date +%Y%m%d).txt"

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try 'sudo $0'" >&2
    exit 1
fi

# Create report header
{
    echo "=============================================="
    echo " Ubuntu Server Security Audit Report"
    echo " Date: $(date)"
    echo " Hostname: $(hostname)"
    echo "=============================================="
    echo ""
} > "$REPORT_FILE"

# 1. System Information
{
    echo "=== SYSTEM INFORMATION ==="
    echo "- Ubuntu Version:"
    lsb_release -a
    echo ""
    echo "- Kernel Version:"
    uname -a
    echo ""
    echo "- Uptime:"
    uptime
    echo ""
    echo "- Last Reboot:"
    who -b
    echo ""
} >> "$REPORT_FILE"

# 2. User Account Audit
{
    echo "=== USER ACCOUNTS ==="
    echo "- Users with login shells:"
    grep -v "/nologin\|/false" /etc/passwd | cut -d: -f1
    echo ""
    echo "- Users with UID 0 (root):"
    grep ':x:0:' /etc/passwd
    echo ""
    echo "- Empty password accounts:"
    awk -F: '($2 == "") {print $1}' /etc/shadow
    echo ""
    echo "- Sudoers:"
    grep -Po '^sudo.+:\K.*$' /etc/group
    echo ""
    echo "- Last logins:"
    lastlog | grep -v "Never logged in"
    echo ""
} >> "$REPORT_FILE"

# 3. SSH Security
{
    echo "=== SSH CONFIGURATION ==="
    echo "- SSH daemon status:"
    systemctl status ssh --no-pager
    echo ""
    echo "- SSH configuration:"
    grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"
    echo ""
    echo "- Root login enabled:"
    grep "^PermitRootLogin" /etc/ssh/sshd_config || echo "PermitRootLogin not explicitly set (default is prohibit-password)"
    echo ""
    echo "- Password authentication enabled:"
    grep "^PasswordAuthentication" /etc/ssh/sshd_config || echo "PasswordAuthentication not explicitly set (default is yes)"
    echo ""
} >> "$REPORT_FILE"

# 4. Firewall Status
{
    echo "=== FIREWALL STATUS ==="
    echo "- UFW status:"
    ufw status verbose
    echo ""
    echo "- Active iptables rules:"
    iptables -L -n -v
    echo ""
} >> "$REPORT_FILE"

# 5. Package Security
{
    echo "=== PACKAGE SECURITY ==="
    echo "- Unattended upgrades status:"
    systemctl status unattended-upgrades --no-pager
    echo ""
    echo "- Automatic updates configuration:"
    cat /etc/apt/apt.conf.d/20auto-upgrades 2>/dev/null || echo "No automatic updates configuration found"
    echo ""
    echo "- Security updates available:"
    apt list --upgradable 2>/dev/null | grep -i security
    echo ""
    echo "- Installed security packages:"
    dpkg -l | grep -E 'fail2ban|rkhunter|lynis|clamav|chkrootkit'
    echo ""
} >> "$REPORT_FILE"

# 6. File System Security
{
    echo "=== FILE SYSTEM SECURITY ==="
    echo "- World-writable files:"
    find / -xdev -type f -perm -0002 -exec ls -ld {} \; 2>/dev/null | head -n 20
    echo ""
    echo "- SUID/SGID files:"
    find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -exec ls -ld {} \; 2>/dev/null | head -n 20
    echo ""
    echo "- /etc/passwd permissions:"
    ls -l /etc/passwd
    echo ""
    echo "- /etc/shadow permissions:"
    ls -l /etc/shadow
    echo ""
} >> "$REPORT_FILE"

# 7. Network Security
{
    echo "=== NETWORK SECURITY ==="
    echo "- Listening ports:"
    ss -tulnp
    echo ""
    echo "- Established connections:"
    ss -tup
    echo ""
    echo "- ARP table:"
    arp -a
    echo ""
    echo "- Network interfaces:"
    ip a
    echo ""
} >> "$REPORT_FILE"

# 8. Cron Jobs
{
    echo "=== CRON JOBS ==="
    echo "- System cron jobs:"
    ls -la /etc/cron.*
    echo ""
    echo "- User cron jobs:"
    for user in $(cut -f1 -d: /etc/passwd); do crontab -l -u "$user" 2>/dev/null | grep -v "^#"; done
    echo ""
} >> "$REPORT_FILE"

# 9. Logging Configuration
{
    echo "=== LOGGING CONFIGURATION ==="
    echo "- Rsyslog status:"
    systemctl status rsyslog --no-pager
    echo ""
    echo "- Auth log (recent entries):"
    tail -20 /var/log/auth.log
    echo ""
    echo "- Failed login attempts:"
    grep "Failed password" /var/log/auth.log | tail -10
    echo ""
} >> "$REPORT_FILE"

# 10. Security Recommendations
{
    echo "=== SECURITY RECOMMENDATIONS ==="
    echo "1. Review user accounts and remove unnecessary ones"
    echo "2. Disable root SSH login if not absolutely needed"
    echo "3. Enable SSH key authentication and disable password auth if possible"
    echo "4. Configure automatic security updates"
    echo "5. Review listening ports and disable unnecessary services"
    echo "6. Install and configure fail2ban for SSH protection"
    echo "7. Consider installing and running Lynis for deeper security audit"
    echo "8. Review cron jobs for suspicious activity"
    echo "9. Check world-writable and SUID/SGID files list"
    echo "10. Consider enabling UFW firewall with restrictive rules"
    echo ""
} >> "$REPORT_FILE"

echo "Security audit completed. Report saved to: $REPORT_FILE"
