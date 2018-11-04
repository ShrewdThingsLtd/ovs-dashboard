FROM philhawthorne/docker-influxdb-grafana
LABEL maintainer="Erez Buchnik <erez@shrewdthings.com>"

RUN ln -s /ovs/ovs_monitor.service /etc/systemd/system/ovs_monitor.service
