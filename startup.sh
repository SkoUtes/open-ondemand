#!/bin/bash
touch/etc/ssh/ssh_known_hosts
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N ""
ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ""
ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -q -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ""
echo -n "open-ondemand""," ; printenv -0 KC_OOD_OPEN_ONDEMAND_SERVICE_HOST && cat /etc/ssh/ssh_host_dsa_key.pub >> /etc/ssh/ssh_known_hosts
echo -n "open-ondemand""," ; printenv -0 KC_OOD_OPEN_ONDEMAND_SERVICE_HOST && cat /etc/ssh/ssh_host_ecdsa_key.pub >> /etc/ssh/ssh_known_hosts
echo -n "open-ondemand""," ; printenv -0 KC_OOD_OPEN_ONDEMAND_SERVICE_HOST && cat /etc/ssh/ssh_host_ed25519_key.pub >> /etc/ssh/ssh_known_hosts
echo -n "open-ondemand""," ; printenv -0 KC_OOD_OPEN_ONDEMAND_SERVICE_HOST && cat /etc/ssh/ssh_host_rsa_key.pub >> /etc/ssh/ssh_known_hosts
ssh-keyscan $KC_OOD_OPEN_ONDEMAND_ISLAND_SERVICE_HOST >> /etc/ssh/ssh_known_hosts
sleep 120
supervisorctl stop sshd