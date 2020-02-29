
################################################################
# This is a generated script based on design: ADC_control
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
# source ADC_control_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# adc_control_saxi, deserializer

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
set design_name ADC_control

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./Documents/PI/PIQuinteros_repo/BlockDesigns

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_msg_id "BD_TCL-110" "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_msg_id "BD_TCL-008" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_msg_id "BD_TCL-009" "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-111" "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-010" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-112" "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_msg_id "BD_TCL-113" "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-011" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_msg_id "BD_TCL-012" "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

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
  set S_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {12} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_0


  # Create ports
  set S_AXI_ACLK_0 [ create_bd_port -dir I -type clk S_AXI_ACLK_0 ]
  set S_AXI_ARESETN_0 [ create_bd_port -dir I -type rst S_AXI_ARESETN_0 ]
  set adc_DCO_i [ create_bd_port -dir I -type clk adc_DCO_i ]
  set adc_FCO_i [ create_bd_port -dir I -from 0 -to 0 adc_FCO_i ]
  set adc_d_i [ create_bd_port -dir I -from 0 -to 0 adc_d_i ]
  set fifo_clk_rd_i [ create_bd_port -dir I -type clk fifo_clk_rd_i ]
  set rst_i [ create_bd_port -dir I -type rst rst_i ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $rst_i

  # Create instance: DDR_data, and set properties
  set DDR_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz:5.1 DDR_data ]
  set_property -dict [ list \
   CONFIG.SELIO_ACTIVE_EDGE {DDR} \
   CONFIG.SELIO_CLK_BUF {MMCM} \
   CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
   CONFIG.SERIALIZATION_FACTOR {4} \
 ] $DDR_data

  # Create instance: DDR_frame, and set properties
  set DDR_frame [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz:5.1 DDR_frame ]
  set_property -dict [ list \
   CONFIG.SELIO_ACTIVE_EDGE {DDR} \
   CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
   CONFIG.SERIALIZATION_FACTOR {4} \
 ] $DDR_frame

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
   CONFIG.Empty_Threshold_Assert_Value {4} \
   CONFIG.Empty_Threshold_Negate_Value {5} \
   CONFIG.Enable_Safety_Circuit {true} \
   CONFIG.Fifo_Implementation {Independent_Clocks_Block_RAM} \
   CONFIG.Full_Flags_Reset_Value {1} \
   CONFIG.Full_Threshold_Assert_Value {1023} \
   CONFIG.Full_Threshold_Negate_Value {1022} \
   CONFIG.Input_Data_Width {14} \
   CONFIG.Output_Data_Width {14} \
   CONFIG.Output_Depth {1024} \
   CONFIG.Overflow_Flag {true} \
   CONFIG.Performance_Options {First_Word_Fall_Through} \
   CONFIG.Read_Data_Count_Width {10} \
   CONFIG.Reset_Pin {true} \
   CONFIG.Reset_Type {Asynchronous_Reset} \
   CONFIG.Use_Dout_Reset {true} \
 ] $fifo_generator_0

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {0} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {2} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_0

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_0_1 [get_bd_intf_ports S_AXI_0] [get_bd_intf_pins adc_control_saxi_0/S_AXI]

  # Create port connections
  connect_bd_net -net S_AXI_ACLK_0_1 [get_bd_ports S_AXI_ACLK_0] [get_bd_pins adc_control_saxi_0/S_AXI_ACLK]
  connect_bd_net -net adc_control_saxi_0_fifo_rd_en_o [get_bd_pins adc_control_saxi_0/fifo_rd_en_o] [get_bd_pins fifo_generator_0/rd_en]
  connect_bd_net -net aresetn_0_1 [get_bd_ports S_AXI_ARESETN_0] [get_bd_pins adc_control_saxi_0/S_AXI_ARESETN]
  connect_bd_net -net clk_in_0_1 [get_bd_ports adc_DCO_i] [get_bd_pins DDR_data/clk_in] [get_bd_pins DDR_frame/clk_in]
  connect_bd_net -net data_in_from_pins_0_1 [get_bd_ports adc_d_i] [get_bd_pins DDR_frame/data_in_from_pins]
  connect_bd_net -net data_in_from_pins_1_1 [get_bd_ports adc_FCO_i] [get_bd_pins DDR_data/data_in_from_pins]
  connect_bd_net -net deserializer_0_d_out [get_bd_pins deserializer_0/d_out] [get_bd_pins fifo_generator_0/din]
  connect_bd_net -net deserializer_0_d_valid [get_bd_pins deserializer_0/d_valid] [get_bd_pins fifo_generator_0/wr_en]
  connect_bd_net -net fifo_generator_0_dout [get_bd_pins adc_control_saxi_0/fifo_dout_i] [get_bd_pins fifo_generator_0/dout]
  connect_bd_net -net fifo_generator_0_empty [get_bd_pins adc_control_saxi_0/fifo_empty_i] [get_bd_pins fifo_generator_0/empty]
  connect_bd_net -net fifo_generator_0_full [get_bd_pins adc_control_saxi_0/fifo_full_i] [get_bd_pins fifo_generator_0/full]
  connect_bd_net -net fifo_generator_0_overflow [get_bd_pins adc_control_saxi_0/fifo_ov_i] [get_bd_pins fifo_generator_0/overflow]
  connect_bd_net -net fifo_generator_0_rd_rst_busy [get_bd_pins adc_control_saxi_0/fifo_rd_rst_busy_i] [get_bd_pins fifo_generator_0/rd_rst_busy]
  connect_bd_net -net fifo_generator_0_wr_rst_busy [get_bd_pins adc_control_saxi_0/fifo_wr_rst_busy_i] [get_bd_pins fifo_generator_0/wr_rst_busy]
  connect_bd_net -net io_reset_0_1 [get_bd_ports rst_i] [get_bd_pins DDR_data/io_reset] [get_bd_pins DDR_frame/io_reset] [get_bd_pins fifo_generator_0/rst]
  connect_bd_net -net rd_clk_0_1 [get_bd_ports fifo_clk_rd_i] [get_bd_pins fifo_generator_0/rd_clk]
  connect_bd_net -net selectio_wiz_0_clk_out [get_bd_pins DDR_frame/clk_out] [get_bd_pins deserializer_0/d_clk_in] [get_bd_pins fifo_generator_0/wr_clk]
  connect_bd_net -net selectio_wiz_0_data_in_to_device [get_bd_pins DDR_frame/data_in_to_device] [get_bd_pins deserializer_0/d_in]
  connect_bd_net -net selectio_wiz_1_data_in_to_device [get_bd_pins DDR_data/data_in_to_device] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins deserializer_0/d_frame] [get_bd_pins xlslice_0/Dout]

  # Create address segments
  create_bd_addr_seg -range 0x00001000 -offset 0x00000000 [get_bd_addr_spaces S_AXI_0] [get_bd_addr_segs adc_control_saxi_0/S_AXI/reg0] SEG_adc_control_saxi_0_reg0


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


