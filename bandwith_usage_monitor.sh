#!/bin/bash

# Bandwidth monitor with iftop

# Check for root permissions
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo."
  exit 1
fi

# Check if iftop is installed
if ! command -v iftop &> /dev/null; then
  echo "iftop not found. Install it? (y/n): "
  read install_choice
  if [[ "$install_choice" =~ ^[Yy]$ ]]; then
    apt update && apt install -y iftop
  else
    echo "iftop is required to run this script."
    exit 1
  fi
fi

# Get interfaces
interfaces=($(ip -o link show | awk -F': ' '{print $2}'))

echo "=== Bandwidth Usage Monitor ==="
echo "Select an interface:"
select iface in "${interfaces[@]}" "Quit"; do
  if [[ "$REPLY" -ge 1 && "$REPLY" -le "${#interfaces[@]}" ]]; then
    echo "Monitoring bandwidth on $iface..."
    iftop -i "$iface" -P
    break
  elif [[ "$REPLY" -eq $((${#interfaces[@]}+1)) ]]; then
    echo "Exiting."
    break
  else
    echo "Invalid selection. Try again."
  fi
done

