FROM centos:centos6

MAINTAINER Hiroaki Sano <hiroaki.sano.9stories@gmail.com>

# Basic packages
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
RUN yum install -y passwd
RUN yum install -y sudo
RUN yum install -y git
RUN yum install -y wget
RUN yum install -y openssl
RUN yum install -y openssh
RUN yum install -y openssh-server
RUN yum install -y openssh-clients

# Create user
RUN useradd pair
RUN echo "pair" | passwd pair --stdin
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN echo "pair ALL=(ALL) ALL" >> /etc/sudoers.d/hiroakis

# Redis
RUN yum install -y redis

# RabbitMQ
RUN yum install -y erlang
RUN rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
RUN rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/v3.1.4/rabbitmq-server-3.1.4-1.noarch.rpm
## Fetch certs for user
RUN git clone git://github.com/joemiller/joemiller.me-intro-to-sensu.git
RUN cd joemiller.me-intro-to-sensu/; ./ssl_certs.sh clean && ./ssl_certs.sh generate
RUN mkdir /etc/rabbitmq/ssl
RUN cp /joemiller.me-intro-to-sensu/server_cert.pem /etc/rabbitmq/ssl/cert.pem
RUN cp /joemiller.me-intro-to-sensu/server_key.pem /etc/rabbitmq/ssl/key.pem
RUN cp /joemiller.me-intro-to-sensu/testca/cacert.pem /etc/rabbitmq/ssl/
ADD http://localhost:4567/rabbit_config /etc/rabbitmq/rabbitmq.config
RUN rabbitmq-plugins enable rabbitmq_management

# Sensu server
ADD http://localhost:4567/sensu_repo /etc/yum.repos.d/sensu.repo
RUN yum install -y sensu
ADD http://localhost:4567/sensu_config_json /etc/sensu/config.json
RUN mkdir -p /etc/sensu/ssl
RUN cp /joemiller.me-intro-to-sensu/client_cert.pem /etc/sensu/ssl/cert.pem
RUN cp /joemiller.me-intro-to-sensu/client_key.pem /etc/sensu/ssl/key.pem

# uchiwa
RUN yum install -y uchiwa
ADD http://localhost:4567/uchiwa_json /etc/sensu/uchiwa.json

# supervisord
RUN wget http://peak.telecommunity.com/dist/ez_setup.py;python ez_setup.py
RUN easy_install supervisor
ADD http://localhost:4567/supervisord_conf /etc/supervisord.conf

RUN /etc/init.d/sshd start
RUN /etc/init.d/sshd stop

EXPOSE 22 3000 4567 5671 15672

CMD ["/usr/bin/supervisord"]