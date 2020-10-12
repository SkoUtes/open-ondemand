#!/bin/bash
ssh-keygen -A && chmod 600 /etc/ssh/* && \
rm /etc/ssh/ssh_host_dsa_key /etc/ssh/ssh_host_dsa_key.pub