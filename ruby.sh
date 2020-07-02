#!/bin/sh
echo "===================================="
echo "===================================="
echo "ruby.sh is running now"
echo "===================================="
echo "===================================="
# Enable nodejs10
source scl_source enable rh-ruby25
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start rh-ruby25: $status"
  exit $status
fi
unset BASH_ENV PROMPT_COMMAND ENV