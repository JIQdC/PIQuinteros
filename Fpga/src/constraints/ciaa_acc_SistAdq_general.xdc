# ----------------------------------------------------------------------------------
# -- Company:  Instituto Balseiro
# -- Engineer: José Quinteros
# -- 
# -- Design Name: 
# -- Module Name: 
# -- Project Name: 
# -- Target Devices: 
# -- Tool Versions: 
# -- Description: General constraints file for CIAA-ACC acquisition system project
# -- 
# -- Dependencies: None.
# -- 
# -- Revision: 2020-11-15
# -- Additional Comments: 
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# VADJ ENABLE - BANK 35 (VCCO_HP: 1.5/1.8v @ J19)
# ----------------------------------------------------------------------------

set_property PACKAGE_PIN J15 [get_ports vadj_en_o]
set_property IOSTANDARD LVCMOS18 [get_ports vadj_en_o]


# ----------------------------------------------------------------------------
# 2 x User LEDs - BANK 12 (VCCO_HR: VADJ)
# ----------------------------------------------------------------------------

set_property PACKAGE_PIN W14 [get_ports led_green_o]
set_property IOSTANDARD LVCMOS18 [get_ports led_green_o]
set_property PACKAGE_PIN W17 [get_ports led_red_o]
set_property IOSTANDARD LVCMOS18 [get_ports led_red_o]

# ----------------------------------------------------------------------------
# 8 x Digital (isolated) IOs - BANK 13 (VCCO_HR: VADJ)
# ----------------------------------------------------------------------------


# set_property PACKAGE_PIN AD24 [get_ports DIN0]
# set_property PACKAGE_PIN AF25 [get_ports DIN1]
# set_property PACKAGE_PIN AD23 [get_ports DIN2]
# set_property PACKAGE_PIN AF24 [get_ports DIN3]

set_property PACKAGE_PIN AD26 [get_ports dout0_o]
set_property IOSTANDARD LVCMOS18 [get_ports dout0_o]
set_property PACKAGE_PIN AE26 [get_ports dout1_o]
set_property IOSTANDARD LVCMOS18 [get_ports dout1_o]
#set_property PACKAGE_PIN AD25 [get_ports dout2_o]
#set_property IOSTANDARD LVCMOS18 [get_ports dout2_o]
set_property PACKAGE_PIN AE25 [get_ports dout3_o]
set_property IOSTANDARD LVCMOS18 [get_ports dout3_o]

# ----------------------------------------------------------------------------
# FMC HPC - Bank 12 and 13 (VCCO_HR: VADJ)
# ----------------------------------------------------------------------------

# ADC SPI interface @bank13
set_property PACKAGE_PIN AF15 [get_ports {adc_ss1_o}]
set_property IOSTANDARD LVCMOS18 [get_ports {adc_ss1_o}]
set_property PACKAGE_PIN AF14 [get_ports {adc_ss2_o}]
set_property IOSTANDARD LVCMOS18 [get_ports {adc_ss2_o}]
# ADC SPI interface @bank12
set_property PACKAGE_PIN AE20 [get_ports adc_sdio_o]
set_property IOSTANDARD LVCMOS18 [get_ports adc_sdio_o]
set_property PACKAGE_PIN AE21 [get_ports adc_sclk_o]
set_property IOSTANDARD LVCMOS18 [get_ports adc_sclk_o]

#FMC present signal
set_property PACKAGE_PIN AF19 [get_ports fmc_present_i]
set_property IOSTANDARD LVCMOS18 [get_ports fmc_present_i]

# ----------------------------------------------------------------------------
# FCO signals as User Generated Clocks
# ----------------------------------------------------------------------------
create_generated_clock -name SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/frame_delayed -source [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/IDDR_inst_frame/C] -divide_by 7 [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver1_inst/IDDR_inst_frame/Q2]
create_generated_clock -name SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver2_inst/frame_delayed -source [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver2_inst/IDDR_inst_frame/C] -divide_by 7 [get_pins SistAdq_i/ADC_AcqControl/adc_control_wrapper_0/U0/adc_receiver2_inst/IDDR_inst_frame/Q2]
