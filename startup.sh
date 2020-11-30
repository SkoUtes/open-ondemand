#!/bin/bash
scl enable ondemand /var/www/ood/apps/sys/shell/bin/setup
mkdir /etc/ood/config/apps /etc/ood/config/apps/shell
touch /etc/ood/config/apps /etc/ood/config/apps/shell/env
cat <<EOF > /etc/ood/config/apps /etc/ood/config/apps/shell/env
OOD_SSHHOST_ALLOWLIST=""
OOD_SHELL_ORIGIN_CHECK="off"
EOF