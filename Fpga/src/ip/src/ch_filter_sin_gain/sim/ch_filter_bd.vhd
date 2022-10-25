--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
--Date        : Tue Oct 25 08:58:20 2022
--Host        : Ferb running 64-bit major release  (build 9200)
--Command     : generate_target ch_filter_bd.bd
--Design      : ch_filter_bd
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Ch_filter_hier_imp_PSQSKR is
  port (
    M_AXIS_DATA_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_DATA_0_tvalid : out STD_LOGIC;
    adc_clk : in STD_LOGIC;
    data_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_data_tvalid : in STD_LOGIC
  );
end Ch_filter_hier_imp_PSQSKR;

architecture STRUCTURE of Ch_filter_hier_imp_PSQSKR is
  component ch_filter_bd_Channel_filter_1 is
  port (
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component ch_filter_bd_Channel_filter_1;
  component ch_filter_bd_dsp_complex_gain_1_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component ch_filter_bd_dsp_complex_gain_1_0;
  signal Channel_mixer_m_axis_dout_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Channel_mixer_m_axis_dout_tvalid : STD_LOGIC;
  signal Conn1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Conn1_TVALID : STD_LOGIC;
  signal aclk_0_1 : STD_LOGIC;
  signal dsp_complex_gain_1_data_out : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_Channel_filter_s_axis_data_tready_UNCONNECTED : STD_LOGIC;
begin
  Channel_mixer_m_axis_dout_tdata(31 downto 0) <= data_in(31 downto 0);
  Channel_mixer_m_axis_dout_tvalid <= s_axis_data_tvalid;
  M_AXIS_DATA_0_tdata(31 downto 0) <= Conn1_TDATA(31 downto 0);
  M_AXIS_DATA_0_tvalid <= Conn1_TVALID;
  aclk_0_1 <= adc_clk;
Channel_filter: component ch_filter_bd_Channel_filter_1
     port map (
      aclk => aclk_0_1,
      m_axis_data_tdata(31 downto 0) => Conn1_TDATA(31 downto 0),
      m_axis_data_tvalid => Conn1_TVALID,
      s_axis_data_tdata(31 downto 0) => dsp_complex_gain_1_data_out(31 downto 0),
      s_axis_data_tready => NLW_Channel_filter_s_axis_data_tready_UNCONNECTED,
      s_axis_data_tvalid => Channel_mixer_m_axis_dout_tvalid
    );
dsp_complex_gain_1: component ch_filter_bd_dsp_complex_gain_1_0
     port map (
      data_in(31 downto 0) => Channel_mixer_m_axis_dout_tdata(31 downto 0),
      data_out(31 downto 0) => dsp_complex_gain_1_data_out(31 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ch_filter_bd is
  port (
    adc_clk_0 : in STD_LOGIC;
    axis_out_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_out_tvalid : out STD_LOGIC;
    data_in_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    valid_in_0 : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of ch_filter_bd : entity is "ch_filter_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ch_filter_bd,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=3,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=1,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of ch_filter_bd : entity is "ch_filter_bd.hwdef";
end ch_filter_bd;

architecture STRUCTURE of ch_filter_bd is
  signal Ch_filter_hier_M_AXIS_DATA_0_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Ch_filter_hier_M_AXIS_DATA_0_TVALID : STD_LOGIC;
  signal adc_clk_0_1 : STD_LOGIC;
  signal data_in_0_1 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_data_tvalid_0_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_clk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.ADC_CLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of adc_clk_0 : signal is "XIL_INTERFACENAME CLK.ADC_CLK_0, ASSOCIATED_BUSIF axis_out, CLK_DOMAIN ch_filter_bd_adc_clk_0, FREQ_HZ 260000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of axis_out_tvalid : signal is "xilinx.com:interface:axis:1.0 axis_out TVALID";
  attribute X_INTERFACE_INFO of axis_out_tdata : signal is "xilinx.com:interface:axis:1.0 axis_out TDATA";
  attribute X_INTERFACE_PARAMETER of axis_out_tdata : signal is "XIL_INTERFACENAME axis_out, CLK_DOMAIN ch_filter_bd_adc_clk_0, FREQ_HZ 260000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 32} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value path} size {attribs {resolve_type generated dependency path_size format long minimum {} maximum {}} value 2} stride {attribs {resolve_type generated dependency path_stride format long minimum {} maximum {}} value 16} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency out_width format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency out_fractwidth format long minimum {} maximum {}} value 0} signed {attribs {resolve_type generated dependency out_signed format bool minimum {} maximum {}} value true}}}}}}}}} TDATA_WIDTH 32 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_data_valid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data_valid} enabled {attribs {resolve_type generated dependency data_valid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency data_valid_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} field_chanid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chanid} enabled {attribs {resolve_type generated dependency chanid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency chanid_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency chanid_bitoffset format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_user {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value user} enabled {attribs {resolve_type generated dependency user_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency user_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency user_bitoffset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}, PHASE 0.000, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  adc_clk_0_1 <= adc_clk_0;
  axis_out_tdata(31 downto 0) <= Ch_filter_hier_M_AXIS_DATA_0_TDATA(31 downto 0);
  axis_out_tvalid <= Ch_filter_hier_M_AXIS_DATA_0_TVALID;
  data_in_0_1(31 downto 0) <= data_in_0(31 downto 0);
  s_axis_data_tvalid_0_1 <= valid_in_0;
Ch_filter_hier: entity work.Ch_filter_hier_imp_PSQSKR
     port map (
      M_AXIS_DATA_0_tdata(31 downto 0) => Ch_filter_hier_M_AXIS_DATA_0_TDATA(31 downto 0),
      M_AXIS_DATA_0_tvalid => Ch_filter_hier_M_AXIS_DATA_0_TVALID,
      adc_clk => adc_clk_0_1,
      data_in(31 downto 0) => data_in_0_1(31 downto 0),
      s_axis_data_tvalid => s_axis_data_tvalid_0_1
    );
end STRUCTURE;
