heck disk space used by logs
echo "=== Log Disk Usage ==="
sudo du -sh /var/log/
echo -e "\nLargest log files:"
sudo find /var/log/ -type f -exec du -h {} + | sort -rh | head -10
