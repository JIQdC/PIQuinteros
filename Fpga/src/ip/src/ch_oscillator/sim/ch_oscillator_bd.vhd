--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
--Date        : Sat Oct 22 16:57:06 2022
--Host        : desktop-ump4eln.cabib.local running 64-bit unknown
--Command     : generate_target ch_oscillator_bd.bd
--Design      : ch_oscillator_bd
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Ch_oscillator_hier_imp_1HV78C6 is
  port (
    adc_clk : in STD_LOGIC;
    adc_rst_ni : in STD_LOGIC;
    m_axis_tdata_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_config_tdata_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_config_tvalid_0 : in STD_LOGIC
  );
end Ch_oscillator_hier_imp_1HV78C6;

architecture STRUCTURE of Ch_oscillator_hier_imp_1HV78C6 is
  component ch_oscillator_bd_Ch_sel_osc_cont_0 is
  port (
    aclk : in STD_LOGIC;
    rst_ni : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tvalid : out STD_LOGIC
  );
  end component ch_oscillator_bd_Ch_sel_osc_cont_0;
  component ch_oscillator_bd_Channel_selector_oscillator_0 is
  port (
    aclk : in STD_LOGIC;
    s_axis_config_tvalid : in STD_LOGIC;
    s_axis_config_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    m_axis_data_tvalid : out STD_LOGIC;
    m_axis_data_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component ch_oscillator_bd_Channel_selector_oscillator_0;
  signal Ch_sel_osc_cont_m_axis_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Oscilador_local_M_AXIS_DATA_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal Oscilador_local_M_AXIS_DATA_1_TVALID : STD_LOGIC;
  signal aclk_0_1 : STD_LOGIC;
  signal rst_ni_0_1 : STD_LOGIC;
  signal s_axis_config_tdata_0_1 : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s_axis_config_tvalid_0_1 : STD_LOGIC;
  signal NLW_Ch_sel_osc_cont_m_axis_tvalid_UNCONNECTED : STD_LOGIC;
  signal NLW_Ch_sel_osc_cont_s_axis_tready_UNCONNECTED : STD_LOGIC;
begin
  aclk_0_1 <= adc_clk;
  m_axis_tdata_0(31 downto 0) <= Ch_sel_osc_cont_m_axis_tdata(31 downto 0);
  rst_ni_0_1 <= adc_rst_ni;
  s_axis_config_tdata_0_1(15 downto 0) <= s_axis_config_tdata_0(15 downto 0);
  s_axis_config_tvalid_0_1 <= s_axis_config_tvalid_0;
Ch_sel_osc_cont: component ch_oscillator_bd_Ch_sel_osc_cont_0
     port map (
      aclk => aclk_0_1,
      m_axis_tdata(31 downto 0) => Ch_sel_osc_cont_m_axis_tdata(31 downto 0),
      m_axis_tvalid => NLW_Ch_sel_osc_cont_m_axis_tvalid_UNCONNECTED,
      rst_ni => rst_ni_0_1,
      s_axis_tdata(31 downto 0) => Oscilador_local_M_AXIS_DATA_1_TDATA(31 downto 0),
      s_axis_tready => NLW_Ch_sel_osc_cont_s_axis_tready_UNCONNECTED,
      s_axis_tvalid => Oscilador_local_M_AXIS_DATA_1_TVALID
    );
Channel_selector_oscillator: component ch_oscillator_bd_Channel_selector_oscillator_0
     port map (
      aclk => aclk_0_1,
      m_axis_data_tdata(31 downto 0) => Oscilador_local_M_AXIS_DATA_1_TDATA(31 downto 0),
      m_axis_data_tvalid => Oscilador_local_M_AXIS_DATA_1_TVALID,
      s_axis_config_tdata(15 downto 0) => s_axis_config_tdata_0_1(15 downto 0),
      s_axis_config_tvalid => s_axis_config_tvalid_0_1
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ch_oscillator_bd is
  port (
    adc_clk_0 : in STD_LOGIC;
    adc_rst_ni_0 : in STD_LOGIC;
    m_axis_tdata_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_config_tdata_0 : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_config_tvalid_0 : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of ch_oscillator_bd : entity is "ch_oscillator_bd,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ch_oscillator_bd,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=3,numReposBlks=2,numNonXlnxBlks=0,numHierBlks=1,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of ch_oscillator_bd : entity is "ch_oscillator_bd.hwdef";
end ch_oscillator_bd;

architecture STRUCTURE of ch_oscillator_bd is
  signal Ch_oscillator_hier_m_axis_tdata_0 : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal adc_clk_0_1 : STD_LOGIC;
  signal adc_rst_ni_0_1 : STD_LOGIC;
  signal s_axis_config_data : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal s_axis_config_tvalid_0_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_clk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.ADC_CLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of adc_clk_0 : signal is "XIL_INTERFACENAME CLK.ADC_CLK_0, CLK_DOMAIN ch_oscillator_bd_adc_clk_0, FREQ_HZ 260000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.000";
begin
  adc_clk_0_1 <= adc_clk_0;
  adc_rst_ni_0_1 <= adc_rst_ni_0;
  m_axis_tdata_0(31 downto 0) <= Ch_oscillator_hier_m_axis_tdata_0(31 downto 0);
  s_axis_config_data(15 downto 0) <= s_axis_config_tdata_0(15 downto 0);
  s_axis_config_tvalid_0_1 <= s_axis_config_tvalid_0;
Ch_oscillator_hier: entity work.Ch_oscillator_hier_imp_1HV78C6
     port map (
      adc_clk => adc_clk_0_1,
      adc_rst_ni => adc_rst_ni_0_1,
      m_axis_tdata_0(31 downto 0) => Ch_oscillator_hier_m_axis_tdata_0(31 downto 0),
      s_axis_config_tdata_0(15 downto 0) => s_axis_config_data(15 downto 0),
      s_axis_config_tvalid_0 => s_axis_config_tvalid_0_1
    );
end STRUCTURE;
