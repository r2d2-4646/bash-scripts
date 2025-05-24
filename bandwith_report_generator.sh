#!/bin/bash

# Check for vnstat
if ! command -v vnstat &> /dev/null; then
  echo "vnstat not found. Install it? (y/n): "
  read install
  if [[ "$install" =~ ^[Yy]$ ]]; then
    sudo apt update && sudo apt install -y vnstat
  else
    echo "vnstat is required. Exiting."
    exit 1
  fi
fi

# Interface selection
interfaces=($(vnstat --iflist | sed 's/Available interfaces: //g' | tr ' ' '\n'))
echo "=== Bandwidth Report Generator ==="
echo "Select an interface:"
select iface in "${interfaces[@]}" "Quit"; do
  if [[ "$REPLY" -ge 1 && "$REPLY" -le "${#interfaces[@]}" ]]; then
    break
  elif [[ "$REPLY" -eq $((${#interfaces[@]}+1)) ]]; then
    echo "Exiting."
    exit 0
  else
    echo "Invalid selection."
  fi
done

# Output directory and file
LOG_DIR="$HOME/network_reports"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
LOG_FILE="$LOG_DIR/bandwidth_report_${iface}_$TIMESTAMP.txt"
CSV_FILE="$LOG_DIR/bandwidth_report_${iface}_$TIMESTAMP.csv"

# Generate Report
echo "Generating report for interface: $iface"
{
  echo "=== Bandwidth Report: $iface ==="
  echo "Date: $(date)"
  echo ""
  vnstat -i "$iface"
  echo ""
  echo "Top Talkers (current snapshot):"
  echo "(Use 'nethogs' or 'iftop' for real-time IP breakdown if needed)"
} > "$LOG_FILE"

# Optional CSV export (vnstat --json is also available)
vnstat -i "$iface" --dumpdb | grep -E '^d;' | awk -F\; -v OFS=',' \
  '{print $3"-"$4"-"$5, $6, $7}' >> "$CSV_FILE"
# Columns: Date, RX MB, TX MB

echo "Report saved to:"
echo "  $LOG_FILE"
echo "  $CSV_FILE (CSV format)"

# Optionally view in less
echo -n "Open text report now? (y/n): "
read view
[[ "$view" =~ ^[Yy]$ ]] && less "$LOG_FILE"

