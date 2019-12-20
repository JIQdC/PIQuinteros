################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name S_AXI_ACLK_0 -period 10 [get_ports S_AXI_ACLK_0]
create_clock -name adc_DCO_i -period 10 [get_ports adc_DCO_i]
create_clock -name fifo_clk_rd_i -period 10 [get_ports fifo_clk_rd_i]

################################################################################