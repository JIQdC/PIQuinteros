--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
--Date        : Fri Oct 21 20:06:50 2022
--Host        : fedora running 64-bit unknown
--Command     : generate_target preprocessing_setup_bd.bd
--Design      : preprocessing_setup_bd
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Local_osc_hier_imp_B52PYN is
  port (
    adc_clk : in STD_LOGIC;
    adc_rst_ni : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tvalid : out STD_LOGIC
  );
end Local_osc_hier_imp_B52PYN;

architecture STRUCTURE of Local_osc_hier_imp_B52PYN is
  component preprocessing_setup_bd_Local_oscillator_1 is
  port (
    aclk : in STD_LOGIC;
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tready : in STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 )
  );
  end component preprocessing_setup_bd_Local_oscillator_1;
  component preprocessing_setup_bd_dsp_dds_compiler_con_0_0 is
  port (
    aclk : in STD_LOGIC;
    rst_ni : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tvalid : out STD_LOGIC
  );
  end component preprocessing_setup_bd_dsp_dds_compiler_con_0_0;
  signal Local_oscillator_M_AXIS_DATA_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal Local_oscillator_M_AXIS_DATA_TREADY : STD_LOGIC;
  signal Local_oscillator_M_AXIS_DATA_TVALID : STD_LOGIC;
  signal aclk_0_1 : STD_LOGIC;
  signal dsp_dds_compiler_con_0_m_axis_tdata : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal dsp_dds_compiler_con_0_m_axis_tvalid : STD_LOGIC;
  signal rst_ni_0_1 : STD_LOGIC;
begin
  aclk_0_1 <= adc_clk;
  m_axis_tdata(15 downto 0) <= dsp_dds_compiler_con_0_m_axis_tdata(15 downto 0);
  m_axis_tvalid <= dsp_dds_compiler_con_0_m_axis_tvalid;
  rst_ni_0_1 <= adc_rst_ni;
Local_oscillator: component preprocessing_setup_bd_Local_oscillator_1
     port map (
      aclk => aclk_0_1,
      m_axis_data_tdata(15 downto 0) => Local_oscillator_M_AXIS_DATA_TDATA(15 downto 0),
      m_axis_data_tready => Local_oscillator_M_AXIS_DATA_TREADY,
      m_axis_data_tvalid => Local_oscillator_M_AXIS_DATA_TVALID
    );
dsp_dds_compiler_con_0: component preprocessing_setup_bd_dsp_dds_compiler_con_0_0
     port map (
      aclk => aclk_0_1,
      m_axis_tdata(15 downto 0) => dsp_dds_compiler_con_0_m_axis_tdata(15 downto 0),
      m_axis_tvalid => dsp_dds_compiler_con_0_m_axis_tvalid,
      rst_ni => rst_ni_0_1,
      s_axis_tdata(15 downto 0) => Local_oscillator_M_AXIS_DATA_TDATA(15 downto 0),
      s_axis_tready => Local_oscillator_M_AXIS_DATA_TREADY,
      s_axis_tvalid => Local_oscillator_M_AXIS_DATA_TVALID
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity cdc_hier_imp_FXXU4G is
  port (
    adc_clk : in STD_LOGIC;
    adc_rst_ni : in STD_LOGIC;
    data_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
end cdc_hier_imp_FXXU4G;

architecture STRUCTURE of cdc_hier_imp_FXXU4G is
  component preprocessing_setup_bd_cdc_comparator_0_0 is
  port (
    clk_i : in STD_LOGIC;
    rst_ni : in STD_LOGIC;
    data_1_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    data_2_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component preprocessing_setup_bd_cdc_comparator_0_0;
  component preprocessing_setup_bd_cdc_two_ff_sync_0_0 is
  port (
    clk_i : in STD_LOGIC;
    rst_ni : in STD_LOGIC;
    data_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component preprocessing_setup_bd_cdc_two_ff_sync_0_0;
  component preprocessing_setup_bd_cdc_two_ff_sync_1_0 is
  port (
    clk_i : in STD_LOGIC;
    rst_ni : in STD_LOGIC;
    data_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    data_out : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component preprocessing_setup_bd_cdc_two_ff_sync_1_0;
  signal AXI_hier_data_source_selector : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal Net1 : STD_LOGIC;
  signal aclk_0_1 : STD_LOGIC;
  signal cdc_comparator_0_data_out : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal cdc_two_ff_sync_0_data_out : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal cdc_two_ff_sync_1_data_out : STD_LOGIC_VECTOR ( 1 downto 0 );
begin
  AXI_hier_data_source_selector(1 downto 0) <= data_in(1 downto 0);
  Net1 <= adc_rst_ni;
  aclk_0_1 <= adc_clk;
  data_out(1 downto 0) <= cdc_comparator_0_data_out(1 downto 0);
cdc_comparator_0: component preprocessing_setup_bd_cdc_comparator_0_0
     port map (
      clk_i => aclk_0_1,
      data_1_in(1 downto 0) => cdc_two_ff_sync_0_data_out(1 downto 0),
      data_2_in(1 downto 0) => cdc_two_ff_sync_1_data_out(1 downto 0),
      data_out(1 downto 0) => cdc_comparator_0_data_out(1 downto 0),
      rst_ni => Net1
    );
cdc_two_ff_sync_0: component preprocessing_setup_bd_cdc_two_ff_sync_0_0
     port map (
      clk_i => aclk_0_1,
      data_in(1 downto 0) => AXI_hier_data_source_selector(1 downto 0),
      data_out(1 downto 0) => cdc_two_ff_sync_0_data_out(1 downto 0),
      rst_ni => Net1
    );
cdc_two_ff_sync_1: component preprocessing_setup_bd_cdc_two_ff_sync_1_0
     port map (
      clk_i => aclk_0_1,
      data_in(1 downto 0) => cdc_two_ff_sync_0_data_out(1 downto 0),
      data_out(1 downto 0) => cdc_two_ff_sync_1_data_out(1 downto 0),
      rst_ni => Net1
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity preprocessing_setup_bd is
  port (
    adc_clk_0 : in STD_LOGIC;
    adc_rst_ni_0 : in STD_LOGIC;
    data_local_osc : out STD_LOGIC_VECTOR ( 15 downto 0 );
    data_osc : out STD_LOGIC_VECTOR ( 31 downto 0 );
    data_sel_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    data_sel_out : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axis_0_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_0_tvalid : out STD_LOGIC;
    tready_osc_in : in STD_LOGIC;
    valid_local_osc : out STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of preprocessing_setup_bd : entity is "preprocessing_setup_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=preprocessing_setup_bd,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=9,numReposBlks=7,numNonXlnxBlks=0,numHierBlks=2,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=5,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of preprocessing_setup_bd : entity is "preprocessing_setup_bd.hwdef";
end preprocessing_setup_bd;

architecture STRUCTURE of preprocessing_setup_bd is
  component preprocessing_setup_bd_Band_selector_oscillator_1 is
  port (
    aclk : in STD_LOGIC;
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tready : in STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component preprocessing_setup_bd_Band_selector_oscillator_1;
  component preprocessing_setup_bd_basic_counter_0_0 is
  port (
    clk_i : in STD_LOGIC;
    rst_ni : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_tvalid : out STD_LOGIC
  );
  end component preprocessing_setup_bd_basic_counter_0_0;
  signal Band_selector_oscillator_m_axis_data_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Local_osc_hier_m_axis_tdata : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal Local_osc_hier_m_axis_tvalid : STD_LOGIC;
  signal adc_clk_0_2 : STD_LOGIC;
  signal adc_rst_ni_0_1 : STD_LOGIC;
  signal basic_counter_0_m_axis_TDATA : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal basic_counter_0_m_axis_TVALID : STD_LOGIC;
  signal cdc_hier_data_out : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal data_in_0_1 : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal m_axis_data_tready_0_1 : STD_LOGIC;
  signal NLW_Band_selector_oscillator_m_axis_data_tvalid_UNCONNECTED : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_clk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.ADC_CLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of adc_clk_0 : signal is "XIL_INTERFACENAME CLK.ADC_CLK_0, CLK_DOMAIN preprocessing_setup_bd_adc_clk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of m_axis_0_tvalid : signal is "xilinx.com:interface:axis:1.0 m_axis_0 TVALID";
  attribute X_INTERFACE_INFO of m_axis_0_tdata : signal is "xilinx.com:interface:axis:1.0 m_axis_0 TDATA";
  attribute X_INTERFACE_PARAMETER of m_axis_0_tdata : signal is "XIL_INTERFACENAME m_axis_0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  adc_clk_0_2 <= adc_clk_0;
  adc_rst_ni_0_1 <= adc_rst_ni_0;
  data_in_0_1(1 downto 0) <= data_sel_in(1 downto 0);
  data_local_osc(15 downto 0) <= Local_osc_hier_m_axis_tdata(15 downto 0);
  data_osc(31 downto 0) <= Band_selector_oscillator_m_axis_data_tdata(31 downto 0);
  data_sel_out(1 downto 0) <= cdc_hier_data_out(1 downto 0);
  m_axis_0_tdata(15 downto 0) <= basic_counter_0_m_axis_TDATA(15 downto 0);
  m_axis_0_tvalid <= basic_counter_0_m_axis_TVALID;
  m_axis_data_tready_0_1 <= tready_osc_in;
  valid_local_osc <= Local_osc_hier_m_axis_tvalid;
Band_selector_oscillator: component preprocessing_setup_bd_Band_selector_oscillator_1
     port map (
      aclk => adc_clk_0_2,
      m_axis_data_tdata(31 downto 0) => Band_selector_oscillator_m_axis_data_tdata(31 downto 0),
      m_axis_data_tready => m_axis_data_tready_0_1,
      m_axis_data_tvalid => NLW_Band_selector_oscillator_m_axis_data_tvalid_UNCONNECTED
    );
Local_osc_hier: entity work.Local_osc_hier_imp_B52PYN
     port map (
      adc_clk => adc_clk_0_2,
      adc_rst_ni => adc_rst_ni_0_1,
      m_axis_tdata(15 downto 0) => Local_osc_hier_m_axis_tdata(15 downto 0),
      m_axis_tvalid => Local_osc_hier_m_axis_tvalid
    );
basic_counter_0: component preprocessing_setup_bd_basic_counter_0_0
     port map (
      clk_i => adc_clk_0_2,
      m_axis_tdata(15 downto 0) => basic_counter_0_m_axis_TDATA(15 downto 0),
      m_axis_tvalid => basic_counter_0_m_axis_TVALID,
      rst_ni => adc_rst_ni_0_1
    );
cdc_hier: entity work.cdc_hier_imp_FXXU4G
     port map (
      adc_clk => adc_clk_0_2,
      adc_rst_ni => adc_rst_ni_0_1,
      data_in(1 downto 0) => data_in_0_1(1 downto 0),
      data_out(1 downto 0) => cdc_hier_data_out(1 downto 0)
    );
end STRUCTURE;
