#!/bin/bash

docker run -d \
    --name ovs-dashboard \
    -p 3003:3003 \
    -v ./influxdb:/var/lib/influxdb \
    -v ./grafana:/var/lib/grafana \
    local/ovs-dashboard:latest
