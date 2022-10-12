

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "my_eight_regs" "NUM_INSTANCES" "DEVICE_ID"  "C_Eight_regs_BASEADDR" "C_Eight_regs_HIGHADDR"
}
