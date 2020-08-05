# Get path to this script directory.
proc getDirname {} {
    set scriptFile [file normalize [info script]]
    set scriptDir [file dirname $scriptFile]
    return $scriptDir
}
set currpath [getDirname]

set part "xc7z010clg400-1"
set block_design "$currpath/cora_z7_bd.tcl"

# Define list of source files to be added to the project.
set srcs [list]
lappend srcs "$currpath/../vhdl/src/system_top.vhd"

set ip {}

# Define list of xdc files to be added to the project.
set constr [list]
lappend constr "$currpath/Cora-Z7-10-Master.xdc"
