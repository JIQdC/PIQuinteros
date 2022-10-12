# Runtime Tcl commands to interact with - my_eight_regs_v1_0

# Sourcing design address info tcl
set bd_path [get_property DIRECTORY [current_project]]/[current_project].srcs/[current_fileset]/bd
source ${bd_path}/my_eight_regs_v1_0_include.tcl

# jtag axi master interface hardware name, change as per your design.
set jtag_axi_master hw_axi_1
set ec 0

# hw test script
# Delete all previous axis transactions
if { [llength [get_hw_axi_txns -quiet]] } {
	delete_hw_axi_txn [get_hw_axi_txns -quiet]
}


# Test all lite slaves.
set wdata_1 abcd1234

# Test: Eight_regs
# Create a write transaction at eight_regs_addr address
create_hw_axi_txn w_eight_regs_addr [get_hw_axis $jtag_axi_master] -type write -address $eight_regs_addr -data $wdata_1
# Create a read transaction at eight_regs_addr address
create_hw_axi_txn r_eight_regs_addr [get_hw_axis $jtag_axi_master] -type read -address $eight_regs_addr
# Initiate transactions
run_hw_axi r_eight_regs_addr
run_hw_axi w_eight_regs_addr
run_hw_axi r_eight_regs_addr
set rdata_tmp [get_property DATA [get_hw_axi_txn r_eight_regs_addr]]
# Compare read data
if { $rdata_tmp == $wdata_1 } {
	puts "Data comparison test pass for - Eight_regs"
} else {
	puts "Data comparison test fail for - Eight_regs, expected-$wdata_1 actual-$rdata_tmp"
	inc ec
}

# Check error flag
if { $ec == 0 } {
	 puts "PTGEN_TEST: PASSED!" 
} else {
	 puts "PTGEN_TEST: FAILED!" 
}

