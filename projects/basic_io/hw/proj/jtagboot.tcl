# Run as: xsdk jtagboot.tcl

puts "Booting from jtag"

# Specify files to load.
set bitfile build/System_top.bit
set fsbl ../sw/build/fsbl.elf
#set app  export/helloworld.elf

# Set up the IP address of the hardware server
# If not running a remote server, use:  localhost:3121
if { $argc == 1 } {
    set hw_server $argv
} else {
    set hw_server 192.168.1.8:3121
}

puts "Using xilinx hw_server @$hw_server."

puts "Connecting..."
connect -url tcp:$hw_server
target -set -nocase -filter {name =~ "ARM*#0"} -index 0
rst -system

puts "Programming PL ..."
fpga -f $bitfile

puts "Programming fsbl ..."
dow $fsbl
con

#puts "Programming app"
#dow $app
#con
