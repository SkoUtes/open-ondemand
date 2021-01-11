#!/bin/bash
scl enable ondemand /var/www/ood/apps/sys/shell/bin/setup
mkdir /etc/ood/config/apps /etc/ood/config/apps/shell
touch /etc/ood/config/apps /etc/ood/config/apps/shell/env
cat <<EOF > /etc/ood/config/apps/shell/env
OOD_SSHHOST_ALLOWLIST=""
OOD_SHELL_ORIGIN_CHECK="off"
EOF
sleep 15
chgrp apache /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
chmod 640 /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
sudo /opt/ood/ood-portal-generator/sbin/update_ood_portal
supervisorctl restart apache