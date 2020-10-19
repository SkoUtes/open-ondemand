#!/bin/bash
sleep 60
## Print out Pod IPs and node names into the /etc/hosts file
{ printenv -0 $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_ISLAND_SERVICE_HOST") && \
echo -n " " && echo "$INSTANCE_NAME" "-island" | tr -d ' ' ;} >> /etc/hosts
{ printenv -0 $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_CLUSTER_IP_SERVICE_HOST") && \
echo -n " " && echo "$INSTANCE_NAME" "-cluster-ip" | tr -d ' ' ;} >> /etc/hosts

## Create shosts.equiv file
touch /etc/shosts.equiv
# { echo "ood-island" ;} >> /etc/shosts.equiv
{ echo -n "$INSTANCE_NAME" "-island" | tr -d ' ' && echo " +" && \ 
printenv $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_ISLAND_SERVICE_HOST") ;} >> /etc/shosts.equiv
# { echo "open-ondemand" :} >> /etc/shosts.equiv
{ echo -n "$INSTANCE_NAME" "-cluster-ip" | tr -d ' ' && echo " +" && \ 
printenv $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_CLUSTER_IP_SERVICE_HOST") ;} >> /etc/shosts.equiv

## Print out ondemand container Service IP and public keys into ssh_known_hosts file
{ echo -n "$INSTANCE_NAME" "-island," | tr -d ' ' && echo -n " " && \
ssh-keyscan -t ecdsa 2> /dev/null \
$(printenv $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_ISLAND_SERVICE_HOST")) ;} >> /etc/ssh/ssh_known_hosts
{ echo -n "$INSTANCE_NAME" "-island," | tr -d ' ' && echo -n " " && \
ssh-keyscan -t ed25519 2> /dev/null \
$(printenv $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_ISLAND_SERVICE_HOST")) ;} >> /etc/ssh/ssh_known_hosts
{ echo -n "$INSTANCE_NAME" "-island," | tr -d ' ' && echo -n " " && \
ssh-keyscan -t rsa 2> /dev/null \
$(printenv $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_ISLAND_SERVICE_HOST")) ;} >> /etc/ssh/ssh_known_hosts

## Print out island container Service IP and public keys into ssh_known_hosts file
{ echo -n "$INSTANCE_NAME" "-cluster-ip," | tr -d ' ' && \
printenv -0 $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_CLUSTER_IP_SERVICE_HOST") && \
cat /etc/ssh/ssh_host_ecdsa_key.pub ;} >> /etc/ssh/ssh_known_hosts
{ echo -n "$INSTANCE_NAME" "-cluster-ip," | tr -d ' ' && \
printenv -0 $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_CLUSTER_IP_SERVICE_HOST") && \
cat /etc/ssh/ssh_host_ed25519_key.pub ;} >> /etc/ssh/ssh_known_hosts
{ echo -n "$INSTANCE_NAME" "-cluster-ip," | tr -d ' ' && \
printenv -0 $(echo -n "$INSTANCE_NAME" | tr [:lower:] [:upper:] | tr '-' '_' && echo -n "_CLUSTER_IP_SERVICE_HOST") && \
cat /etc/ssh/ssh_host_rsa_key.pub ;} >> /etc/ssh/ssh_known_hosts

## Disable SSHD
# sleep 60
# supervisorctl stop sshd