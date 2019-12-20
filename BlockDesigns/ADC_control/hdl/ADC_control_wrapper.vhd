--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Fri Dec 20 09:03:41 2019
--Host        : jiqdc-ubuntu running 64-bit Ubuntu 18.04.3 LTS
--Command     : generate_target ADC_control_wrapper.bd
--Design      : ADC_control_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ADC_control_wrapper is
  port (
    S_AXI_0_araddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_arready : out STD_LOGIC;
    S_AXI_0_arvalid : in STD_LOGIC;
    S_AXI_0_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_awready : out STD_LOGIC;
    S_AXI_0_awvalid : in STD_LOGIC;
    S_AXI_0_bready : in STD_LOGIC;
    S_AXI_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_bvalid : out STD_LOGIC;
    S_AXI_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_rready : in STD_LOGIC;
    S_AXI_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_rvalid : out STD_LOGIC;
    S_AXI_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_wready : out STD_LOGIC;
    S_AXI_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_wvalid : in STD_LOGIC;
    S_AXI_ACLK_0 : in STD_LOGIC;
    S_AXI_ARESETN_0 : in STD_LOGIC;
    adc_DCO_i : in STD_LOGIC;
    adc_FCO_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    adc_d_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    fifo_clk_rd_i : in STD_LOGIC;
    rst_i : in STD_LOGIC
  );
end ADC_control_wrapper;

architecture STRUCTURE of ADC_control_wrapper is
  component ADC_control is
  port (
    S_AXI_ACLK_0 : in STD_LOGIC;
    S_AXI_ARESETN_0 : in STD_LOGIC;
    adc_DCO_i : in STD_LOGIC;
    adc_FCO_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    adc_d_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    fifo_clk_rd_i : in STD_LOGIC;
    rst_i : in STD_LOGIC;
    S_AXI_0_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_awvalid : in STD_LOGIC;
    S_AXI_0_awready : out STD_LOGIC;
    S_AXI_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_wvalid : in STD_LOGIC;
    S_AXI_0_wready : out STD_LOGIC;
    S_AXI_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_bvalid : out STD_LOGIC;
    S_AXI_0_bready : in STD_LOGIC;
    S_AXI_0_araddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_arvalid : in STD_LOGIC;
    S_AXI_0_arready : out STD_LOGIC;
    S_AXI_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_rvalid : out STD_LOGIC;
    S_AXI_0_rready : in STD_LOGIC
  );
  end component ADC_control;
begin
ADC_control_i: component ADC_control
     port map (
      S_AXI_0_araddr(3 downto 0) => S_AXI_0_araddr(3 downto 0),
      S_AXI_0_arprot(2 downto 0) => S_AXI_0_arprot(2 downto 0),
      S_AXI_0_arready => S_AXI_0_arready,
      S_AXI_0_arvalid => S_AXI_0_arvalid,
      S_AXI_0_awaddr(3 downto 0) => S_AXI_0_awaddr(3 downto 0),
      S_AXI_0_awprot(2 downto 0) => S_AXI_0_awprot(2 downto 0),
      S_AXI_0_awready => S_AXI_0_awready,
      S_AXI_0_awvalid => S_AXI_0_awvalid,
      S_AXI_0_bready => S_AXI_0_bready,
      S_AXI_0_bresp(1 downto 0) => S_AXI_0_bresp(1 downto 0),
      S_AXI_0_bvalid => S_AXI_0_bvalid,
      S_AXI_0_rdata(31 downto 0) => S_AXI_0_rdata(31 downto 0),
      S_AXI_0_rready => S_AXI_0_rready,
      S_AXI_0_rresp(1 downto 0) => S_AXI_0_rresp(1 downto 0),
      S_AXI_0_rvalid => S_AXI_0_rvalid,
      S_AXI_0_wdata(31 downto 0) => S_AXI_0_wdata(31 downto 0),
      S_AXI_0_wready => S_AXI_0_wready,
      S_AXI_0_wstrb(3 downto 0) => S_AXI_0_wstrb(3 downto 0),
      S_AXI_0_wvalid => S_AXI_0_wvalid,
      S_AXI_ACLK_0 => S_AXI_ACLK_0,
      S_AXI_ARESETN_0 => S_AXI_ARESETN_0,
      adc_DCO_i => adc_DCO_i,
      adc_FCO_i(0) => adc_FCO_i(0),
      adc_d_i(0) => adc_d_i(0),
      fifo_clk_rd_i => fifo_clk_rd_i,
      rst_i => rst_i
    );
end STRUCTURE;
