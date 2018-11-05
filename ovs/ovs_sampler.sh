#!/bin/bash

source /ovs/common.sh

function sample_ovs {

	source /ovs/port_stats.sh
}

influxdb_write_tgt ${TGT_BR} "$(sample_ovs)"
