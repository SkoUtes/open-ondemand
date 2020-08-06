FROM centos:7
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager && \
    yum install -y wget 

RUN yum install -y sssd authconfig openldap && \
    yum clean all
COPY sssd.conf /etc/sssd
RUN chown root:root /etc/sssd/sssd.conf
RUN chmod 600 /etc/sssd/sssd.conf
RUN authconfig --update --enablesssd --enablesssdauth --enableldap --enableldapauth --enablekrb5 --enablemkhomedir

# Install Ruby 2.5 and Node.js 10
RUN yum install -y centos-release-scl-rh
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum install -y rh-ruby25
RUN yum install -y rh-nodejs10

# Copy in the wrapper scripts
COPY ruby-node.sh /root
WORKDIR /root
RUN chmod +x ruby-node.sh

# Install OnDemand
RUN yum install -y https://yum.osc.edu/ondemand/1.7/ondemand-release-web-1.7-1.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all
RUN sudo yum install ondemand-selinux -y

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