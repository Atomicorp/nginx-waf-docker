FROM centos:latest
MAINTAINER Support <support@atomicorp.com>

RUN yum -y update
RUN yum -y install wget  && yum clean all

RUN cd /root; NON_INT=1 wget -q -O - https://updates.atomicorp.com/installers/atomic |sh

COPY config/tortix-common.repo /etc/yum.repos.d/tortix-common.repo

RUN yum -y install nginx nginx-module-modsecurity http-tools roadsend-php-libs aum

# Special condition for aum
RUN ln -sf /var/asl/bin/aum.dynamic /var/asl/bin/aum

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
 && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf

# Enable WAF
RUN sed -i '1s@^@load_module modules/ngx_http_modsecurity_module.so;\n@' /etc/nginx/nginx.conf
RUN mkdir -p /var/asl/data/audit
RUN mkdir -p /etc/asl && touch /etc/asl/whitelist
COPY config/00_mod_security.conf /etc/nginx/conf.d/
COPY config/modsecurity.d /etc/httpd/modsecurity.d



# Install Forego
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego


ENV DOCKER_GEN_VERSION 0.7.3

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

COPY . /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam", "/etc/httpd/modsecurity.d"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]


