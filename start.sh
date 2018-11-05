#!/bin/bash

TGT_IP=${1:-172.16.10.152}
TGT_USER=${2:-root}
TGT_BR=${3:-vpn.ens1}
SAMPLER_INTERVAL_SEC=${4:-1}

echo
echo -n "Password for user ${TGT_USER} on target ${TGT_IP}:"
echo
read -s TGT_PASS


root_dir=$(pwd)
influxdb_dir="${root_dir}/influxdb"
grafana_dir="${root_dir}/grafana"
ovs_dashboard_container="ovs-dashboard"
env_file="/tmp/ovs_monitor.env"

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
	--ipc=host \
	--privileged=true \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-p 3003:3003 \
	-p 8086:8086 \
	-v "${influxdb_dir}":/var/lib/influxdb \
	-v "${grafana_dir}":/var/lib/grafana \
	-v "${root_dir}/ovs":/ovs:ro \
	local/ovs-dashboard:latest

printf '
OVS_TGT_IP=%s\n
OVS_TGT_USER=%s\n
OVS_TGT_PASS=%s\n
OVS_TGT_BR=%s\n
OVS_SAMPLER_INTERVAL_SEC=%s\n
' \
${TGT_IP} ${TGT_USER} ${TGT_PASS} ${TGT_BR} ${SAMPLER_INTERVAL_SEC} \
> "${env_file}"
docker cp "${env_file}" "${ovs_dashboard_container}:${env_file}"
rm -f "${env_file}"
