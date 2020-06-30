#!/bin/bash

# Sleep for a minute
sleep 60

# Start up Ruby
supervisorctl scl enable rh-ruby25 bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Ruby 2.5: $status"
  exit $status
elif [[ $status = 0 ]]; then
	echo "rh-ruby25 enabled"
	exit $status
fi

# Start up Node.js
supervisorctl scl enable rh-nodejs10 bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start Node.js 10: $status"
  exit $status
elif [[ $status = 0 ]]; then
	echo "rh-nodejs10 enabled"
	exit $status
fi