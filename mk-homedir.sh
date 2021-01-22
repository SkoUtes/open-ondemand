#!/bin/bash
mkdir -p $(ls -1 -d /var/log/ondemand-nginx/*/ | tr -d '/' | sed 's/\(varlogondemand-nginx\)//g' | xargs -L 1 echo /home/ | tr -d ' ')