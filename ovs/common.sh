#!/bin/bash

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

function influxdb_normalize {

	local influxdb_name=$1
	
	sed "s/\./_/g" <<< "${influxdb_name}"
}

function influxdb_write {

	local db_name=$(influxdb_normalize $1)
	local points_list=$2
	local db_proto=$3
	local db_ip=$4
	local db_port=$5
	local db_user=$6
	local db_pass=$7
	
	if [[ "${points_list}" == "!" ]]
	then
		while [[ $(netstat -nap | grep -w ${db_port}) == "" ]]
		do
			sleep 2
		done
		echo \
		"curl \
			-XPOST \
			\"${db_proto}://${db_ip}:${db_port}/query\" \
			--data-urlencode \
			\"q=CREATE DATABASE ${db_name}\"" \
			>>"${log_file}" 2>&1
		curl \
			-XPOST \
			"${db_proto}://${db_ip}:${db_port}/query" \
			--data-urlencode \
			"q=CREATE DATABASE ${db_name}" \
			>>"${log_file}" 2>&1
	else
		curl \
			-XPOST \
			"${db_proto}://${db_ip}:${db_port}/write?db=${db_name}" \
			--data-binary \
			"${points_list}"
	fi
}

function influxdb_init_tgt {

	local db_name=$1

	influxdb_write \
		"${db_name}" \
		"!" \
		"http" \
		"127.0.0.1" \
		"8086" \
		"root" \
		"root"
}

function influxdb_write_tgt {

	local db_name=$1
	local points_list="$2"

	influxdb_write \
		"${db_name}" \
		"${points_list}" \
		"http" \
		"127.0.0.1" \
		"8086" \
		"root" \
		"root"
}
