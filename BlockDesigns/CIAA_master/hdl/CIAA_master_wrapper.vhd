--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Fri Dec 20 09:22:31 2019
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
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    adc_sclk_o : out STD_LOGIC;
    adc_sdio_io : inout STD_LOGIC;
    adc_ss1_o : out STD_LOGIC;
    adc_ss2_o : out STD_LOGIC;
    hdmi_en_o : out STD_LOGIC;
    led_green_o : out STD_LOGIC;
    led_red_o : out STD_LOGIC;
    tp8_o : out STD_LOGIC;
    vadj_en_o : out STD_LOGIC
  );
end CIAA_master_wrapper;

architecture STRUCTURE of CIAA_master_wrapper is
  component CIAA_master is
  port (
    adc_sclk_o : out STD_LOGIC;
    adc_sdio_io : inout STD_LOGIC;
    adc_ss1_o : out STD_LOGIC;
    adc_ss2_o : out STD_LOGIC;
    hdmi_en_o : out STD_LOGIC;
    led_green_o : out STD_LOGIC;
    led_red_o : out STD_LOGIC;
    tp8_o : out STD_LOGIC;
    vadj_en_o : out STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC
  );
  end component CIAA_master;
begin
CIAA_master_i: component CIAA_master
     port map (
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      adc_sclk_o => adc_sclk_o,
      adc_sdio_io => adc_sdio_io,
      adc_ss1_o => adc_ss1_o,
      adc_ss2_o => adc_ss2_o,
      hdmi_en_o => hdmi_en_o,
      led_green_o => led_green_o,
      led_red_o => led_red_o,
      tp8_o => tp8_o,
      vadj_en_o => vadj_en_o
    );
end STRUCTURE;
