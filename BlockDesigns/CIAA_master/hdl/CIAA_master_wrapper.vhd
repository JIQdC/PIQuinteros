--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Fri Nov 29 17:38:45 2019
--Host        : jiqdc-ubuntu running 64-bit Ubuntu 18.04.3 LTS
--Command     : generate_target CIAA_master_wrapper.bd
--Design      : CIAA_master_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity CIAA_master_wrapper is
  port (
    adc_sclk_0 : out STD_LOGIC;
    adc_sdio_0 : inout STD_LOGIC;
    adc_ss1_0 : out STD_LOGIC;
    adc_ss2_0 : out STD_LOGIC;
    hdmi_en_o_0 : out STD_LOGIC;
    led_green_o_0 : out STD_LOGIC;
    led_red_o_0 : out STD_LOGIC;
    tp8_o_0 : out STD_LOGIC;
    vadj_en_o_0 : out STD_LOGIC
  );
end CIAA_master_wrapper;

architecture STRUCTURE of CIAA_master_wrapper is
  component CIAA_master is
  port (
    adc_sclk_0 : out STD_LOGIC;
    adc_sdio_0 : inout STD_LOGIC;
    adc_ss1_0 : out STD_LOGIC;
    adc_ss2_0 : out STD_LOGIC;
    hdmi_en_o_0 : out STD_LOGIC;
    led_green_o_0 : out STD_LOGIC;
    led_red_o_0 : out STD_LOGIC;
    tp8_o_0 : out STD_LOGIC;
    vadj_en_o_0 : out STD_LOGIC
  );
  end component CIAA_master;
begin
CIAA_master_i: component CIAA_master
     port map (
      adc_sclk_0 => adc_sclk_0,
      adc_sdio_0 => adc_sdio_0,
      adc_ss1_0 => adc_ss1_0,
      adc_ss2_0 => adc_ss2_0,
      hdmi_en_o_0 => hdmi_en_o_0,
      led_green_o_0 => led_green_o_0,
      led_red_o_0 => led_red_o_0,
      tp8_o_0 => tp8_o_0,
      vadj_en_o_0 => vadj_en_o_0
    );
end STRUCTURE;
