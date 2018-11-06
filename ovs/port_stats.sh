#!/bin/bash

set +x

function port_stats_to_influxdb {

	local port_stats=$1
	
	echo "${port_stats}" | \
		sed 's/ //g' | \
		sed 's/port\([0-9][0-9]*\):/\nport\1 /g' | \
		sed 's/portLOCAL:/\nportLOCAL /g' | \
		sed 's/rxpkts=\([.0-9][.0-9]*\),bytes=\([.0-9][.0-9]*\),drop=\([.0-9][.0-9]*\),errs=\([.0-9][.0-9]*\),frame=\([.0-9][.0-9]*\),over=\([.0-9][.0-9]*\),crc=\([.0-9][.0-9]*\)/rxpkts=\1,rxbytes=\2,rxdrop=\3,rxerrs=\4,rxframe=\5,rxover=\6,rxcrc=\7/g' | \
		sed 's/txpkts=\([.0-9][.0-9]*\),bytes=\([.0-9][.0-9]*\),drop=\([.0-9][.0-9]*\),errs=\([.0-9][.0-9]*\),coll=\([.0-9][.0-9]*\)/,txpkts=\1,txbytes=\2,txdrop=\3,txerrs=\4,txcoll=\5/g' | \
		sed 's/duration=\([.0-9][.0-9]*\)s/,duration=\1/g' | \
		grep 'port'
}

port_stats=$(exec_tgt "\
ovs-ofctl -O OpenFlow14 dump-ports ${TGT_BR} | \
grep -v OFPST_PORT; \
")

port_stats_to_influxdb "${port_stats}"

set +x
