#!/bin/bash

# Sleep for a minute
sleep 60

# Start up Ruby
supervisorctl enable rh-ruby25
if [ $status -ne 0 ]; then
  echo "Failed to start Ruby 2.5: $status"
  exit $status
fi

# Start up Node.js
supervisorctl enable rh-nodejs10
if [ $status -ne 0 ]; then
  echo "Failed to start Node.js 10: $status"
  exit $status
fi