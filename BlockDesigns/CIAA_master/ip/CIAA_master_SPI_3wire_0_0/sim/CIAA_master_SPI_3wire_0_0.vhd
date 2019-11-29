-- (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
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

-- IP VLNV: xilinx.com:module_ref:SPI_3wire:1.0
-- IP Revision: 1

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY CIAA_master_SPI_3wire_0_0 IS
  PORT (
    proc_sclk : IN STD_LOGIC;
    proc_ss1 : IN STD_LOGIC;
    proc_ss2 : IN STD_LOGIC;
    proc_mosi : IN STD_LOGIC;
    proc_miso : OUT STD_LOGIC;
    adc_sclk : OUT STD_LOGIC;
    adc_ss1 : OUT STD_LOGIC;
    adc_ss2 : OUT STD_LOGIC;
    adc_sdio : INOUT STD_LOGIC;
    tristate_en : IN STD_LOGIC
  );
END CIAA_master_SPI_3wire_0_0;

ARCHITECTURE CIAA_master_SPI_3wire_0_0_arch OF CIAA_master_SPI_3wire_0_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF CIAA_master_SPI_3wire_0_0_arch: ARCHITECTURE IS "yes";
  COMPONENT SPI_3wire IS
    PORT (
      proc_sclk : IN STD_LOGIC;
      proc_ss1 : IN STD_LOGIC;
      proc_ss2 : IN STD_LOGIC;
      proc_mosi : IN STD_LOGIC;
      proc_miso : OUT STD_LOGIC;
      adc_sclk : OUT STD_LOGIC;
      adc_ss1 : OUT STD_LOGIC;
      adc_ss2 : OUT STD_LOGIC;
      adc_sdio : INOUT STD_LOGIC;
      tristate_en : IN STD_LOGIC
    );
  END COMPONENT SPI_3wire;
  ATTRIBUTE IP_DEFINITION_SOURCE : STRING;
  ATTRIBUTE IP_DEFINITION_SOURCE OF CIAA_master_SPI_3wire_0_0_arch: ARCHITECTURE IS "module_ref";
BEGIN
  U0 : SPI_3wire
    PORT MAP (
      proc_sclk => proc_sclk,
      proc_ss1 => proc_ss1,
      proc_ss2 => proc_ss2,
      proc_mosi => proc_mosi,
      proc_miso => proc_miso,
      adc_sclk => adc_sclk,
      adc_ss1 => adc_ss1,
      adc_ss2 => adc_ss2,
      adc_sdio => adc_sdio,
      tristate_en => tristate_en
    );
END CIAA_master_SPI_3wire_0_0_arch;
