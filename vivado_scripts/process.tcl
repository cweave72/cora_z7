namespace eval process {

proc create_proj {buildpath part block_design srcs ip constr {project_name "project_1"}} {
    puts "Creating project:"
    puts "   buildpath: $buildpath"
    puts "   part: $part"
    puts "   project name: $project_name.xpr"
    puts "   block_design: $block_design"

    create_project $project_name $buildpath -part $part -force
    set_property target_language VHDL [current_project]

    source -quiet $block_design
    puts "   design name: $design_name"

    make_wrapper -files [get_files $buildpath/$project_name.srcs/sources_1/bd/$design_name/$design_name.bd] -top -force
    import_files -force -norecurse $buildpath/$project_name.srcs/sources_1/bd/$design_name/hdl/${design_name}_wrapper.vhd

    if { [llength $srcs] != 0 } {
        foreach f $srcs {
            add_files -norecurse $f
        }
    }

    if { [llength $ip] != 0 } {
        foreach f $ip {
            read_ip $f
        }
    }

    if { [llength $constr] != 0 } {
        foreach f $constr {
            add_files -fileset constrs_1 -norecurse $f 
        }
        report_ip_status
    }
}

proc run_synth {name {jobs 4}} {
    puts "Running synth ..."
    reset_run $name
    launch_runs $name -jobs $jobs
    wait_on_run $name
}

proc run_par {buildpath name {jobs 4}} {
    puts "Running par ..."
    reset_run $name
    launch_runs $name -to_step write_bitstream -jobs $jobs
    wait_on_run $name
    open_run $name

    puts "Generating utilization report..."
    report_utilization -file [file join $buildpath "utilization.rpt"]
    puts "Generating timing report..."
    report_timing -file [file join $buildpath "timing.rpt"]

    puts "Exporting hardware definition..."
    file copy -force $buildpath/project_1.runs/$name/System_top.sysdef $buildpath/System_top.hdf
}

}
