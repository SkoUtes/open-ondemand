#!/bin/sh
echo "===================================="
echo "===================================="
echo "ruby.sh is running now"
echo "===================================="
echo "===================================="
# Enable nodejs10
scl enable rh-ruby25 bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start rh-ruby25: $status"
  exit $status
fi