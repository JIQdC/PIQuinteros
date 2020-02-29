
################################################################
# This is a generated script based on design: SistAdq_test1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2019.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source SistAdq_test1_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# adc_control_saxi, debug_control, deserializer

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z030fbg676-2
   set_property BOARD_PART www.proyecto-ciaa.com.ar:ciaa-acc:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name SistAdq_test1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:fifo_generator:13.2\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:selectio_wiz:5.1\
xilinx.com:ip:sim_clk_gen:1.0\
xilinx.com:ip:xlconcat:2.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
adc_control_saxi\
debug_control\
deserializer\
"

   set list_mods_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_msg_id "BD_TCL-008" "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set S00_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S00_AXI_0


  # Create ports
  set adc_DCO2_n_i [ create_bd_port -dir I -type clk adc_DCO2_n_i ]
  set adc_DCO2_p_i [ create_bd_port -dir I -type clk adc_DCO2_p_i ]
  set adc_bank12_n_i [ create_bd_port -dir I -from 1 -to 0 adc_bank12_n_i ]
  set adc_bank12_p_i [ create_bd_port -dir I -from 1 -to 0 adc_bank12_p_i ]
  set clk_o [ create_bd_port -dir O -type clk clk_o ]
  set rst_n_o [ create_bd_port -dir O -from 0 -to 0 -type rst rst_n_o ]

  # Create instance: adc_control_saxi_0, and set properties
  set block_name adc_control_saxi
  set block_cell_name adc_control_saxi_0
  if { [catch {set adc_control_saxi_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $adc_control_saxi_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {2} \
 ] $axi_interconnect_0

  # Create instance: debug_control_0, and set properties
  set block_name debug_control
  set block_cell_name debug_control_0
  if { [catch {set debug_control_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $debug_control_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: deserializer_0, and set properties
  set block_name deserializer
  set block_cell_name deserializer_0
  if { [catch {set deserializer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_msg_id "BD_TCL-105" "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $deserializer_0 eq "" } {
     catch {common::send_msg_id "BD_TCL-106" "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: fifo_generator_0, and set properties
  set fifo_generator_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 fifo_generator_0 ]
  set_property -dict [ list \
   CONFIG.Dout_Reset_Value {def} \
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value {1023} \
   CONFIG.Full_Threshold_Negate_Value {1022} \
   CONFIG.Input_Data_Width {14} \
   CONFIG.Output_Data_Width {14} \
   CONFIG.Overflow_Flag {true} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count {true} \
   CONFIG.Read_Data_Count_Width {10} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.Underflow_Flag {false} \
   CONFIG.Use_Extra_Logic {false} \
   CONFIG.Valid_Flag {false} \
   CONFIG.Write_Acknowledge_Flag {false} \
   CONFIG.Write_Data_Count_Width {10} \
 ] $fifo_generator_0

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]
  set_property -dict [ list \
   CONFIG.C_NUM_PERP_RST {2} \
 ] $proc_sys_reset_0

  # Create instance: reset_deb, and set properties
  set reset_deb [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 reset_deb ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
 ] $reset_deb

  # Create instance: reset_fifo, and set properties
  set reset_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 reset_fifo ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $reset_fifo

  # Create instance: selectio_wiz_0, and set properties
  set selectio_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz:5.1 selectio_wiz_0 ]
  set_property -dict [ list \
   CONFIG.BUS_IO_STD {LVDS_25} \
   CONFIG.BUS_SIG_TYPE {DIFF} \
   CONFIG.CLK_FWD_IO_STD {LVDS_25} \
   CONFIG.CLK_FWD_SIG_TYPE {DIFF} \
   CONFIG.SELIO_ACTIVE_EDGE {DDR} \
   CONFIG.SELIO_BUS_IN_DELAY {NONE} \
   CONFIG.SELIO_CLK_IO_STD {LVDS_25} \
   CONFIG.SELIO_CLK_SIG_TYPE {DIFF} \
   CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
   CONFIG.SERIALIZATION_FACTOR {4} \
   CONFIG.SYSTEM_DATA_WIDTH {2} \
 ] $selectio_wiz_0

  # Create instance: sim_clk_gen_0, and set properties
  set sim_clk_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:sim_clk_gen:1.0 sim_clk_gen_0 ]
  set_property -dict [ list \
   CONFIG.INITIAL_RESET_CLOCK_CYCLES {5} \
 ] $sim_clk_gen_0

  # Create instance: slice_data_1, and set properties
  set slice_data_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_data_1 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {3} \
   CONFIG.DIN_TO {3} \
   CONFIG.DIN_WIDTH {4} \
   CONFIG.DOUT_WIDTH {1} \
 ] $slice_data_1

  # Create instance: slice_data_2, and set properties
  set slice_data_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_data_2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {4} \
   CONFIG.DOUT_WIDTH {1} \
 ] $slice_data_2

  # Create instance: slice_frame, and set properties
  set slice_frame [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 slice_frame ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {4} \
 ] $slice_frame

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_0_1 [get_bd_intf_ports S00_AXI_0] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins adc_control_saxi_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net adc_control_saxi_0_deb_control_o [get_bd_pins adc_control_saxi_0/deb_control_o] [get_bd_pins debug_control_0/control_i]
  connect_bd_net -net adc_control_saxi_0_deb_select_clk_o [get_bd_pins adc_control_saxi_0/deb_select_clk_o] [get_bd_pins debug_control_0/select_clk_i]
  connect_bd_net -net adc_control_saxi_0_deb_usr_w1_o [get_bd_pins adc_control_saxi_0/deb_usr_w1_o] [get_bd_pins debug_control_0/usr_w1_i]
  connect_bd_net -net adc_control_saxi_0_deb_usr_w2_o [get_bd_pins adc_control_saxi_0/deb_usr_w2_o] [get_bd_pins debug_control_0/usr_w2_i]
  connect_bd_net -net adc_control_saxi_0_fifo_rd_en_o [get_bd_pins adc_control_saxi_0/fifo_rd_en_o] [get_bd_pins fifo_generator_0/rd_en]
  connect_bd_net -net clk_in_n_0_1 [get_bd_ports adc_DCO2_n_i] [get_bd_pins selectio_wiz_0/clk_in_n]
  connect_bd_net -net clk_in_p_0_1 [get_bd_ports adc_DCO2_p_i] [get_bd_pins selectio_wiz_0/clk_in_p]
  connect_bd_net -net data_in_from_pins_n_0_1 [get_bd_ports adc_bank12_n_i] [get_bd_pins selectio_wiz_0/data_in_from_pins_n]
  connect_bd_net -net data_in_from_pins_p_0_1 [get_bd_ports adc_bank12_p_i] [get_bd_pins selectio_wiz_0/data_in_from_pins_p]
  connect_bd_net -net debug_control_0_d_out_o [get_bd_pins debug_control_0/d_out_o] [get_bd_pins fifo_generator_0/din]
  connect_bd_net -net debug_control_0_d_valid_o [get_bd_pins debug_control_0/wr_en_o] [get_bd_pins fifo_generator_0/wr_en]
  connect_bd_net -net debug_control_0_wr_clk_o [get_bd_pins debug_control_0/wr_clk_o] [get_bd_pins fifo_generator_0/wr_clk]
  connect_bd_net -net deserializer_0_d_out [get_bd_pins debug_control_0/d_out_i] [get_bd_pins deserializer_0/d_out]
  connect_bd_net -net deserializer_0_d_valid [get_bd_pins debug_control_0/d_valid_i] [get_bd_pins deserializer_0/d_valid]
  connect_bd_net -net fifo_generator_0_dout [get_bd_pins adc_control_saxi_0/fifo_dout_i] [get_bd_pins fifo_generator_0/dout]
  connect_bd_net -net fifo_generator_0_empty [get_bd_pins adc_control_saxi_0/fifo_empty_i] [get_bd_pins fifo_generator_0/empty]
  connect_bd_net -net fifo_generator_0_full [get_bd_pins adc_control_saxi_0/fifo_full_i] [get_bd_pins fifo_generator_0/full]
  connect_bd_net -net fifo_generator_0_overflow [get_bd_pins adc_control_saxi_0/fifo_ov_i] [get_bd_pins fifo_generator_0/overflow]
  connect_bd_net -net fifo_generator_0_rd_rst_busy [get_bd_pins adc_control_saxi_0/fifo_rd_rst_busy_i] [get_bd_pins fifo_generator_0/rd_rst_busy]
  connect_bd_net -net fifo_generator_0_wr_rst_busy [get_bd_pins adc_control_saxi_0/fifo_wr_rst_busy_i] [get_bd_pins fifo_generator_0/wr_rst_busy]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_ports rst_n_o] [get_bd_pins adc_control_saxi_0/S_AXI_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins proc_sys_reset_0/peripheral_reset] [get_bd_pins reset_deb/Din] [get_bd_pins reset_fifo/Din]
  connect_bd_net -net reset_deb_Dout [get_bd_pins debug_control_0/rst_i] [get_bd_pins reset_deb/Dout]
  connect_bd_net -net selectio_wiz_0_clk_out [get_bd_pins debug_control_0/clk_adc_i] [get_bd_pins deserializer_0/d_clk_in] [get_bd_pins selectio_wiz_0/clk_out]
  connect_bd_net -net selectio_wiz_0_data_in_to_device [get_bd_pins selectio_wiz_0/data_in_to_device] [get_bd_pins slice_data_1/Din] [get_bd_pins slice_data_2/Din] [get_bd_pins slice_frame/Din]
  connect_bd_net -net sim_clk_gen_0_clk1 [get_bd_ports clk_o] [get_bd_pins adc_control_saxi_0/S_AXI_ACLK] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins debug_control_0/clk_fpga_i] [get_bd_pins fifo_generator_0/rd_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins sim_clk_gen_0/clk]
  connect_bd_net -net sim_clk_gen_0_sync_rst [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins sim_clk_gen_0/sync_rst]
  connect_bd_net -net slice_data_1_Dout [get_bd_pins slice_data_1/Dout] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net slice_data_2_Dout [get_bd_pins slice_data_2/Dout] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net slice_frame_Dout [get_bd_pins debug_control_0/frame_i] [get_bd_pins deserializer_0/d_frame] [get_bd_pins slice_frame/Dout]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins deserializer_0/d_in] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces S00_AXI_0] [get_bd_addr_segs adc_control_saxi_0/S_AXI/reg0] SEG_adc_control_saxi_0_reg0


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


