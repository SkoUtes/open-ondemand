FROM centos:7
RUN yum update -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager openssh-server && \
    yum install -y wget 

# Set up SSSD and edit PAM files
RUN yum install -y sssd authconfig openldap oddjob-mkhomedir && \
    yum clean all
COPY sssd.conf /etc/sssd
RUN chown root:root /etc/sssd/sssd.conf
RUN chmod 600 /etc/sssd/sssd.conf
WORKDIR /etc/pam.d
RUN rm -f system-auth \
    rm -f password-auth
COPY PAM-system-auth ./system-auth
COPY PAM-password-auth ./password-auth
RUN chmod 744 system-auth
RUN chmod 744 password-auth
RUN authconfig --update --enablesssd --enablesssdauth --enablemkhomedir

# Install Ruby 2.5 and Node.js 10
RUN yum install -y centos-release-scl-rh
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum install -y rh-ruby25
RUN yum install -y rh-nodejs10

# Copy in the script and filesystem-map
COPY ruby-node.sh /root
COPY filesystem.txt /root
WORKDIR /root
RUN chmod +x ruby-node.sh

# Install OnDemand
RUN yum install -y https://yum.osc.edu/ondemand/1.7/ondemand-release-web-1.7-1.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all
RUN yum install ondemand-selinux -y

# isntall openid auth mod
RUN yum install -y httpd24-mod_auth_openidc
# config file for ood-portal-generator
ADD ood_portal.yml /etc/ood/config/ood_portal.yml
# Then build and install the new Apache configuration file with
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal
# FIX: Contains secret values
ADD auth_openidc-sample.conf /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

# Install Singularity
WORKDIR /usr/local
RUN sudo yum groupinstall -y 'Development Tools'
RUN sudo yum install -y openssl-devel libuuid-devel libseccomp-devel wget squashfs-tools cryptsetup
RUN wget https://dl.google.com/go/go1.13.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.13.linux-amd64.tar.gz
RUN rm go1.13.linux-amd64.tar.gz
RUN echo 'export GOPATH=${HOME}/go' >> ~/.bashrc && \
    echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc && \
    source ~/.bashrc
RUN go get -d github.com/sylabs/singularity
RUN export VERSION=3.6.0 && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz
WORKDIR /usr/local/singularity
RUN yum update -y && yum clean all
RUN ./mconfig && \
    make -C ./builddir && \
    sudo make -C ./builddir install
RUN yum install -y singularity

# Add cluster.yaml files
RUN mkdir /etc/ood/config/clusters.d
COPY frisco.yml /etc/ood/config/clusters.d/frisco.yml
WORKDIR /root

# Some security precautions
RUN chmod 600 /etc/ood/config/ood_portal.yml
RUN chgrp apache /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
RUN chmod 640 /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

ADD supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]