#!/bin/sh
echo "===================================="
echo "===================================="
echo "nodejs.sh is running now"
echo "===================================="
echo "===================================="
# Enable nodejs10
scl enable rh-nodejs10 bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start rh-nodejs10: $status"
  exit $status
fi