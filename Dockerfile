from centos:7
RUN yum update -y && \
    yum install centos-release-scl -y && \
    yum install -y epel-release && \
    yum install -y supervisor centos-release-scl subscription-manager && \
    yum install -y wget

# Install Ruby 2.5 and Node.js 10
RUN yum install -y centos-release-scl-rh
RUN yum-config-manager --enable rhel-server-rhscl-7-rpms
RUN yum install -y rh-ruby25
RUN yum install -y rh-nodejs10

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



RUN yum install -y centos-release-scl && \
    INSTALL_PKGS="rh-ruby24 rh-ruby24-ruby-devel rh-ruby24-rubygem-rake rh-ruby24-rubygem-bundler" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && rpm -V $INSTALL_PKGS && \
    yum -y clean all --enablerepo='*'


# Copy in the wrapper scripts
RUN mkdir /root/scripts
COPY ruby-node.sh /root/scripts
WORKDIR /root/scripts
RUN chmod +x ruby-node.sh
ENV BASH_ENV="/root/scripts" \
    ENV="/root/scripts/ruby-node.sh" \
    PROMPT_COMMAND=". /root/scripts/ruby-node.sh"

RUN yum install -y https://yum.osc.edu/ondemand/1.6/ondemand-release-web-1.6-4.noarch.rpm && \
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