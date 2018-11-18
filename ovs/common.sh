#!/bin/bash

urlencode() {
	# urlencode <string>
	old_lc_collate=$LC_COLLATE
	LC_COLLATE=C

	local length="${#1}"
	for (( i = 0; i < length; i++ )); do
		local c="${1:i:1}"
		case $c in
		[a-zA-Z0-9.~_-])	printf "$c" ;;
		*)					printf '%%%02X' "'$c" ;;
		esac
	done

	LC_COLLATE=$old_lc_collate
}

urldecode() {
	# urldecode <string>

	local url_encoded="${1//+/ }"
	printf '%b' "${url_encoded//%/\\x}"
}

function exec_remote {

	local remote_cmd=$1
	local remote_ip=$2
	local remote_user=$3
	local remote_pass=$4
	local timestamp=$(date +"%Y.%m.%d %H:%M:%S")
	
	echo "$(sshpass -p ${remote_pass} ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${remote_user}@${remote_ip} ${remote_cmd})"
}

function exec_tgt {

	local remote_cmd=$1
	
	echo $(exec_remote "${remote_cmd}" "${TGT_IP}" "${TGT_USER}" "${TGT_PASS}")
}

function influxdb_write {

	local db_name=$1
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
		curl \
			-XPOST \
			"${db_proto}://${db_ip}:${db_port}/query" \
			--data-urlencode \
			"q=CREATE DATABASE ${db_name}"
	else
		set +x
		curl \
			-XPOST \
			"${db_proto}://${db_ip}:${db_port}/write?db=${db_name}" \
			--data-binary \
			"${points_list}"
		set +x
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
