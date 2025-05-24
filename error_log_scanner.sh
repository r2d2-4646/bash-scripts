can important logs for error messages
echo "=== Scanning for Errors in Logs ==="
important_logs=("/var/log/syslog" "/var/log/auth.log" "/var/log/kern.log" "/var/log/dpkg.log")

for log in "${important_logs[@]}"; do
	    if [ -f "$log" ]; then
		            echo "=== Errors in $log ==="
			            sudo grep -i -E 'error|fail|warning|critical' "$log" | tail -20
				            echo ""
					        fi
					done
