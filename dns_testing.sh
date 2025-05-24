#!/usr/bin/env bash

# Network Diagnostic Script v2.0
set -euo pipefail
trap 'echo -e "\nOperation aborted by user"; exit 1' INT

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

header() {
    clear
    echo -e "${YELLOW}=== Network Connectivity Tests ===${NC}"
    echo -e "1. Basic ping test"
    echo -e "2. DNS resolution test"
    echo -e "3. HTTP/HTTPS connectivity test"
    echo -e "4. Full diagnostic"
    echo -e "5. Exit"
    echo -n -e "${GREEN}Enter choice (1-5): ${NC}"
}

validate_input() {
    local input=$1
    local min=$2
    local max=$3
    [[ $input =~ ^[0-9]+$ ]] && (( input >= min && input <= max ))
}

test_ping() {
    read -rp "Enter host/IP to ping: " host
    if [[ -z $host ]]; then
        echo -e "${RED}Error: Host cannot be empty${NC}"
        return 1
    fi
    ping -c 4 -W 3 "$host" || echo -e "${RED}Ping failed${NC}"
}

test_dns() {
    read -rp "Enter domain to resolve: " domain
    if [[ -z $domain ]]; then
        echo -e "${RED}Error: Domain cannot be empty${NC}"
        return 1
    fi
    echo -e "${YELLOW}DNS resolution for $domain:${NC}"
    dig +short "$domain" || echo -e "${RED}DNS resolution failed${NC}"
    echo -e "\n${YELLOW}Using DNS servers:${NC}"
    grep -v '^#' /etc/resolv.conf | grep nameserver || echo -e "${RED}No nameservers found${NC}"
}

test_http() {
    read -rp "Enter URL to test (without protocol): " url
    if [[ -z $url ]]; then
        echo -e "${RED}Error: URL cannot be empty${NC}"
        return 1
    fi
    echo -e "${YELLOW}Testing HTTPS...${NC}"
    if ! curl -sSI "https://$url" --connect-timeout 5; then
        echo -e "${YELLOW}HTTPS failed, trying HTTP...${NC}"
        curl -sSI "http://$url" --connect-timeout 5 || echo -e "${RED}HTTP connection failed${NC}"
    fi
}

full_diagnostic() {
    local divider="===================================="
    
    echo -e "\n${YELLOW}=== Network Interface Information ===${NC}"
    ip -c addr show
    
    echo -e "\n${YELLOW}=== Routing Table ===${NC}"
    ip -c route show
    
    echo -e "\n${YELLOW}=== Testing Connectivity ===${NC}"
    echo -e "${divider}"
    echo -e "Pinging Cloudflare DNS (1.1.1.1):"
    ping -c 4 -W 3 1.1.1.1 || echo -e "${RED}Ping failed${NC}"
    
    echo -e "\n${divider}"
    echo -e "Testing DNS resolution (cloudflare.com):"
    dig +short cloudflare.com || echo -e "${RED}DNS resolution failed${NC}"
    
    echo -e "\n${divider}"
    echo -e "Testing HTTPS connection:"
    curl -sSI https://cloudflare.com --connect-timeout 5 || echo -e "${RED}HTTPS connection failed${NC}"
}

while true; do
    header
    read -r choice
    
    if ! validate_input "$choice" 1 5; then
        echo -e "${RED}Invalid choice! Please enter a number between 1-5${NC}"
        sleep 2
        continue
    fi

    case $choice in
        1) test_ping ;;
        2) test_dns ;;
        3) test_http ;;
        4) full_diagnostic ;;
        5) echo -e "${GREEN}Exiting...${NC}"; exit 0 ;;
    esac
    
    echo -e "\n${YELLOW}Press any key to continue...${NC}"
    read -n 1 -s
done
