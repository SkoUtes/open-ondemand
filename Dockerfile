FROM centos:7
RUN yum update -y && \
    yum install centos-release-scl -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager && \
    yum install -y wget \
    yum install -y make

# Enable and install software collections for ruby and node

ENV RUBY_MAJOR_VERSION=2 \
    RUBY_MINOR_VERSION=5

ENV RUBY_VERSION="${RUBY_MAJOR_VERSION}.${RUBY_MINOR_VERSION}" \
    RUBY_SCL_NAME_VERSION="${RUBY_MAJOR_VERSION}${RUBY_MINOR_VERSION}"

ENV RUBY_SCL="rh-ruby${RUBY_SCL_NAME_VERSION}" \
    IMAGE_NAME="centos/ruby-${RUBY_SCL_NAME_VERSION}-centos7"

RUN yum install -y centos-release-scl-rh && \
    INSTALL_PKGS=" \
${RUBY_SCL} \
${RUBY_SCL}-ruby-devel \
${RUBY_SCL}-rubygem-rake \
${RUBY_SCL}-rubygem-bundler \
" && \
    yum install -y --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
    yum -y clean all --enablerepo='*' && \
    rpm -V ${INSTALL_PKGS}

ENV NODEJS_VERSION=10 \
    NPM_RUN=start \
    NAME=nodejs \
    NPM_CONFIG_PREFIX=$HOME/.npm-global

RUN yum install -y centos-release-scl-rh && \
    ( [ "rh-${NAME}${NODEJS_VERSION}" != "${NODEJS_SCL}" ] && yum remove -y ${NODEJS_SCL}\* || : ) && \
    INSTALL_PKGS="rh-nodejs${NODEJS_VERSION} rh-nodejs${NODEJS_VERSION}-npm rh-nodejs${NODEJS_VERSION}-nodejs-nodemon nss_wrapper" && \
    ln -s /usr/lib/node_modules/nodemon/bin/nodemon.js /usr/bin/nodemon && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'

RUN yum install -y https://yum.osc.edu/ondemand/1.7/ondemand-release-web-1.7-1.noarch.rpm && \
    yum install -y ondemand && \
    yum clean all

# End of software collections (scl) install

# install openid auth mod
RUN yum install -y httpd24-mod_auth_openidc
# config file for ood-portal-generator
ADD ood_portal.yml /etc/ood/config/ood_portal.yml
# Then build and install the new Apache configuration file with
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal
# FIX: Contains secret values
ADD auth_openidc-sample.conf /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

RUN chgrp apache /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf
RUN chmod 640 /opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf

# Copy in the wrapper script
RUN mkdir /root/scripts
COPY ruby-node.sh /root/scripts
WORKDIR /root/scripts
RUN chmod +x ruby-node.sh

# Edit httpd-scl-wrapper script
WORKDIR /opt/rh/httpd24/root/usr/sbin
RUN sed '1,13d' httpd-scl-wrapper
RUN echo $'[httpd-scl-wrapper] \n\
#!/bin/sh \n\
scl enable rh-ruby25 rh-nodejs10 bash \n\
# We have to re-enable SCL environment, because /sbin/service \n\
# clears almost all environment variables. \n\
# Since X_SCLS is cleared as well, we lose information about other \n\
# collections enabled. \n\
. /opt/rh/httpd24/service-environment \n\
for sclname in $HTTPD24_HTTPD_SCLS_ENABLED ; do \n\
    . /opt/rh/$sclname/enable \n\
    export X_SCLS="$X_SCLS $sclname" \n\
done \n\
 \n\
exec /opt/rh/httpd24/root/usr/sbin/httpd "$@"'

ADD supervisord.conf /etc/supervisord.conf
CMD ["/bin/sh", "-c", "/usr/bin/supervisord -c /etc/supervisord.conf"]