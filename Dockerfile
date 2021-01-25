FROM centos:7
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager openssh-server openssh-clients && \
    yum install -y wget 

# Install Ruby 2.5 and Node.js 10
RUN yum install -y centos-release-scl-rh
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum install -y rh-ruby25
RUN yum install -y rh-nodejs10

# Copy in the filesystem-map
COPY filesystem.txt /root
WORKDIR /root

# Install OnDemand
RUN yum install -y https://yum.osc.edu/ondemand/1.8/ondemand-release-web-1.8-1.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all
RUN yum install ondemand-selinux -y

# Install openid auth mod
RUN yum install -y httpd24-mod_auth_openidc
# Remove auth_openidc.conf
RUN rm -f /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

# Set up incron
RUN yum install incron -y
COPY mk-homedir.sh /var/log/ondemand-nginx/mk-homedir.sh
RUN chmod 0711 /var/log/ondemand-nginx/mk-homedir.sh
COPY incron-mkdir /etc/incron.d/incron-mkdir
COPY incron.allow /etc/incron.allow
RUN chmod 0700 /etc/incron.d
RUN useradd incron-user && chown incron-user /var/log/ondemand-nginx/mk-homedir.sh && \
    chgrp incron-user ondemand-nginx && chmod 0750 /var/log/ondemand-nginx

# Install Singularity
WORKDIR /usr/local
RUN sudo yum groupinstall -y 'Development Tools'
RUN sudo yum install -y openssl-devel libuuid-devel libseccomp-devel wget squashfs-tools cryptsetup
RUN wget https://dl.google.com/go/go1.14.7.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.14.7.linux-amd64.tar.gz
RUN rm go1.14.7.linux-amd64.tar.gz
RUN yum install golang -y
RUN export GOPATH=${HOME}/go&& \
    export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin && \
    source ~/.bashrc
RUN export VERSION=3.6.0 && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz
WORKDIR /usr/local/singularity
RUN yum update -y && yum clean all
RUN ./mconfig && \
    make -C ./builddir && \
    sudo make -C ./builddir install
RUN yum install -y singularity

# Configure shel application
RUN mkdir /etc/ood/config/clusters.d
RUN mkdir /opt/ood/linuxhost_adapter
WORKDIR /opt/ood/linuxhost_adapter
RUN singularity pull docker://centos:7.6.1810
RUN mv centos_7.6.1810.sif centos_7.6.sif
RUN yum update -y
RUN mkdir /etc/ood/config/apps && mkdir /etc/ood/config/apps/shell
COPY env /etc/ood/config/apps/shell/env
COPY startup.sh /opt/rh/httpd24/root/etc/httpd/conf.d/startup.sh
WORKDIR /root

# Some security precautions
RUN chmod 0700 /opt/rh/httpd24/root/etc/httpd/conf.d/startup.sh

ADD supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]