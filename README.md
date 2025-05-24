# bash-scripts
My multi purpose bash scripts for Ubuntu Servers
Some information about the scripts

dns_testing.sh
---------------------
Upgrades are as follows:
set -euo pipefail for better error handling, 
Input validation for all user entries, 
CTRL+C trap to prevent partial execution, 
Colorized output for better readability,
Timeouts for network operations,
More comprehensive full diagnostic,
Better error messages,
Modular functions for each test,
Proper variable quoting,
Input sanitization,
Helpful comments,
Clearer prompts,
Pause after each operation,
Better error feedback,
More options (exit option).

Technical Improvements:
Uses ip command instead of deprecated ifconfig,
Added timeouts to curl and ping,
Filtered comments from resolv.conf,
Colorized ip command output.

error_log_scanner.sh
---------------------
It loops through key logs and filters for potentially problematic entries.

disk_space.sh
---------------------
This script snippet is effective for checking disk usage by log files. 
Uses du -b for accurate sorting (bytes instead of human-readable). 
numfmt formats size properly for readable output after sorting. 
Handles filenames with spaces safely with awk and quoting.
Suppresses find errors using 2>/dev/null.

bandwith_usage_monitor.sh
---------------------
Checks for root privileges. Verifies iftop installation. Offers to install iftop if missing. Lists available network interfaces
Uses select for interactive interface choice. Clean interface with clear prompts. Added duration limit (30 seconds by default). Explicit root check. Proper command validation. Clean error exits
