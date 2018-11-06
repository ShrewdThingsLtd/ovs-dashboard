#!/bin/bash

source /ovs/common.sh

function sample_ovs_ports {

	source /ovs/port_stats.sh
}

influxdb_write_tgt $(urlencode ${TGT_BR}:ports) "$(sample_ovs_ports)"
