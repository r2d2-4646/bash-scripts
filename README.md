# bash-scripts
My multi purpose bash scripts for Ubuntu Servers
Some information about the scripts

dns_testing.sh
---------------------
Upgrades are as follows:
set -euo pipefail for better error handling
Input validation for all user entries
CTRL+C trap to prevent partial execution
Colorized output for better readability
Timeouts for network operations
More comprehensive full diagnostic
Better error messages
Modular functions for each test
Proper variable quoting
Input sanitization
Helpful comments
Clearer prompts
Pause after each operation
Better error feedback
More options (exit option)

Technical Improvements:
+++++++++++++++++++++++++
Uses ip command instead of deprecated ifconfig
Added timeouts to curl and ping
Filtered comments from resolv.conf
Colorized ip command output

