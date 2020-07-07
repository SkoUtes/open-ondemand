#!/bin/sh
echo "===================================="
echo "===================================="
echo "rh-ruby25 and nodejs10 are now running"
echo "===================================="
echo "===================================="
# Enable nodejs10
scl enable rh-ruby25 bash
scl enable rh-nodejs10 bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start ruby and node.js: $status"
  exit $status
fi
unset BASH_ENV PROMPT_COMMAND ENV
supervisorctl start apache