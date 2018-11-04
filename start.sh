#!/bin/bash

root_dir=$(pwd)
influxdb_dir="${root_dir}/influxdb"
grafana_dir="${root_dir}/grafana"
ovs_dashboard_container="ovs-dashboard"

mkdir -p "${influxdb_dir}"
mkdir -p "${grafana_dir}"

function container_clean {

	local container_name=$1

	docker kill "${container_name}"
	docker rm "${container_name}"
}

container_clean "${ovs_dashboard_container}" 2> /dev/null
docker run -d \
    --name "${ovs_dashboard_container}" \
    -p 3003:3003 \
    -v "${influxdb_dir}":/var/lib/influxdb \
    -v "${grafana_dir}":/var/lib/grafana \
    local/ovs-dashboard:latest

