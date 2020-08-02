# Create device tree
puts "Creating device tree:"
puts "   DEVICE_TREE_XLNX_PATH = $env(DEVICE_TREE_XLNX_PATH)"
puts "   HWDEF = $env(HWDEF_PATH)"
puts "   OUTDIR = $env(OUTDIR_PATH)"

hsi open_hw_design $env(HWDEF_PATH)
hsi set_repo_path $env(DEVICE_TREE_XLNX_PATH)
hsi create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0

puts "Writing dts files to $env(OUTDIR_PATH)."
hsi generate_target -dir $env(OUTDIR_PATH)
hsi close_hw_design [hsi::current_hw_design]
