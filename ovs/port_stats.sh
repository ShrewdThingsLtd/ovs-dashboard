#!/bin/bash

set +x

function port_stats_to_influxdb {

	local port_stats=$1
	
	echo "${port_stats}" | \
		sed 's/ //g' | \
		sed 's/port\([0-9][0-9]*\):/\nport\1 /g' | \
		sed 's/portLOCAL:/\nportLOCAL /g' | \
		sed 's/txpkts=/,txpkts=/g' | \
		sed 's/duration=\([.0-9][.0-9]*\)s/,duration=\1/g' | \
		grep 'port'
}

port_stats=$(exec_tgt "\
ovs-ofctl -O OpenFlow14 dump-ports ${TGT_BR} | \
grep -v OFPST_PORT; \
")

port_stats_to_influxdb "${port_stats}"

set +x
