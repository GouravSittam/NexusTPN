#!/bin/bash
# Simple custom Nagios check example
# returns 0 for OK, 1 for WARNING, 2 for CRITICAL

THRESHOLD_WARN=80
THRESHOLD_CRIT=90

USAGE=$(df -h / | awk 'NR==2 {gsub("%","",$5); print $5}')

if [ "$USAGE" -ge "$THRESHOLD_CRIT" ]; then
  echo "CRITICAL - root usage ${USAGE}%"
  exit 2
elif [ "$USAGE" -ge "$THRESHOLD_WARN" ]; then
  echo "WARNING - root usage ${USAGE}%"
  exit 1
else
  echo "OK - root usage ${USAGE}%"
  exit 0
fi
