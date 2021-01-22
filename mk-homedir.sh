#!/bin/bash
mkdir -p $(ls -1 -d */ | tr -d '/' | xargs -L 1 echo /home/ | tr -d ' ')
ls -d */ | tr -d '/' | sed p | paste - - | xargs -t -L 1 chown