#!/bin/sh
echo "===================================="
echo "===================================="
echo "rh-ruby25 and nodejs10 are now running"
echo "===================================="
echo "===================================="
# Enable nodejs10
scl enable ondemand bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start ruby and node.js: $status"
  exit $status
fi