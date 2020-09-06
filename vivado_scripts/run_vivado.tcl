# Get path to this script directory.
proc getDirname {} {
    set scriptFile [file normalize [info script]]
    set scriptDir [file dirname $scriptFile]
    return $scriptDir
}

set currpath [getDirname]

source $currpath/process.tcl
source $env(PROJ_DIR)/params.tcl
set buildpath $env(BUILD_DIR)

# Arguments accepted:
# all
# proj
# synth
# par

set jobs [list]

if {$argc == 1} {
    if {$argv == "all"} {
        if { [file exists "$buildpath/project_1.xpr"] == 1 } {
            puts "Project already exists, skipping..."
            set jobs {"synth" "par"}
        } else {
            set jobs {"proj" "synth" "par"}
        }
    } elseif {$argv == "proj"} {
        lappend jobs "proj"
    } elseif {$argv == "synth"} {
        lappend jobs "synth"
        # Add proj to the jobs list if the project doesn't exist yet.
        if { [file exists "$buildpath/project_1.xpr"] == 0} {
            lappend jobs "proj"
        }
    } elseif {$argv == "par"} {
        lappend jobs "par"
        # Add proj to the jobs list if the project doesn't exist yet.
        if { [file exists "$buildpath/project_1.xpr"] == 0} {
            lappend jobs "proj"
        }
    }
} else {
    set jobs {"proj" "synth" "par"}
}

# Project operations
if {[lsearch -exact $jobs "proj"] >= 0} {
    process::create_proj $buildpath $part $block_design $srcs $ip $constr
} else {
    open_project $buildpath/project_1.xpr
}

if {[lsearch -exact $jobs "synth"] >= 0} {
    process::run_synth synth_1 4 $generics
}

if {[lsearch -exact $jobs "par"] >= 0} {
    process::run_par $buildpath impl_1
}
