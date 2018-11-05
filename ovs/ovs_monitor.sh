#!/bin/bash

env_file="/tmp/ovs_monitor.env"

while [ ! -f "${env_file}" ]
do
	sleep 2
done
source "${env_file}"
#rm -f "${env_file}"

source /ovs/common.sh

printf '
\n\n
=====================\n
[%s] OVS-MONITOR: Target %s, user %s\n
=====================\n
' \
"$(date +'%Y.%m.%d %H:%M:%S')" "${OVS_TGT_IP}" "${OVS_TGT_USER}" \
>>"${log_file}"

influxdb_init_tgt "${OVS_TGT_BR}"
while true
do
	TGT_IP="${OVS_TGT_IP}" \
	TGT_USER="${OVS_TGT_USER}" \
	TGT_PASS="${OVS_TGT_PASS}" \
	TGT_BR="${OVS_TGT_BR}" \
		/ovs/ovs_sampler.sh \
		>>"${log_file}" 2>&1
	sleep "${OVS_SAMPLER_INTERVAL_SEC}"
done
