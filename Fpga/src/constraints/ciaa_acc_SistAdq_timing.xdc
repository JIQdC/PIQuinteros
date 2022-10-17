# resets: until all resets are properly synchronized, treat them all as async
set_false_path -from [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/data_control_inst/async_rst_o_reg/C]
set_false_path -from [get_pins {SistAdq_i/reset_fast/U0/PR_OUT_DFF[0].FDRE_PER/C}]

# deserializer CDC
# pulse synchronizer uses 2 clocks. Data should be available before that
set deserializer_max_delay [expr 2*1e3/260]
set_max_delay \
    -datapath_only \
    -from [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/ADC_data[*].deserializer_data/out_reg_reg[*]/C] \
    -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/ADC_data[*].sampler_data/dout_reg_reg[*]/D] $deserializer_max_delay
# false path to pulse synchronizer
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/ADC_data[*].pulse_sync_data/dest_pulse_reg_reg[0]/D]

# preprocessing registers CDC
# false path to synchronizers
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/fifo_input_mux_sel_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/data_source_sel_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/ch_*_freq_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/ch_*_freq_sync_inst/valid_sync_inst/dest_pulse_reg_reg[0]/D]

# fifo registers CDC
# false path to synchronizers
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/ADC_data[*].fifo_*_sync_inst/dest_level_reg_reg[0]/D]

# debug control registers CDC
# false path to synchronizers
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/debug_enable_sync_inst/dest_level_reg_reg[0]/D]
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/debug_control_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver*_inst/debug_w2w1_sync_inst/sync_data_reg0_reg[*]/D]

