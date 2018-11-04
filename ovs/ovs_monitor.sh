#!/bin/bash

env_file="/tmp/runtime_env.conf"

while [ ! -f "${env_file}" ]
do
	sleep 2
done
source "${env_file}"
rm -f "${env_file}"

while true
do
	TGT_IP=${OVS_TGT_IP} \
	TGT_USER=${OVS_TGT_USER} \
	TGT_PASS=${OVS_TGT_PASS} \
		/ovs/ovs_sampler.sh
	sleep "${OVS_SAMPLER_INTERVAL_SEC}"
done
