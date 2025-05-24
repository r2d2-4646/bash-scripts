#!/bin/bash

echo "=== Log Disk Usage Summary ==="
du -sh /var/log/

echo -e "\n=== Top 10 Largest Log Files ==="

find /var/log/ -type f -exec du -b {} + 2>/dev/null | sort -rn | head -10 | \
    awk '{
        size=$1;
        "numfmt --to=iec-i --suffix=B " size | getline hsize;
        print hsize, $2
    }'

