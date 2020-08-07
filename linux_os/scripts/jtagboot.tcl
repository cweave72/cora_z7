# Environment variables to provide:
# HW_SERVER - ip:port of hardware server (localhost if local) required
# BITFILE - path to the bitfile (required)
# FSBL - path to the fsbl elf file (required)
# UBOOT - path to the u-boot image
# DTB - path to the device-tree blob (for linux)
# RAMDISK - path to the rootfs
# UIMAGE - path to the linux kernel image
#
set hwserver $env(HW_SERVER)
set bitfile $env(BITFILE)
set fsbl $env(FSBL)

if { [info exists ::env(UBOOT)] } {
    set uboot $env(UBOOT)
} else {
    set uboot "none"
}

if { [info exists ::env(DTB)] } {
    set dtb $env(DTB)
} else {
    set dtb "none"
}

if { [info exists ::env(RAMDISK)] } {
    set ramdisk $env(RAMDISK)
} else {
    set ramdisk "none"
}

if { [info exists ::env(UIMAGE)] } {
    set kernel $env(UIMAGE)
} else {
    set kernel "none"
}

puts "Booting from jtag"
puts "    hswerver : $hwserver"
puts "    bitfile  : $bitfile"
puts "    fsbl     : $fsbl"
puts "    dtb      : $dtb"
puts "    ramdisk  : $ramdisk"
puts "    kernel   : $kernel"

puts "Connecting..."
connect -url tcp:$hwserver:3121
target -set -nocase -filter {name =~ "ARM*#0"} -index 0
rst -system

puts "Programming PL"
fpga -f $bitfile

puts "Programming fsbl"
dow $fsbl
con

# Allow FSBL to run for 1 sec.
after 1000
stop

if {$uboot != "none"} {
    puts "Programming u-boot"
    #dow $uboot
    #con
}

# Below we assume that if uimage is provided, all other linux boot products
# have also been provided.
if {$kernel != "none"} {
    after 1000
    stop

    puts "Downloading ramdisk $ramdisk @0x10000000"
    dow -data $ramdisk 0x10000000
    puts "Downloading uImage @0x13200000"
    dow -data $kernel 0x13200000
    puts "Downloading dtb $dtb @0x16400000"
    dow -data $dtb 0x16400000

    puts "Execute u-boot command to boot: bootm 0x13200000 0x10000000 0x16400000"
    con
}

