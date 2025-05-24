#!/bin/bash

# Running & Enabled Services Monitoring Script for Ubuntu 22 Server

# Colors
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Optional: Log output to file
exec > >(tee "services_report_$(date +%F).log") 2>&1

# Header
clear
echo -e "${CYAN}==========================================="
echo -e "🚀 Running & Enabled Services Report"
echo -e "===========================================${NC}"

# Running Services
echo -e "\n${YELLOW}✅ Running Services:${NC}"
printf "%-50s %-10s %-10s\n" "SERVICE NAME" "LOAD" "ACTIVE"
systemctl list-units --type=service --state=running --no-pager | awk 'NR>1 {printf "%-50s %-10s %-10s\n", $1, $4, $5}' | head -n -7

# Enabled Services
echo -e "\n${YELLOW}🔹 Enabled Services (Start at Boot):${NC}"
printf "%-50s %-10s\n" "SERVICE NAME" "STATE"
systemctl list-unit-files --type=service --state=enabled --no-pager | awk 'NR>1 {printf "%-50s %-10s\n", $1, $2}' | head -n -1

# Footer
echo -e "\n${GREEN}✅ Service Check Completed! Log saved to $(pwd)/services_report_$(date +%F).log${NC}"

