FROM philhawthorne/docker-influxdb-grafana
LABEL maintainer="Erez Buchnik <erez@shrewdthings.com>"

RUN ln -s /ovs/ovs_monitor.service /etc/systemd/system/ovs_monitor.service
COPY ./ovs/supervisord.conf /tmp/supervisord.conf
RUN cat /tmp/supervisord.conf >> /etc/supervisor/conf.d/supervisord.conf
