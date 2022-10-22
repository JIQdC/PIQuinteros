--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
--Date        : Fri Oct 21 20:07:36 2022
--Host        : fedora running 64-bit unknown
--Command     : generate_target band_processing_bd.bd
--Design      : band_processing_bd
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Band_filter_hier_imp_Q8IROE is
  port (
    adc_clk : in STD_LOGIC;
    data_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC
  );
end Band_filter_hier_imp_Q8IROE;

architecture STRUCTURE of Band_filter_hier_imp_Q8IROE is
  component band_processing_bd_Band_filter_0 is
  port (
    aclk : in STD_LOGIC;
    s_axis_data_tvalid : in STD_LOGIC;
    s_axis_data_tready : out STD_LOGIC;
    s_axis_data_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component band_processing_bd_Band_filter_0;
  component band_processing_bd_dsp_complex_gain_0_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component band_processing_bd_dsp_complex_gain_0_0;
  signal Band_filter_m_axis_data_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Band_filter_m_axis_data_tvalid : STD_LOGIC;
  signal Band_mixer_m_axis_dout_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Band_mixer_m_axis_dout_tvalid : STD_LOGIC;
  signal aclk_0_1 : STD_LOGIC;
  signal dsp_complex_gain_0_data_out : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_Band_filter_s_axis_data_tready_UNCONNECTED : STD_LOGIC;
begin
  Band_mixer_m_axis_dout_tdata(31 downto 0) <= data_in(31 downto 0);
  Band_mixer_m_axis_dout_tvalid <= s_axis_data_tvalid;
  aclk_0_1 <= adc_clk;
  m_axis_data_tdata(31 downto 0) <= Band_filter_m_axis_data_tdata(31 downto 0);
  m_axis_data_tvalid <= Band_filter_m_axis_data_tvalid;
Band_filter: component band_processing_bd_Band_filter_0
     port map (
      aclk => aclk_0_1,
      m_axis_data_tdata(31 downto 0) => Band_filter_m_axis_data_tdata(31 downto 0),
      m_axis_data_tvalid => Band_filter_m_axis_data_tvalid,
      s_axis_data_tdata(31 downto 0) => dsp_complex_gain_0_data_out(31 downto 0),
      s_axis_data_tready => NLW_Band_filter_s_axis_data_tready_UNCONNECTED,
      s_axis_data_tvalid => Band_mixer_m_axis_dout_tvalid
    );
dsp_complex_gain_0: component band_processing_bd_dsp_complex_gain_0_0
     port map (
      data_in(31 downto 0) => Band_mixer_m_axis_dout_tdata(31 downto 0),
      data_out(31 downto 0) => dsp_complex_gain_0_data_out(31 downto 0)
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity band_processing_bd is
  port (
    adc_clk_0 : in STD_LOGIC;
    adc_rst_ni_0 : in STD_LOGIC;
    band_mixer_data_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    band_mixer_valid_o : out STD_LOGIC;
    band_osc_in : in STD_LOGIC_VECTOR ( 31 downto 0 );
    control_in_0 : in STD_LOGIC_VECTOR ( 1 downto 0 );
    data_adc : in STD_LOGIC_VECTOR ( 13 downto 0 );
    data_counter : in STD_LOGIC_VECTOR ( 15 downto 0 );
    data_local_osc : in STD_LOGIC_VECTOR ( 15 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 31 downto 0 );
    valid_adc : in STD_LOGIC;
    valid_counter : in STD_LOGIC;
    valid_local_osc : in STD_LOGIC;
    valid_mux_out : out STD_LOGIC;
    valid_out : out STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of band_processing_bd : entity is "band_processing_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=band_processing_bd,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=8,numReposBlks=7,numNonXlnxBlks=0,numHierBlks=1,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=5,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of band_processing_bd : entity is "band_processing_bd.hwdef";
end band_processing_bd;

architecture STRUCTURE of band_processing_bd is
  component band_processing_bd_Band_mixer_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    s_axis_a_tvalid : in STD_LOGIC;
    s_axis_a_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_b_tvalid : in STD_LOGIC;
    s_axis_b_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_dout_tvalid : out STD_LOGIC;
    m_axis_dout_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component band_processing_bd_Band_mixer_0;
  component band_processing_bd_dsp_data_source_mux_0_0 is
  port (
    counter_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    counter_tvalid : in STD_LOGIC;
    adc_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    adc_tvalid : in STD_LOGIC;
    dds_compiler_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    dds_compiler_tvalid : in STD_LOGIC;
    control_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tvalid : out STD_LOGIC
  );
  end component band_processing_bd_dsp_data_source_mux_0_0;
  component band_processing_bd_valid_data_holder_0_0 is
  port (
    clk_i : in STD_LOGIC;
    rst_ni : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tvalid : out STD_LOGIC
  );
  end component band_processing_bd_valid_data_holder_0_0;
  component band_processing_bd_zero_padder_0_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 15 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component band_processing_bd_zero_padder_0_0;
  component band_processing_bd_zero_padder_1_0 is
  port (
    data_in : in STD_LOGIC_VECTOR ( 13 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component band_processing_bd_zero_padder_1_0;
  signal Band_filter_hier_m_axis_data_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Band_filter_hier_m_axis_data_tvalid : STD_LOGIC;
  signal Band_mixer_m_axis_dout_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Band_mixer_m_axis_dout_tvalid : STD_LOGIC;
  signal adc_clk_0_1 : STD_LOGIC;
  signal adc_rst_ni_0_1 : STD_LOGIC;
  signal control_in_0_1 : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal counter_tdata_0_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal counter_tvalid_0_1 : STD_LOGIC;
  signal data_in_0_1 : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal dds_compiler_tdata_0_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dds_compiler_tvalid_0_1 : STD_LOGIC;
  signal dsp_data_source_mux_0_m_axis_tdata : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dsp_data_source_mux_0_m_axis_tvalid : STD_LOGIC;
  signal s_axis_a_tdata_0_1 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal s_axis_tvalid_0_1 : STD_LOGIC;
  signal valid_data_holder_0_m_axis_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal valid_data_holder_0_m_axis_TVALID : STD_LOGIC;
  signal zero_padder_0_data_out : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal zero_padder_1_data_out : STD_LOGIC_VECTOR ( 15 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_clk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.ADC_CLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of adc_clk_0 : signal is "XIL_INTERFACENAME CLK.ADC_CLK_0, ASSOCIATED_RESET adc_rst_ni_0, CLK_DOMAIN band_processing_bd_adc_clk_0, FREQ_HZ 260000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
begin
  adc_clk_0_1 <= adc_clk_0;
  adc_rst_ni_0_1 <= adc_rst_ni_0;
  band_mixer_data_o(31 downto 0) <= Band_mixer_m_axis_dout_tdata(31 downto 0);
  band_mixer_valid_o <= Band_mixer_m_axis_dout_tvalid;
  control_in_0_1(1 downto 0) <= control_in_0(1 downto 0);
  counter_tdata_0_1(15 downto 0) <= data_counter(15 downto 0);
  counter_tvalid_0_1 <= valid_counter;
  data_in_0_1(13 downto 0) <= data_adc(13 downto 0);
  data_out(31 downto 0) <= Band_filter_hier_m_axis_data_tdata(31 downto 0);
  dds_compiler_tdata_0_1(15 downto 0) <= data_local_osc(15 downto 0);
  dds_compiler_tvalid_0_1 <= valid_local_osc;
  s_axis_a_tdata_0_1(31 downto 0) <= band_osc_in(31 downto 0);
  s_axis_tvalid_0_1 <= valid_adc;
  valid_mux_out <= dsp_data_source_mux_0_m_axis_tvalid;
  valid_out <= Band_filter_hier_m_axis_data_tvalid;
Band_filter_hier: entity work.Band_filter_hier_imp_Q8IROE
     port map (
      adc_clk => adc_clk_0_1,
      data_in(31 downto 0) => Band_mixer_m_axis_dout_tdata(31 downto 0),
      m_axis_data_tdata(31 downto 0) => Band_filter_hier_m_axis_data_tdata(31 downto 0),
      m_axis_data_tvalid => Band_filter_hier_m_axis_data_tvalid,
      s_axis_data_tvalid => Band_mixer_m_axis_dout_tvalid
    );
Band_mixer: component band_processing_bd_Band_mixer_0
     port map (
      aclk => adc_clk_0_1,
      aresetn => adc_rst_ni_0_1,
      m_axis_dout_tdata(31 downto 0) => Band_mixer_m_axis_dout_tdata(31 downto 0),
      m_axis_dout_tvalid => Band_mixer_m_axis_dout_tvalid,
      s_axis_a_tdata(31 downto 0) => s_axis_a_tdata_0_1(31 downto 0),
      s_axis_a_tvalid => dsp_data_source_mux_0_m_axis_tvalid,
      s_axis_b_tdata(31 downto 0) => zero_padder_0_data_out(31 downto 0),
      s_axis_b_tvalid => dsp_data_source_mux_0_m_axis_tvalid
    );
dsp_data_source_mux_0: component band_processing_bd_dsp_data_source_mux_0_0
     port map (
      adc_tdata(15 downto 0) => valid_data_holder_0_m_axis_TDATA(15 downto 0),
      adc_tvalid => valid_data_holder_0_m_axis_TVALID,
      control_in(1 downto 0) => control_in_0_1(1 downto 0),
      counter_tdata(15 downto 0) => counter_tdata_0_1(15 downto 0),
      counter_tvalid => counter_tvalid_0_1,
      dds_compiler_tdata(15 downto 0) => dds_compiler_tdata_0_1(15 downto 0),
      dds_compiler_tvalid => dds_compiler_tvalid_0_1,
      m_axis_tdata(15 downto 0) => dsp_data_source_mux_0_m_axis_tdata(15 downto 0),
      m_axis_tvalid => dsp_data_source_mux_0_m_axis_tvalid
    );
valid_data_holder_0: component band_processing_bd_valid_data_holder_0_0
     port map (
      clk_i => adc_clk_0_1,
      m_axis_tdata(15 downto 0) => valid_data_holder_0_m_axis_TDATA(15 downto 0),
      m_axis_tvalid => valid_data_holder_0_m_axis_TVALID,
      rst_ni => adc_rst_ni_0_1,
      s_axis_tdata(15 downto 0) => zero_padder_1_data_out(15 downto 0),
      s_axis_tvalid => s_axis_tvalid_0_1
    );
zero_padder_0: component band_processing_bd_zero_padder_0_0
     port map (
      data_in(15 downto 0) => dsp_data_source_mux_0_m_axis_tdata(15 downto 0),
      data_out(31 downto 0) => zero_padder_0_data_out(31 downto 0)
    );
zero_padder_1: component band_processing_bd_zero_padder_1_0
     port map (
      data_in(13 downto 0) => data_in_0_1(13 downto 0),
      data_out(15 downto 0) => zero_padder_1_data_out(15 downto 0)
    );
end STRUCTURE;
