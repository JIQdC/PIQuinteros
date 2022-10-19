# Test names list
puts [string repeat - 72]
puts "Available tests:"
set test_names {
    remake_calibration_test
}

# If no test name is entered print test names and exit.
if {($argc == 0) || ($1 ni $test_names)} {
    puts "Usage: source sim.do \[test_name\]"
    puts "Please select one of the available tests."
    return
}

set uvm_testname $1

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

set work work

catch {file delete -force $work}

vlib $work
set src_path ../tb

do ../questa/compile.do
do compile.do


vsim \
    -voptargs=+acc\
    -t ps\
    +UVM_TESTNAME=$uvm_testname\
    -work $work \
-L xilinx_vip \
-L xpm \
-L xil_defaultlib \
-L fifo_generator_v13_2_5 \
-L xbip_utils_v3_0_10 \
-L axi_utils_v2_0_6 \
-L fir_compiler_v7_2_15 \
-L xbip_pipe_v3_0_6 \
-L xbip_bram18k_v3_0_6 \
-L mult_gen_v12_0_16 \
-L cmpy_v6_0_19 \
-L c_reg_fd_v12_0_6 \
-L xbip_dsp48_wrapper_v3_0_4 \
-L xbip_dsp48_addsub_v3_0_6 \
-L xbip_addsub_v3_0_6 \
-L c_addsub_v12_0_14 \
-L c_gate_bit_v12_0_6 \
-L xbip_counter_v3_0_6 \
-L c_counter_binary_v12_0_14 \
-L xbip_dsp48_multadd_v3_0_6 \
-L dds_compiler_v6_0_20 \
-L generic_baseblocks_v2_1_0 \
-L axi_infrastructure_v1_1_0 \
-L axi_register_slice_v2_1_22 \
-L axi_data_fifo_v2_1_21 \
-L axi_crossbar_v2_1_23 \
-L dist_mem_gen_v8_0_13 \
-L lib_pkg_v1_0_2 \
-L lib_cdc_v1_0_2 \
-L lib_srl_fifo_v1_0_2 \
-L lib_fifo_v1_0_14 \
-L axi_lite_ipif_v3_0_4 \
-L interrupt_control_v3_1_4 \
-L axi_quad_spi_v3_2_21 \
-L adc_spi_control \
-L axi_vip_v1_1_8 \
-L processing_system7_vip_v1_0_10 \
-L proc_sys_reset_v5_0_13 \
-L axi_protocol_converter_v2_1_22 \
-L axi_clock_converter_v2_1_21 \
-L xilinx_vip \
-L unisims_ver \
-L unimacro_ver \
-L secureip \
    $work.remake_top  $work.glbl

do wave.do
run -a
transcript file ""