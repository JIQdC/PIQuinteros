onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/adc_clk_i
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/rst_i
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/data_RE_i
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/data_FE_i
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/frame_i
add wave -noupdate -format Analog-Interpolated -height 80 -max 6426.0 -min -8034.0 -radix decimal /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/data_o
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/d_valid_o
add wave -noupdate -format Analog-Step -height 80 -max 8188.9999999999991 -min -8152.0 -radix decimal /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/d_reg
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/out_reg
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/f_reg
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/zeros2
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/deserializer_data/valid_reg
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/sampler_data/ce
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/sampler_data/din
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/sampler_data/dout
add wave -noupdate /remake_top/SistAdq/SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/ADC_data(0)/sampler_data/dout_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {442045 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 863
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {691450 ps}
