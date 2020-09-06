set cwd [pwd]
set hwdef $env(HWDEF)
puts "Using hardware definition: $hwdef."

setws build/bsp

# Create the hw project.
createhw -name hw_0 -hwspec $hwdef

# Create bsp for FSBL based on hardware.
createbsp -name bsp_0 -hwproject hw_0 -proc ps7_cortexa9_0
setlib -bsp bsp_0 -lib xilffs
regenbsp -bsp bsp_0

# Build everything
projects -build
exit
