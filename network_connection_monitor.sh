#!/bin/bash

# Color setup
CYAN='\033[0;36m'
NC='\033[0m' # No Color

while true; do
  clear
  echo -e "${CYAN}=== Active Network Connections ===${NC}"
  echo "1. All connections"
  echo "2. HTTP/HTTPS connections"
  echo "3. SSH connections"
  echo "4. Custom port"
  echo "5. Only ESTABLISHED connections"
  echo "6. Exit"
  echo -n "Enter your choice (1-6): "
  read choice

  case $choice in
    1)
      echo -e "\n${CYAN}--- All connections ---${NC}"
      sudo ss -tulnp
      ;;
    2)
      echo -e "\n${CYAN}--- HTTP/HTTPS connections (ports 80, 443) ---${NC}"
      sudo ss -tulnp | grep -E ':80\b|:443\b'
      ;;
    3)
      echo -e "\n${CYAN}--- SSH connections (port 22) ---${NC}"
      sudo ss -tulnp | grep -E ':22\b'
      ;;
    4)
      echo -n "Enter port number: "
      read port
      echo -e "\n${CYAN}--- Connections on port $port ---${NC}"
      sudo ss -tulnp | grep -E ":$port\b"
      ;;
    5)
      echo -e "\n${CYAN}--- ESTABLISHED Connections Only ---${NC}"
      sudo ss -tulnp | grep ESTAB
      ;;
    6)
      echo "Exiting..."
      break
      ;;
    *)
      echo "Invalid choice!"
      ;;
  esac

  echo ""
  read -n 1 -s -r -p "Press any key to return to menu..."
done

