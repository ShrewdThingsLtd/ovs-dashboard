FROM philhawthorne/docker-influxdb-grafana
LABEL maintainer="Erez Buchnik <erez@shrewdthings.com>"

RUN apt-get -y update
RUN apt-get -y install sshpass

COPY ./ovs/supervisord.conf /tmp/supervisord.conf
RUN cat /tmp/supervisord.conf >> /etc/supervisor/conf.d/supervisord.conf
RUN rm /tmp/supervisord.conf
