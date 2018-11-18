#!/bin/bash

source /ovs/common.sh

function sample_ovs_ports {

	source /ovs/port_stats.sh
}

function sample_ovs_flows {

	source /ovs/flow_stats.sh
}

influxdb_write_tgt $(urlencode ${TGT_BR}:ports) "$(sample_ovs_ports)"
influxdb_write_tgt $(urlencode ${TGT_BR}:flows) "$(sample_ovs_flows)"
