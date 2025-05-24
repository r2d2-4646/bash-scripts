#!/usr/bin/env bash

# Enhanced Bandwidth Monitor v2.0
set -eo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for root permissions
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: Please run as root or with sudo${NC}"
        exit 1
    fi
}

# Verify iftop installation
verify_iftop() {
    if ! command -v iftop &> /dev/null; then
        echo -e "${YELLOW}iftop not found.${NC}"
        read -rp "Install iftop? (y/n): " install_choice
        if [[ "$install_choice" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Updating packages...${NC}"
            if ! apt update; then
                echo -e "${RED}Failed to update packages${NC}"
                exit 1
            fi
            echo -e "${BLUE}Installing iftop...${NC}"
            if ! apt install -y iftop; then
                echo -e "${RED}Failed to install iftop${NC}"
                exit 1
            fi
        else
            echo -e "${RED}iftop is required for this script${NC}"
            exit 1
        fi
    fi
}

# Get network interfaces
get_interfaces() {
    ip -o link show | awk -F': ' '!/lo:/ {print $2}'
}

# Monitor bandwidth
monitor_bandwidth() {
    local iface=$1
    local duration=30  # Default monitoring duration in seconds
    
    echo -e "\n${GREEN}=== Monitoring ${iface} ===${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop monitoring${NC}"
    
    iftop -i "$iface" -t -s "$duration" -P -n -N -B 2>/dev/null || \
        echo -e "${RED}Error monitoring interface ${iface}${NC}"
}

# Main execution
main() {
    check_root
    verify_iftop
    
    echo -e "${BLUE}=== Bandwidth Usage Monitor ===${NC}"
    
    # Get available interfaces (exclude loopback)
    mapfile -t interfaces < <(get_interfaces)
    
    if [ ${#interfaces[@]} -eq 0 ]; then
        echo -e "${RED}No network interfaces found!${NC}"
        exit 1
    fi
    
    PS3="Select an interface (or $((${#interfaces[@]}+1)) to quit): "
    select iface in "${interfaces[@]}" "Quit"; do
        case $REPLY in
            [1-9]|[1-9][0-9])
                if [[ "$REPLY" -le "${#interfaces[@]}" ]]; then
                    monitor_bandwidth "$iface"
                    break
                fi
                ;;
            $((${#interfaces[@]}+1)))
                echo -e "${GREEN}Exiting.${NC}"
                break
                ;;
            *)
                echo -e "${RED}Invalid selection. Try again.${NC}"
                ;;
        esac
    done
}

main
