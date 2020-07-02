#!/bin/sh
echo "===================================="
echo "===================================="
echo "nodejs.sh is running now"
echo "===================================="
echo "===================================="
# Enable nodejs10
source scl_source enable rh-ruby25
source scl_source enable rh-nodejs10
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start rh-nodejs10: $status"
  exit $status
fi
unset BASH_ENV PROMPT_COMMAND ENV