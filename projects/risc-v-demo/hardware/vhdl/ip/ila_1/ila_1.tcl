package require yaml
set part "xc7z010clg400-1"

set cwd [pwd]

set config [yaml::yaml2dict -file $cwd/config.yaml]

set name [dict get $config name]
set num_probes [dict get $config num_probes]
set all_probe_same_mu [dict get $config all_probe_same_mu]
set probe_match_count [dict get $config probe_match_count]
set capture_depth [dict get $config capture_depth]

create_project -in_memory -part $part
set_property target_language VHDL [current_project]

#create_ip -name ila -vendor xilinx.com -library ip -version 6.2 \
	-module_name $name -dir $cwd
create_ip -name ila -vendor xilinx.com -library ip \
	-module_name $name -dir $cwd

set props [list]
lappend props CONFIG.C_NUM_OF_PROBES $num_probes
lappend props CONFIG.Component_Name "$name"
lappend props CONFIG.C_DATA_DEPTH $capture_depth
lappend props CONFIG.C_EN_STRG_QUAL {0}
lappend props CONFIG.ALL_PROBE_SAME_MU_CNT {2}
lappend props CONFIG.C_ENABLE_ILA_AXI_MON {false}
lappend props CONFIG.C_MONITOR_TYPE {Native}
for {set i 0} {$i < $num_probes} {incr i} {
	lappend props CONFIG.C_PROBE${i}_WIDTH [dict get $config probe_$i width]
	lappend props CONFIG.C_PROBE${i}_MU_CNT $probe_match_count
}

#puts $props

set_property -dict $props [get_ips $name]
generate_target {instantiation_template} [get_ips]
