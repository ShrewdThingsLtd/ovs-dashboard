#!/bin/bash

set +x

function flow_stats_to_influxdb {

	local flow_stats=$1
	
	echo "${flow_stats}" | \
		sed 's/ cookie=/\ncookie=/g' | \
		sed 's/,/|/g' | \
		sed 's/cookie=\(.*\)| duration=\([.0-9][.0-9]*\)s| table=\([.0-9][.0-9]*\)| n_packets=\([.0-9][.0-9]*\)| n_bytes=\([.0-9][.0-9]*\)| \(.*\) actions=\(.*\)/\6 cookie="\1",duration=\2,table=\3,n_packets=\4,n_bytes=\5,actions="\7"/g' | \
		grep 'cookie'
}

flow_stats=$(exec_tgt "\
ovs-ofctl -O OpenFlow14 dump-flows ${TGT_BR} | \
grep -v OFPST_FLOW; \
")

flow_stats_to_influxdb "${flow_stats}"

set +x
