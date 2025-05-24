#!/bin/bash

# === Ultimate Ubuntu 22 Server Diagnostic Toolkit ===

# ───────────────────────────── Colors ─────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ───────────────────────────── Setup ─────────────────────────────
clear
LOG_FILE="ubuntu_diagnostic_$(date +%F).log"
exec > >(tee "$LOG_FILE") 2>&1

echo -e "${CYAN}===================================================="
echo -e "🛠️  Ubuntu 22 Server Full Diagnostic Toolkit"
echo -e "Date: $(date)"
echo -e "====================================================${NC}"

# ───────────────────────────── System Info ─────────────────────────────
echo -e "\n${YELLOW}🖥️ System Info:${NC}"
lsb_release -a 2>/dev/null
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
lscpu | awk '/Model name|CPU\(s\)|Thread\(s\) per core/'
free -h
df -hT --total

# ───────────────────────────── Network Info ─────────────────────────────
echo -e "\n${YELLOW}🌐 Network Info:${NC}"
hostnamectl
ip -br a
ss -tulnp
ip route show
if [[ -f /etc/resolv.conf ]]; then
    cat /etc/resolv.conf
else
    echo -e "${RED}⚠️ /etc/resolv.conf not found.${NC}"
fi
if command -v netstat &>/dev/null; then
    netstat -i
else
    ip -s link
fi
echo -e "\n${YELLOW}🔥 UFW Firewall:${NC}"
ufw status verbose

# ───────────────────────────── Services Info ─────────────────────────────
echo -e "\n${YELLOW}⚙️ Running Services:${NC}"
systemctl list-units --type=service --state=running --no-pager | awk 'NR>1 {print $1, $4, $5}' | head -n -7
echo -e "\n${YELLOW}📌 Enabled Services (Boot):${NC}"
systemctl list-unit-files --type=service --state=enabled --no-pager | awk 'NR>1 {print $1, $2}' | head -n -1

# ───────────────────────────── Service Checks ─────────────────────────────
SERVICES=(
    "nginx"
    "docker"
    "postfix"
    "clamav-daemon"
    "clamav-freshclam"
    "containerd"
    "webmin"
    "rsyslog"
    "ssh"
)

echo -e "\n${YELLOW}🔍 Key Service Statuses:${NC}"
for svc in "${SERVICES[@]}"; do
    echo -e "\nChecking: $svc"
    if systemctl list-units --type=service | grep -q "$svc"; then
        systemctl is-active --quiet "$svc" && \
        echo -e "${GREEN}✅ $svc is running.${NC}" || \
        echo -e "${RED}❌ $svc is NOT running.${NC}"
    else
        echo -e "${RED}⚠️ $svc not found.${NC}"
    fi
done

# ───────────────────────────── Logs Overview ─────────────────────────────
LOG_FILES=(
    "/var/log/syslog"
    "/var/log/auth.log"
    "/var/log/kern.log"
    "/var/log/dmesg"
    "/var/log/apt/history.log"
    "/var/log/apt/term.log"
    "/var/log/boot.log"
    "/var/log/dpkg.log"
    "/var/log/ufw.log"
    "/var/log/cloud-init.log"
    "/var/log/nginx/access.log"
    "/var/log/nginx/error.log"
    "/var/log/postfix.log"
    "/var/log/clamav/clamav.log"
    "/var/log/docker.log"
)

echo -e "\n${YELLOW}📄 Tail of Key Log Files (last 30 lines):${NC}"
for log in "${LOG_FILES[@]}"; do
    echo -e "\n${CYAN}>> $log${NC}"
    if [[ -f "$log" ]]; then
        tail -n 30 "$log"
    else
        echo -e "${RED}Not found.${NC}"
    fi
done

# ───────────────────────────── Security Updates ─────────────────────────────
echo -e "\n${YELLOW}🛡️ Available Security Updates:${NC}"
apt update > /dev/null 2>&1
apt list --upgradable 2>/dev/null | grep -i security

# ───────────────────────────── Done ─────────────────────────────
echo -e "\n${GREEN}✅ Diagnostic Complete! Log saved to: $LOG_FILE${NC}"

