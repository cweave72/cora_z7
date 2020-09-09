# Get path to this script directory.
proc getDirname {} {
    set scriptFile [file normalize [info script]]
    set scriptDir [file dirname $scriptFile]
    return $scriptDir
}
set currpath [getDirname]

set part "xc7z010clg400-1"
set block_design "$currpath/system_bd.tcl"

set generics [list]
lappend generics "DMEM_DEPTH=16384"
lappend generics "IMEM_DEPTH=65536"
lappend generics "USE_CORE_MGR_ROM=0"
lappend generics "GPIO_PORT_WIDTH=8"
lappend generics "NUM_TIMERS=1"
lappend generics "TICKS_PER_US=50"
lappend generics "SWTIMER_WIDTH=32"
lappend generics "TIMER_WIDTH=16"
lappend generics "SWTIMER_ONLY=0"
lappend generics "USE_M_EXTENSION=1"

# Define list of source files to be added to the project.
set srcs [list]
lappend srcs "$currpath/../vhdl/common/Utils_v010_P/src/Utils_v010_P.vhd"
lappend srcs "$currpath/../vhdl/common/RamDP_v010/src/RamDP_v010.vhd"
lappend srcs "$currpath/../vhdl/common/AXI4Lite_if/src/AXI4Lite_if.vhd"
lappend srcs "$currpath/../vhdl/common/RamTrueDP_v010/src/RamTrueDP_v010.vhd"
lappend srcs "$currpath/../vhdl/common/SyncFifo_v010/src/SyncFifo_v010.vhd"
lappend srcs "$currpath/../vhdl/common/AXIS_Mst/src/AXIS_Mst.vhd"
lappend srcs "$currpath/../vhdl/common/AXIS_Slv/src/AXIS_Slv.vhd"
lappend srcs "$currpath/../vhdl/common/Divider_v010/src/Divider_v010.vhd"
lappend srcs "$env(ROM_INIT_FILE)"
lappend srcs "$currpath/../vhdl/risc-v/core/src/Rom.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/RamDP32.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/RV32Instr_P.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/RegRam_Base.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/RegFile.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/Alu_Mult32.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/Alu.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/BranchCtrl.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/InstrDecode.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/LoadStoreCtrl.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/MachineCtrl.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/Core_fwd.vhd"
lappend srcs "$currpath/../vhdl/risc-v/periph/gpio/src/Gpio_v010.vhd"
lappend srcs "$currpath/../vhdl/risc-v/periph/Timer/src/Timer_v010.vhd"
lappend srcs "$currpath/../vhdl/risc-v/periph/Stream/src/Stream_Config_P.vhd"
lappend srcs "$currpath/../vhdl/risc-v/periph/Stream/src/Stream_v010.vhd"
lappend srcs "$currpath/../vhdl/risc-v/periph/IrqCtlr/src/IrqCtlr_v010.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/TraceProbes_P.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/RV32Core_v010.vhd"
lappend srcs "$currpath/../vhdl/risc-v/core/src/AXI_CoreMgr.vhd"
lappend srcs "$currpath/../vhdl/src/RV32_sys.vhd"
lappend srcs "$currpath/../vhdl/src/system_top.vhd"

set ip [list]
lappend ip "$currpath/../vhdl/ip/ila_1/ila_1/ila_1.xci"

# Define list of xdc files to be added to the project.
set constr [list]
lappend constr "$currpath/Cora-Z7-10-Master.xdc"
