#!/bin/sh
echo "===================================="
echo "===================================="
echo "rh-ruby25 and nodejs10 are now running"
echo "===================================="
echo "===================================="
# Enable nodejs10
set ENV BASH_ENV="/root/scripts/ruby-node.sh" \
    ENV="/root/scripts/ruby-node.sh" \
    PROMPT_COMMAND=". /root/scripts/ruby-node.sh"
scl enable rh-ruby25 rh-nodejs10 bash
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start ruby and node.js: $status"
  exit $status
fi
unset BASH_ENV PROMPT_COMMAND ENV
sleep 5
. /opt/rh/httpd24/service-environment
    for sclname in $HTTPD24_HTTPD_SCLS_ENABLED ; do
        . /opt/rh/$sclname/enable
        export X_SCLS="$X_SCLS $sclname"
    done

    exec /opt/rh/httpd24/root/usr/sbin/httpd "$@"