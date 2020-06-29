from centos/systemd
RUN yum update -y && \
    yum install centos-release-scl -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager && \
    yum install -y wget && \
    yum install -y https://yum.osc.edu/ondemand/1.6/ondemand-release-web-1.6-4.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all

# Install Ruby 2.5 and Node.js 10
RUN yum install centos-release-scl-rh
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum install rh-ruby25
RUN systemctl enable rh-ruby25 bash
RUN yum install rh-nodejs10
RUN systemctl enable rh-nodejs10 bash

# set up systemd
RUN yum -y install systemd; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;
# isntall openid auth mod
RUN yum install -y httpd24-mod_auth_openidc
# config file for ood-portal-generator
ADD ood_portal.yml /etc/ood/config/ood_portal.yml
# Then build and install the new Apache configuration file with
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal
# FIX: Contains secret values
ADD auth_openidc-sample.conf /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

RUN chgrp apache /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
RUN chmod 640 /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

# Set up Let's Encrypt inside of the container

RUN yum install -y httpd && \
    systemctl start httpd && \
    systemctl enable httpd && \
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    touch /var/www/ood/index.html

RUN cat << EOF > /var/www/ood/index.html


ADD supervisord.conf /etc/supervisord.conf
CMD ["/usr/sbin/init", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]