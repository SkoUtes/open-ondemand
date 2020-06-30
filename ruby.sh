#!/bin/sh

# Start up Ruby and nodejs
scl enable rh-ruby25 bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start rh-ruby25: $status"
  exit $status
fi