#!/bin/bash

# Ubuntu Package Management Script
# Description: Lists installed packages, checks for updates, and allows selective upgrades
# Author: System Administrator
# Date: $(date +%Y-%m-%d)

# Configuration
INSTALLED_PKGS_FILE="/tmp/installed_packages_$(date +%Y%m%d).txt"
UPDATABLE_PKGS_FILE="/tmp/updatable_packages_$(date +%Y%m%d).txt"
UPGRADE_LOG="/var/log/selective_upgrade_$(date +%Y%m%d).log"

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try 'sudo $0'" >&2
    exit 1
fi

# Function to list installed packages
list_installed_packages() {
    echo "Listing all installed packages..."
    dpkg --get-selections | grep -v deinstall | awk '{print $1}' > "$INSTALLED_PKGS_FILE"
    echo "Installed packages list saved to: $INSTALLED_PKGS_FILE"
    echo "Total installed packages: $(wc -l < "$INSTALLED_PKGS_FILE")"
}

# Function to check for updates
check_updates() {
    echo "Checking for available updates..."
    apt-get update > /dev/null
    
    # List upgradable packages
    apt list --upgradable 2>/dev/null | grep -v "^Listing..." | cut -d'/' -f1 > "$UPDATABLE_PKGS_FILE"
    
    local updatable_count=$(wc -l < "$UPDATABLE_PKGS_FILE")
    echo "Updatable packages list saved to: $UPDATABLE_PKGS_FILE"
    echo "Total updatable packages: $updatable_count"
    
    if [ "$updatable_count" -gt 0 ]; then
        echo -e "\nUpdatable packages:"
        apt list --upgradable 2>/dev/null | grep -v "^Listing..."
    else
        echo "No packages need updating."
        exit 0
    fi
}

# Function to compare lists
compare_lists() {
    echo -e "\nComparing installed and updatable packages..."
    echo "Packages that can be updated:"
    comm -12 <(sort "$INSTALLED_PKGS_FILE") <(sort "$UPDATABLE_PKGS_FILE") | while read -r pkg; do
        current_ver=$(dpkg -s "$pkg" | grep Version | cut -d' ' -f2)
        new_ver=$(apt-cache policy "$pkg" | grep Candidate | cut -d' ' -f4)
        echo "$pkg (Current: $current_ver, Available: $new_ver)"
    done
}

# Function for selective upgrade
selective_upgrade() {
    echo -e "\nStarting selective upgrade process..."
    echo "You can choose to upgrade all packages or select specific ones."
    
    while true; do
        read -rp "Do you want to (U)pgrade all, (S)elect packages, or (Q)uit? [U/s/q]: " choice
        case "$choice" in
            [Uu]*|"" )
                echo "Upgrading all packages..."
                apt-get upgrade -y | tee -a "$UPGRADE_LOG"
                break
                ;;
            [Ss]* )
                echo "Available packages for upgrade:"
                select pkg in $(cat "$UPDATABLE_PKGS_FILE") "DONE"; do
                    if [ "$pkg" = "DONE" ]; then
                        break
                    elif [ -n "$pkg" ]; then
                        echo "Upgrading $pkg..."
                        apt-get install --only-upgrade -y "$pkg" | tee -a "$UPGRADE_LOG"
                    fi
                done
                break
                ;;
            [Qq]* )
                echo "Exiting without upgrading."
                exit 0
                ;;
            * )
                echo "Invalid choice. Please enter U, S, or Q."
                ;;
        esac
    done
    
    echo "Upgrade log saved to: $UPGRADE_LOG"
}

# Main execution
echo "=== Ubuntu Package Management Script ==="
list_installed_packages
check_updates
compare_lists
selective_upgrade

echo -e "\nOperation completed."
