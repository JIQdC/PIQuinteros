-- (c) Copyright 1995-2022 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:module_ref:dsp_data_source_mux:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY preprocessing_setup_bd_dsp_data_source_mux_0_0 IS
  PORT (
    counter_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    counter_tvalid : IN STD_LOGIC;
    adc_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    adc_tvalid : IN STD_LOGIC;
    dds_compiler_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dds_compiler_tvalid : IN STD_LOGIC;
    control_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axis_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_tvalid : OUT STD_LOGIC
  );
END preprocessing_setup_bd_dsp_data_source_mux_0_0;

ARCHITECTURE preprocessing_setup_bd_dsp_data_source_mux_0_0_arch OF preprocessing_setup_bd_dsp_data_source_mux_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF preprocessing_setup_bd_dsp_data_source_mux_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT dsp_data_source_mux IS
    PORT (
      counter_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      counter_tvalid : IN STD_LOGIC;
      adc_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      adc_tvalid : IN STD_LOGIC;
      dds_compiler_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      dds_compiler_tvalid : IN STD_LOGIC;
      control_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axis_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      m_axis_tvalid : OUT STD_LOGIC
    );
  END COMPONENT dsp_data_source_mux;
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF preprocessing_setup_bd_dsp_data_source_mux_0_0_arch: ARCHITECTURE IS "module_ref";
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF m_axis_tdata: SIGNAL IS "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF m_axis_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 m_axis TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF dds_compiler_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 dds_compiler TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF dds_compiler_tdata: SIGNAL IS "XIL_INTERFACENAME dds_compiler, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF dds_compiler_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 dds_compiler TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF adc_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 adc TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF adc_tdata: SIGNAL IS "XIL_INTERFACENAME adc, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF adc_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 adc TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF counter_tvalid: SIGNAL IS "xilinx.com:interface:axis:1.0 counter TVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF counter_tdata: SIGNAL IS "XIL_INTERFACENAME counter, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0";
  ATTRIBUTE X_INTERFACE_INFO OF counter_tdata: SIGNAL IS "xilinx.com:interface:axis:1.0 counter TDATA";
BEGIN
  U0 : dsp_data_source_mux
    PORT MAP (
      counter_tdata => counter_tdata,
      counter_tvalid => counter_tvalid,
      adc_tdata => adc_tdata,
      adc_tvalid => adc_tvalid,
      dds_compiler_tdata => dds_compiler_tdata,
      dds_compiler_tvalid => dds_compiler_tvalid,
      control_in => control_in,
      m_axis_tdata => m_axis_tdata,
      m_axis_tvalid => m_axis_tvalid
    );
END preprocessing_setup_bd_dsp_data_source_mux_0_0_arch;
