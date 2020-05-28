FROM centos:7
RUN yum update -y && \
    yum install centos-release-scl -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager && \
    yum install -y wget && \
    yum install -y https://yum.osc.edu/ondemand/1.6/ondemand-release-web-1.6-4.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all

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

ADD supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]