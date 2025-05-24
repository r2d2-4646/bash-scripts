tch logs in real-time
echo "=== Real-time Log Monitoring ==="
echo "1. System messages (syslog)"
echo "2. Authentication logs"
echo "3. Kernel logs"
echo "Enter your choice (1-3): "
read choice

case $choice in
	    1) sudo tail -f /var/log/syslog ;;
	        2) sudo tail -f /var/log/auth.log ;;
		    3) sudo tail -f /var/log/kern.log ;;
		        *) echo "Invalid choice!" ;;
		esac
