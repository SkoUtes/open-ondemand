FROM centos:7
RUN yum update -y && \
    yum install -y centos-release-scl \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager && \
    yum install -y wget && \
    yum install -y https://yum.osc.edu/ondemand/1.7/ondemand-release-web-1.7-1.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all

# isntall openid auth mod
RUN yum install -y httpd24-mod_auth_openidc
# config file for ood-portal-generator
ADD ood_portal.yml /etc/ood/config/ood_portal.yml
# Then build and install the new Apache configuration file with
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal
# FIX: Contains secret values
ADD auth_openidc.conf /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

RUN chgrp apache /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
RUN chmod 640 /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

### #keycloak ===========
### WORKDIR /opt
### RUN wget https://downloads.jboss.org/keycloak/4.8.3.Final/keycloak-4.8.3.Final.tar.gz && \
###     tar xzf keycloak-4.8.3.Final.tar.gz && \
###     groupadd -r keycloak && \
###     useradd -m -d /var/lib/keycloak -s /sbin/nologin -r -g keycloak keycloak && \
###     chown keycloak: -R keycloak-4.8.3.Final
### 
### WORKDIR /opt/keycloak-4.8.3.Final
### RUN chmod 700 standalone
### RUN yum -y install java-1.8.0-openjdk-devel
### 
### # can I run the user duing the helm install?
### RUN ./bin/add-user-keycloak.sh --user admin --password KEYCLOAKPASS --realm master
### RUN ./bin/jboss-cli.sh 'embed-server,/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)'
### RUN ./bin/jboss-cli.sh 'embed-server,/socket-binding-group=standard-sockets/socket-binding=proxy-https:add(port=8443)'
### RUN ./bin/jboss-cli.sh 'embed-server,/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=proxy-https)'
### 
### # this line is specific to a plain httpd install.
### #ADD vhost.conf /etc/httpd/conf.d/vhost.conf
### 
### ADD ood-keycloak.conf /opt/rh/httpd24/root/etc/httpd/conf.d/ood-keycloak.conf
### #=====================
### 
ADD supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]