#!/bin/bash

set +x

log_file="/tmp/ovs_monitor.log"

function exec_remote {

	local remote_cmd=$1
	local remote_ip=$2
	local remote_user=$3
	local remote_pass=$4
	local timestamp=$(date +"%Y.%m.%d %H:%M:%S")
	
	#echo "[${timestamp}] sshpass -p ${remote_pass} ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${remote_user}@${remote_ip} ${remote_cmd}" >>${log_file} 2>&1
	echo "$(sshpass -p ${remote_pass} ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${remote_user}@${remote_ip} ${remote_cmd})"
}

function exec_tgt {

	local remote_cmd=$1
	
	echo $(exec_remote "${remote_cmd}" "${TGT_IP}" "${TGT_USER}" "${TGT_PASS}")
}

function port_stats_to_influxdb {

	local port_stats=$1
	
	echo "${port_stats}" | \
		sed 's/ //g' | \
		sed 's/port\([0-9][0-9]*\):/\nport\1 /g' | \
		sed 's/portLOCAL:/\nportLOCAL /g' | \
		sed 's/txpkts=/,txpkts=/g' | \
		sed 's/duration=/,duration=/g'
}

port_stats=$(exec_tgt "\
ovs-ofctl -O OpenFlow14 dump-ports vpn.ens1 | \
grep -v OFPST_PORT; \
")

port_stats_to_influxdb "${port_stats}"

set +x
