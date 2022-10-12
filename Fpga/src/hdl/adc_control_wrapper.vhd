----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Wrapper for AXI data control and ADC receivers modules
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-11-20
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
LIBRARY UNISIM;
USE UNISIM.vcomponents.ALL;

USE work.fifo_record_pkg.ALL;

ENTITY adc_control_wrapper IS
  GENERIC (
    -- Core ID and version
    USER_CORE_ID_VER : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00020003";
    N : INTEGER := 16; --number of ADC channels
    N1 : INTEGER := 14; --number of ADC channels in receiver 1
    N2 : INTEGER := 2; --number of ADC channels in receiver 2
    RES_ADC : INTEGER := 14; --ADC bit resolution
    FIFO_EMPTY_VAL : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"00000DEF"; --output value when attempting to read from empty FIFO
    N_tr_b : INTEGER := 10 --bits for downsampler treshold register        
  );
  PORT (
    --AXI interface
    S_AXI_ACLK : IN STD_LOGIC;
    S_AXI_ARESETN : IN STD_LOGIC;
    S_AXI_AWADDR : IN STD_LOGIC_VECTOR(10 - 1 DOWNTO 0);
    S_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S_AXI_AWVALID : IN STD_LOGIC;
    S_AXI_AWREADY : OUT STD_LOGIC;
    S_AXI_WDATA : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    S_AXI_WSTRB : IN STD_LOGIC_VECTOR((32/8) - 1 DOWNTO 0);
    S_AXI_WVALID : IN STD_LOGIC;
    S_AXI_WREADY : OUT STD_LOGIC;
    S_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXI_BVALID : OUT STD_LOGIC;
    S_AXI_BREADY : IN STD_LOGIC;
    S_AXI_ARADDR : IN STD_LOGIC_VECTOR(10 - 1 DOWNTO 0);
    S_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S_AXI_ARVALID : IN STD_LOGIC;
    S_AXI_ARREADY : OUT STD_LOGIC;
    S_AXI_RDATA : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    S_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXI_RVALID : OUT STD_LOGIC;
    S_AXI_RREADY : IN STD_LOGIC;

    --AXI interface for preprocessing regs
    S_AXI_PREPROC_ACLK : IN STD_LOGIC;
    S_AXI_PREPROC_ARESETN : IN STD_LOGIC;
    S_AXI_PREPROC_AWADDR : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
    S_AXI_PREPROC_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S_AXI_PREPROC_AWVALID : IN STD_LOGIC;
    S_AXI_PREPROC_AWREADY : OUT STD_LOGIC;
    S_AXI_PREPROC_WDATA : IN STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    S_AXI_PREPROC_WSTRB : IN STD_LOGIC_VECTOR((32/8) - 1 DOWNTO 0);
    S_AXI_PREPROC_WVALID : IN STD_LOGIC;
    S_AXI_PREPROC_WREADY : OUT STD_LOGIC;
    S_AXI_PREPROC_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXI_PREPROC_BVALID : OUT STD_LOGIC;
    S_AXI_PREPROC_BREADY : IN STD_LOGIC;
    S_AXI_PREPROC_ARADDR : IN STD_LOGIC_VECTOR(5 - 1 DOWNTO 0);
    S_AXI_PREPROC_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    S_AXI_PREPROC_ARVALID : IN STD_LOGIC;
    S_AXI_PREPROC_ARREADY : OUT STD_LOGIC;
    S_AXI_PREPROC_RDATA : OUT STD_LOGIC_VECTOR(32 - 1 DOWNTO 0);
    S_AXI_PREPROC_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXI_PREPROC_RVALID : OUT STD_LOGIC;
    S_AXI_PREPROC_RREADY : IN STD_LOGIC;

    --external reset for peripherals
    rst_peripherals_i : IN STD_LOGIC;

    --ADC signals
    adc_DCO1_p_i : IN STD_LOGIC;
    adc_DCO1_n_i : IN STD_LOGIC;
    adc_DCO2_p_i : IN STD_LOGIC;
    adc_DCO2_n_i : IN STD_LOGIC;
    adc_FCO1_p_i : IN STD_LOGIC;
    adc_FCO1_n_i : IN STD_LOGIC;
    adc_FCO2_p_i : IN STD_LOGIC;
    adc_FCO2_n_i : IN STD_LOGIC;
    adc_data_p_i : IN STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
    adc_data_n_i : IN STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
    adc_FCO1lck_o : OUT STD_LOGIC;
    adc_FCO2lck_o : OUT STD_LOGIC;

    --downsampler control signals
    treshold_value_i : IN STD_LOGIC_VECTOR((N_tr_b - 1) DOWNTO 0);
    treshold_ld_i : IN STD_LOGIC;

    --delay control signals
    delay_locked_o : OUT STD_LOGIC;
    delay_data_ld_i : IN STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
    delay_data_input_i : IN STD_LOGIC_VECTOR((5 * N - 1) DOWNTO 0);
    delay_data_output_o : OUT STD_LOGIC_VECTOR((5 * N - 1) DOWNTO 0);
    delay_frame1_ld_i : IN STD_LOGIC;
    delay_frame1_input_i : IN STD_LOGIC_VECTOR((5 - 1) DOWNTO 0);
    delay_frame1_output_o : OUT STD_LOGIC_VECTOR((5 - 1) DOWNTO 0);
    delay_frame2_ld_i : IN STD_LOGIC;
    delay_frame2_input_i : IN STD_LOGIC_VECTOR((5 - 1) DOWNTO 0);
    delay_frame2_output_o : OUT STD_LOGIC_VECTOR((5 - 1) DOWNTO 0);

    --external trigger signal
    ext_trigger_i : IN STD_LOGIC
  );
END adc_control_wrapper;

ARCHITECTURE arch OF adc_control_wrapper IS

  --Xilinx attributes
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF adc_DCO1_p_i : SIGNAL IS "xilinx.com:interface:diff_clock:1.0 adc_DCO1_i CLK_P";
  ATTRIBUTE X_INTERFACE_INFO OF adc_DCO1_n_i : SIGNAL IS "xilinx.com:interface:diff_clock:1.0 adc_DCO1_i CLK_N";
  ATTRIBUTE X_INTERFACE_INFO OF adc_DCO2_p_i : SIGNAL IS "xilinx.com:interface:diff_clock:1.0 adc_DCO2_i CLK_P";
  ATTRIBUTE X_INTERFACE_INFO OF adc_DCO2_n_i : SIGNAL IS "xilinx.com:interface:diff_clock:1.0 adc_DCO2_i CLK_N";
  ATTRIBUTE X_INTERFACE_INFO OF adc_FCO1_p_i : SIGNAL IS "xilinx.com:interface:diff_analog_io:1.0 adc_FCO1_i V_P";
  ATTRIBUTE X_INTERFACE_INFO OF adc_FCO1_n_i : SIGNAL IS "xilinx.com:interface:diff_analog_io:1.0 adc_FCO1_i V_N";
  ATTRIBUTE X_INTERFACE_INFO OF adc_FCO2_p_i : SIGNAL IS "xilinx.com:interface:diff_analog_io:1.0 adc_FCO2_i V_P";
  ATTRIBUTE X_INTERFACE_INFO OF adc_FCO2_n_i : SIGNAL IS "xilinx.com:interface:diff_analog_io:1.0 adc_FCO2_i V_N";
  ATTRIBUTE X_INTERFACE_INFO OF adc_data_p_i : SIGNAL IS "xilinx.com:interface:diff_analog_io:1.0 adc_data_i V_P";
  ATTRIBUTE X_INTERFACE_INFO OF adc_data_n_i : SIGNAL IS "xilinx.com:interface:diff_analog_io:1.0 adc_data_i V_N";
  ATTRIBUTE X_INTERFACE_INFO OF rst_peripherals_i : SIGNAL IS "xilinx.com:signal:reset:1.0 rst_peripherals_i RST";
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER OF rst_peripherals_i : SIGNAL IS "POLARITY ACTIVE_HIGH";

  --label must be the same as label in idelay_wrapper.vhd
  ATTRIBUTE IODELAY_GROUP : STRING;
  ATTRIBUTE IODELAY_GROUP OF IDELAYCTRL_inst : LABEL IS "Reception_Delays";

  SIGNAL async_rst_from_AXI, fifo_rst_from_AXI, fifo_rst, debug_rst : STD_LOGIC := '0';
  SIGNAL debug_enable_from_AXI : STD_LOGIC := '0';
  SIGNAL debug_control_from_AXI : STD_LOGIC_VECTOR((N * 4 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL debug_control_to_r1 : STD_LOGIC_VECTOR((N1 * 4 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL debug_control_to_r2 : STD_LOGIC_VECTOR((N2 * 4 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL debug_w2w1_from_AXI : STD_LOGIC_VECTOR((28 * N - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL debug_w2w1_to_r1 : STD_LOGIC_VECTOR((28 * N1 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL debug_w2w1_to_r2 : STD_LOGIC_VECTOR((28 * N2 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL fifo_rd_en_from_AXI : STD_LOGIC_VECTOR((N - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL fifo_rd_en_to_r1 : STD_LOGIC_VECTOR((N1 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL fifo_rd_en_to_r2 : STD_LOGIC_VECTOR((N2 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL fifo_out_to_AXI : fifo_out_vector_t((N - 1) DOWNTO 0);
  SIGNAL fifo_out_from_r1 : fifo_out_vector_t((N1 - 1) DOWNTO 0);
  SIGNAL fifo_out_from_r2 : fifo_out_vector_t((N2 - 1) DOWNTO 0);
  SIGNAL adc_data_to_r1_p, adc_data_to_r1_n : STD_LOGIC_VECTOR((N1 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL adc_data_to_r2_p, adc_data_to_r2_n : STD_LOGIC_VECTOR((N2 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL delay_data_ld_to_r1 : STD_LOGIC_VECTOR((N1 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL delay_data_ld_to_r2 : STD_LOGIC_VECTOR((N2 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL delay_data_input_to_r1, delay_data_output_from_r1 : STD_LOGIC_VECTOR((5 * N1 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL delay_data_input_to_r2, delay_data_output_from_r2 : STD_LOGIC_VECTOR((5 * N2 - 1) DOWNTO 0) := (OTHERS => '0');
  SIGNAL delay_refclk : STD_LOGIC;

  --preprocessing signals
  SIGNAL data_source_sel : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ch_1_freq : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ch_2_freq : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ch_3_freq : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ch_4_freq : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL ch_5_freq : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');

BEGIN

  data_control_inst : ENTITY work.data_control(rtl)
    GENERIC MAP(
      USER_CORE_ID_VER => USER_CORE_ID_VER,
      N => N,
      FIFO_EMPTY_VAL => FIFO_EMPTY_VAL
    )
    PORT MAP(
      S_AXI_ACLK => S_AXI_ACLK, --: in std_logic;
      S_AXI_ARESETN => S_AXI_ARESETN, -- in std_logic;
      S_AXI_AWADDR => S_AXI_AWADDR, --: in std_logic_vector(10-1 downto 0);
      S_AXI_AWPROT => S_AXI_AWPROT, --: in std_logic_vector(2 downto 0);
      S_AXI_AWVALID => S_AXI_AWVALID, --: in std_logic;
      S_AXI_AWREADY => S_AXI_AWREADY, -- : out std_logic;
      S_AXI_WDATA => S_AXI_WDATA,
      S_AXI_WSTRB => S_AXI_WSTRB,
      S_AXI_WVALID => S_AXI_WVALID,
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_BRESP => S_AXI_BRESP,
      S_AXI_BVALID => S_AXI_BVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      S_AXI_ARADDR => S_AXI_ARADDR,
      S_AXI_ARPROT => S_AXI_ARPROT,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_RDATA => S_AXI_RDATA,
      S_AXI_RRESP => S_AXI_RRESP,
      S_AXI_RVALID => S_AXI_RVALID,
      S_AXI_RREADY => S_AXI_RREADY,
      async_rst_o => async_rst_from_AXI,
      fifo_rst_o => fifo_rst_from_AXI,
      debug_enable_o => debug_enable_from_AXI,
      debug_control_o => debug_control_from_AXI,
      debug_w2w1_o => debug_w2w1_from_AXI,
      fifo_rd_en_o => fifo_rd_en_from_AXI,
      fifo_out_i => fifo_out_to_AXI,
      ext_trigger_i => ext_trigger_i
    );

  -- Preprocessing registers
  preprocessing_registers_inst : ENTITY work.eight_regs_block(arch_imp)
    GENERIC MAP(
      CORE_CONTROL => USER_CORE_ID_VER
    )
    PORT MAP(
      S_AXI_ACLK => S_AXI_PREPROC_ACLK,
      S_AXI_ARESETN => S_AXI_PREPROC_ARESETN,
      S_AXI_AWADDR => S_AXI_PREPROC_AWADDR,
      S_AXI_AWPROT => S_AXI_PREPROC_AWPROT,
      S_AXI_AWVALID => S_AXI_PREPROC_AWVALID,
      S_AXI_AWREADY => S_AXI_PREPROC_AWREADY,
      S_AXI_WDATA => S_AXI_PREPROC_WDATA,
      S_AXI_WSTRB => S_AXI_PREPROC_WSTRB,
      S_AXI_WVALID => S_AXI_PREPROC_WVALID,
      S_AXI_WREADY => S_AXI_PREPROC_WREADY,
      S_AXI_BRESP => S_AXI_PREPROC_BRESP,
      S_AXI_BVALID => S_AXI_PREPROC_BVALID,
      S_AXI_BREADY => S_AXI_PREPROC_BREADY,
      S_AXI_ARADDR => S_AXI_PREPROC_ARADDR,
      S_AXI_ARPROT => S_AXI_PREPROC_ARPROT,
      S_AXI_ARVALID => S_AXI_PREPROC_ARVALID,
      S_AXI_ARREADY => S_AXI_PREPROC_ARREADY,
      S_AXI_RDATA => S_AXI_PREPROC_RDATA,
      S_AXI_RRESP => S_AXI_PREPROC_RRESP,
      S_AXI_RVALID => S_AXI_PREPROC_RVALID,
      S_AXI_RREADY => S_AXI_PREPROC_RREADY,
      data_source_selector => data_source_sel,
      ch_1_freq => ch_1_freq,
      ch_2_freq => ch_2_freq,
      ch_3_freq => ch_3_freq,
      ch_4_freq => ch_4_freq,
      ch_5_freq => ch_5_freq
    );

  ---- DELAY CONTROL
  -- instantiate IBUFDS and BUFG for external ref clk, and IDELAYCTRL to control IDELAYs in receivers

  -- BUFG: Global Clock Simple Buffer
  --       Kintex-7
  BUFG_inst_IDELAYCTRL : BUFG
  PORT MAP(
    O => delay_refclk, -- 1-bit output: Clock output
    I => S_AXI_ACLK -- 1-bit input: Clock input
  );

  -- IDELAYCTRL: IDELAYE2/ODELAYE2 Tap Delay Value Control
  --             Kintex-7
  IDELAYCTRL_inst : IDELAYCTRL
  PORT MAP(
    RDY => delay_locked_o, -- 1-bit output: Ready output
    REFCLK => delay_refclk, -- 1-bit input: Reference clock input
    RST => debug_rst -- 1-bit input: Active high reset input
  );

  --receiver for bank12 signals
  --bank12 has DCO2 and FCO2
  adc_receiver1_inst : ENTITY work.adc_receiver(arch)
    GENERIC MAP(
      RES_ADC => RES_ADC,
      N => N1,
      N_tr_b => N_tr_b
    )
    PORT MAP(
      fpga_clk_i => S_AXI_ACLK,
      async_rst_i => debug_rst,

      adc_clk_p_i => adc_DCO2_p_i,
      adc_clk_n_i => adc_DCO2_n_i,
      adc_frame_p_i => adc_FCO2_p_i,
      adc_frame_n_i => adc_FCO2_n_i,
      adc_data_p_i => adc_data_to_r1_p,
      adc_data_n_i => adc_data_to_r1_n,
      adc_FCOlck_o => adc_FCO2lck_o,

      treshold_value_i => treshold_value_i,
      treshold_ld_i => treshold_ld_i,

      debug_enable_i => debug_enable_from_AXI,
      debug_control_i => debug_control_to_r1,
      debug_w2w1_i => debug_w2w1_to_r1,

      fifo_rst_i => fifo_rst,
      fifo_rd_en_i => fifo_rd_en_to_r1,
      fifo_out_o => fifo_out_from_r1,

      delay_refclk_i => delay_refclk,
      delay_data_ld_i => delay_data_ld_to_r1,
      delay_data_input_i => delay_data_input_to_r1,
      delay_data_output_o => delay_data_output_from_r1,
      delay_frame_ld_i => delay_frame1_ld_i,
      delay_frame_input_i => delay_frame1_input_i,
      delay_frame_output_o => delay_frame1_output_o,

      --preprocessing signals
      data_source_sel => data_source_sel,
      ch_1_freq => ch_1_freq,
      ch_2_freq => ch_2_freq,
      ch_3_freq => ch_3_freq,
      ch_4_freq => ch_4_freq,
      ch_5_freq => ch_5_freq
    );

  --receiver for bank13 signals
  --bank13 has DCO1 and FCO1
  adc_receiver2_inst : ENTITY work.adc_receiver(arch)
    GENERIC MAP(
      RES_ADC => RES_ADC,
      N => N2,
      N_tr_b => N_tr_b
    )
    PORT MAP(
      fpga_clk_i => S_AXI_ACLK,
      async_rst_i => debug_rst,

      adc_clk_p_i => adc_DCO1_p_i,
      adc_clk_n_i => adc_DCO1_n_i,
      adc_frame_p_i => adc_FCO1_p_i,
      adc_frame_n_i => adc_FCO1_n_i,
      adc_data_p_i => adc_data_to_r2_p,
      adc_data_n_i => adc_data_to_r2_n,
      adc_FCOlck_o => adc_FCO1lck_o,

      treshold_value_i => treshold_value_i,
      treshold_ld_i => treshold_ld_i,

      debug_enable_i => debug_enable_from_AXI,
      debug_control_i => debug_control_to_r2,
      debug_w2w1_i => debug_w2w1_to_r2,

      fifo_rst_i => fifo_rst,
      fifo_rd_en_i => fifo_rd_en_to_r2,
      fifo_out_o => fifo_out_from_r2,

      delay_refclk_i => delay_refclk,
      delay_data_ld_i => delay_data_ld_to_r2,
      delay_data_input_i => delay_data_input_to_r2,
      delay_data_output_o => delay_data_output_from_r2,
      delay_frame_ld_i => delay_frame2_ld_i,
      delay_frame_input_i => delay_frame2_input_i,
      delay_frame_output_o => delay_frame2_output_o,

      --preprocessing signals
      data_source_sel => data_source_sel,
      ch_1_freq => ch_1_freq,
      ch_2_freq => ch_2_freq,
      ch_3_freq => ch_3_freq,
      ch_4_freq => ch_4_freq,
      ch_5_freq => ch_5_freq
    );

  --reset handling
  fifo_rst <= fifo_rst_from_AXI OR rst_peripherals_i;
  debug_rst <= async_rst_from_AXI OR rst_peripherals_i;

  --debug control mapping
  debug_control_to_r1(3 DOWNTO 0) <= debug_control_from_AXI(3 DOWNTO 0);
  debug_control_to_r1(7 DOWNTO 4) <= debug_control_from_AXI(7 DOWNTO 4);
  debug_control_to_r1(11 DOWNTO 8) <= debug_control_from_AXI(11 DOWNTO 8);
  debug_control_to_r1(15 DOWNTO 12) <= debug_control_from_AXI(15 DOWNTO 12);
  debug_control_to_r1(19 DOWNTO 16) <= debug_control_from_AXI(19 DOWNTO 16);
  debug_control_to_r1(23 DOWNTO 20) <= debug_control_from_AXI(23 DOWNTO 20);
  debug_control_to_r1(27 DOWNTO 24) <= debug_control_from_AXI(27 DOWNTO 24);
  debug_control_to_r1(31 DOWNTO 28) <= debug_control_from_AXI(31 DOWNTO 28);
  debug_control_to_r1(35 DOWNTO 32) <= debug_control_from_AXI(35 DOWNTO 32);
  debug_control_to_r1(39 DOWNTO 36) <= debug_control_from_AXI(39 DOWNTO 36);
  debug_control_to_r1(43 DOWNTO 40) <= debug_control_from_AXI(43 DOWNTO 40);
  debug_control_to_r2(3 DOWNTO 0) <= debug_control_from_AXI(47 DOWNTO 44);
  debug_control_to_r1(47 DOWNTO 44) <= debug_control_from_AXI(51 DOWNTO 48);
  debug_control_to_r1(51 DOWNTO 48) <= debug_control_from_AXI(55 DOWNTO 52);
  debug_control_to_r1(55 DOWNTO 52) <= debug_control_from_AXI(59 DOWNTO 56);
  debug_control_to_r2(7 DOWNTO 4) <= debug_control_from_AXI(63 DOWNTO 60);

  --debug w2w1 mapping
  debug_w2w1_to_r1(27 DOWNTO 0) <= debug_w2w1_from_AXI(27 DOWNTO 0);
  debug_w2w1_to_r1(55 DOWNTO 28) <= debug_w2w1_from_AXI(55 DOWNTO 28);
  debug_w2w1_to_r1(83 DOWNTO 56) <= debug_w2w1_from_AXI(83 DOWNTO 56);
  debug_w2w1_to_r1(111 DOWNTO 84) <= debug_w2w1_from_AXI(111 DOWNTO 84);
  debug_w2w1_to_r1(139 DOWNTO 112) <= debug_w2w1_from_AXI(139 DOWNTO 112);
  debug_w2w1_to_r1(167 DOWNTO 140) <= debug_w2w1_from_AXI(167 DOWNTO 140);
  debug_w2w1_to_r1(195 DOWNTO 168) <= debug_w2w1_from_AXI(195 DOWNTO 168);
  debug_w2w1_to_r1(223 DOWNTO 196) <= debug_w2w1_from_AXI(223 DOWNTO 196);
  debug_w2w1_to_r1(251 DOWNTO 224) <= debug_w2w1_from_AXI(251 DOWNTO 224);
  debug_w2w1_to_r1(279 DOWNTO 252) <= debug_w2w1_from_AXI(279 DOWNTO 252);
  debug_w2w1_to_r1(307 DOWNTO 280) <= debug_w2w1_from_AXI(307 DOWNTO 280);
  debug_w2w1_to_r2(27 DOWNTO 0) <= debug_w2w1_from_AXI(335 DOWNTO 308);
  debug_w2w1_to_r1(335 DOWNTO 308) <= debug_w2w1_from_AXI(363 DOWNTO 336);
  debug_w2w1_to_r1(363 DOWNTO 336) <= debug_w2w1_from_AXI(391 DOWNTO 364);
  debug_w2w1_to_r1(391 DOWNTO 364) <= debug_w2w1_from_AXI(419 DOWNTO 392);
  debug_w2w1_to_r2(55 DOWNTO 28) <= debug_w2w1_from_AXI(447 DOWNTO 420);

  --FIFO rd_en mapping
  fifo_rd_en_to_r1(0 DOWNTO 0) <= fifo_rd_en_from_AXI(0 DOWNTO 0);
  fifo_rd_en_to_r1(1 DOWNTO 1) <= fifo_rd_en_from_AXI(1 DOWNTO 1);
  fifo_rd_en_to_r1(2 DOWNTO 2) <= fifo_rd_en_from_AXI(2 DOWNTO 2);
  fifo_rd_en_to_r1(3 DOWNTO 3) <= fifo_rd_en_from_AXI(3 DOWNTO 3);
  fifo_rd_en_to_r1(4 DOWNTO 4) <= fifo_rd_en_from_AXI(4 DOWNTO 4);
  fifo_rd_en_to_r1(5 DOWNTO 5) <= fifo_rd_en_from_AXI(5 DOWNTO 5);
  fifo_rd_en_to_r1(6 DOWNTO 6) <= fifo_rd_en_from_AXI(6 DOWNTO 6);
  fifo_rd_en_to_r1(7 DOWNTO 7) <= fifo_rd_en_from_AXI(7 DOWNTO 7);
  fifo_rd_en_to_r1(8 DOWNTO 8) <= fifo_rd_en_from_AXI(8 DOWNTO 8);
  fifo_rd_en_to_r1(9 DOWNTO 9) <= fifo_rd_en_from_AXI(9 DOWNTO 9);
  fifo_rd_en_to_r1(10 DOWNTO 10) <= fifo_rd_en_from_AXI(10 DOWNTO 10);
  fifo_rd_en_to_r2(0 DOWNTO 0) <= fifo_rd_en_from_AXI(11 DOWNTO 11);
  fifo_rd_en_to_r1(11 DOWNTO 11) <= fifo_rd_en_from_AXI(12 DOWNTO 12);
  fifo_rd_en_to_r1(12 DOWNTO 12) <= fifo_rd_en_from_AXI(13 DOWNTO 13);
  fifo_rd_en_to_r1(13 DOWNTO 13) <= fifo_rd_en_from_AXI(14 DOWNTO 14);
  fifo_rd_en_to_r2(1 DOWNTO 1) <= fifo_rd_en_from_AXI(15 DOWNTO 15);

  --FIFO out mapping
  fifo_out_to_AXI(0 DOWNTO 0) <= fifo_out_from_r1(0 DOWNTO 0);
  fifo_out_to_AXI(1 DOWNTO 1) <= fifo_out_from_r1(1 DOWNTO 1);
  fifo_out_to_AXI(2 DOWNTO 2) <= fifo_out_from_r1(2 DOWNTO 2);
  fifo_out_to_AXI(3 DOWNTO 3) <= fifo_out_from_r1(3 DOWNTO 3);
  fifo_out_to_AXI(4 DOWNTO 4) <= fifo_out_from_r1(4 DOWNTO 4);
  fifo_out_to_AXI(5 DOWNTO 5) <= fifo_out_from_r1(5 DOWNTO 5);
  fifo_out_to_AXI(6 DOWNTO 6) <= fifo_out_from_r1(6 DOWNTO 6);
  fifo_out_to_AXI(7 DOWNTO 7) <= fifo_out_from_r1(7 DOWNTO 7);
  fifo_out_to_AXI(8 DOWNTO 8) <= fifo_out_from_r1(8 DOWNTO 8);
  fifo_out_to_AXI(9 DOWNTO 9) <= fifo_out_from_r1(9 DOWNTO 9);
  fifo_out_to_AXI(10 DOWNTO 10) <= fifo_out_from_r1(10 DOWNTO 10);
  fifo_out_to_AXI(11 DOWNTO 11) <= fifo_out_from_r2(0 DOWNTO 0);
  fifo_out_to_AXI(12 DOWNTO 12) <= fifo_out_from_r1(11 DOWNTO 11);
  fifo_out_to_AXI(13 DOWNTO 13) <= fifo_out_from_r1(12 DOWNTO 12);
  fifo_out_to_AXI(14 DOWNTO 14) <= fifo_out_from_r1(13 DOWNTO 13);
  fifo_out_to_AXI(15 DOWNTO 15) <= fifo_out_from_r2(1 DOWNTO 1);

  --ADC data mapping
  adc_data_to_r1_p(0 DOWNTO 0) <= adc_data_p_i(0 DOWNTO 0);
  adc_data_to_r1_p(1 DOWNTO 1) <= adc_data_p_i(1 DOWNTO 1);
  adc_data_to_r1_p(2 DOWNTO 2) <= adc_data_p_i(2 DOWNTO 2);
  adc_data_to_r1_p(3 DOWNTO 3) <= adc_data_p_i(3 DOWNTO 3);
  adc_data_to_r1_p(4 DOWNTO 4) <= adc_data_p_i(4 DOWNTO 4);
  adc_data_to_r1_p(5 DOWNTO 5) <= adc_data_p_i(5 DOWNTO 5);
  adc_data_to_r1_p(6 DOWNTO 6) <= adc_data_p_i(6 DOWNTO 6);
  adc_data_to_r1_p(7 DOWNTO 7) <= adc_data_p_i(7 DOWNTO 7);
  adc_data_to_r1_p(8 DOWNTO 8) <= adc_data_p_i(8 DOWNTO 8);
  adc_data_to_r1_p(9 DOWNTO 9) <= adc_data_p_i(9 DOWNTO 9);
  adc_data_to_r1_p(10 DOWNTO 10) <= adc_data_p_i(10 DOWNTO 10);
  adc_data_to_r2_p(0 DOWNTO 0) <= adc_data_p_i(11 DOWNTO 11);
  adc_data_to_r1_p(11 DOWNTO 11) <= adc_data_p_i(12 DOWNTO 12);
  adc_data_to_r1_p(12 DOWNTO 12) <= adc_data_p_i(13 DOWNTO 13);
  adc_data_to_r1_p(13 DOWNTO 13) <= adc_data_p_i(14 DOWNTO 14);
  adc_data_to_r2_p(1 DOWNTO 1) <= adc_data_p_i(15 DOWNTO 15);
  adc_data_to_r1_n(0 DOWNTO 0) <= adc_data_n_i(0 DOWNTO 0);
  adc_data_to_r1_n(1 DOWNTO 1) <= adc_data_n_i(1 DOWNTO 1);
  adc_data_to_r1_n(2 DOWNTO 2) <= adc_data_n_i(2 DOWNTO 2);
  adc_data_to_r1_n(3 DOWNTO 3) <= adc_data_n_i(3 DOWNTO 3);
  adc_data_to_r1_n(4 DOWNTO 4) <= adc_data_n_i(4 DOWNTO 4);
  adc_data_to_r1_n(5 DOWNTO 5) <= adc_data_n_i(5 DOWNTO 5);
  adc_data_to_r1_n(6 DOWNTO 6) <= adc_data_n_i(6 DOWNTO 6);
  adc_data_to_r1_n(7 DOWNTO 7) <= adc_data_n_i(7 DOWNTO 7);
  adc_data_to_r1_n(8 DOWNTO 8) <= adc_data_n_i(8 DOWNTO 8);
  adc_data_to_r1_n(9 DOWNTO 9) <= adc_data_n_i(9 DOWNTO 9);
  adc_data_to_r1_n(10 DOWNTO 10) <= adc_data_n_i(10 DOWNTO 10);
  adc_data_to_r2_n(0 DOWNTO 0) <= adc_data_n_i(11 DOWNTO 11);
  adc_data_to_r1_n(11 DOWNTO 11) <= adc_data_n_i(12 DOWNTO 12);
  adc_data_to_r1_n(12 DOWNTO 12) <= adc_data_n_i(13 DOWNTO 13);
  adc_data_to_r1_n(13 DOWNTO 13) <= adc_data_n_i(14 DOWNTO 14);
  adc_data_to_r2_n(1 DOWNTO 1) <= adc_data_n_i(15 DOWNTO 15);

  --delay data ld mapping
  delay_data_ld_to_r1(0 DOWNTO 0) <= delay_data_ld_i(0 DOWNTO 0);
  delay_data_ld_to_r1(1 DOWNTO 1) <= delay_data_ld_i(1 DOWNTO 1);
  delay_data_ld_to_r1(2 DOWNTO 2) <= delay_data_ld_i(2 DOWNTO 2);
  delay_data_ld_to_r1(3 DOWNTO 3) <= delay_data_ld_i(3 DOWNTO 3);
  delay_data_ld_to_r1(4 DOWNTO 4) <= delay_data_ld_i(4 DOWNTO 4);
  delay_data_ld_to_r1(5 DOWNTO 5) <= delay_data_ld_i(5 DOWNTO 5);
  delay_data_ld_to_r1(6 DOWNTO 6) <= delay_data_ld_i(6 DOWNTO 6);
  delay_data_ld_to_r1(7 DOWNTO 7) <= delay_data_ld_i(7 DOWNTO 7);
  delay_data_ld_to_r1(8 DOWNTO 8) <= delay_data_ld_i(8 DOWNTO 8);
  delay_data_ld_to_r1(9 DOWNTO 9) <= delay_data_ld_i(9 DOWNTO 9);
  delay_data_ld_to_r1(10 DOWNTO 10) <= delay_data_ld_i(10 DOWNTO 10);
  delay_data_ld_to_r2(0 DOWNTO 0) <= delay_data_ld_i(11 DOWNTO 11);
  delay_data_ld_to_r1(11 DOWNTO 11) <= delay_data_ld_i(12 DOWNTO 12);
  delay_data_ld_to_r1(12 DOWNTO 12) <= delay_data_ld_i(13 DOWNTO 13);
  delay_data_ld_to_r1(13 DOWNTO 13) <= delay_data_ld_i(14 DOWNTO 14);
  delay_data_ld_to_r2(1 DOWNTO 1) <= delay_data_ld_i(15 DOWNTO 15);

  --delay data input mapping
  delay_data_input_to_r1(4 DOWNTO 0) <= delay_data_input_i(4 DOWNTO 0);
  delay_data_input_to_r1(9 DOWNTO 5) <= delay_data_input_i(9 DOWNTO 5);
  delay_data_input_to_r1(14 DOWNTO 10) <= delay_data_input_i(14 DOWNTO 10);
  delay_data_input_to_r1(19 DOWNTO 15) <= delay_data_input_i(19 DOWNTO 15);
  delay_data_input_to_r1(24 DOWNTO 20) <= delay_data_input_i(24 DOWNTO 20);
  delay_data_input_to_r1(29 DOWNTO 25) <= delay_data_input_i(29 DOWNTO 25);
  delay_data_input_to_r1(34 DOWNTO 30) <= delay_data_input_i(34 DOWNTO 30);
  delay_data_input_to_r1(39 DOWNTO 35) <= delay_data_input_i(39 DOWNTO 35);
  delay_data_input_to_r1(44 DOWNTO 40) <= delay_data_input_i(44 DOWNTO 40);
  delay_data_input_to_r1(49 DOWNTO 45) <= delay_data_input_i(49 DOWNTO 45);
  delay_data_input_to_r1(54 DOWNTO 50) <= delay_data_input_i(54 DOWNTO 50);
  delay_data_input_to_r2(4 DOWNTO 0) <= delay_data_input_i(59 DOWNTO 55);
  delay_data_input_to_r1(59 DOWNTO 55) <= delay_data_input_i(64 DOWNTO 60);
  delay_data_input_to_r1(64 DOWNTO 60) <= delay_data_input_i(69 DOWNTO 65);
  delay_data_input_to_r1(69 DOWNTO 65) <= delay_data_input_i(74 DOWNTO 70);
  delay_data_input_to_r2(9 DOWNTO 5) <= delay_data_input_i(79 DOWNTO 75);

  --delay data output mapping
  delay_data_output_o(4 DOWNTO 0) <= delay_data_output_from_r1(4 DOWNTO 0);
  delay_data_output_o(9 DOWNTO 5) <= delay_data_output_from_r1(9 DOWNTO 5);
  delay_data_output_o(14 DOWNTO 10) <= delay_data_output_from_r1(14 DOWNTO 10);
  delay_data_output_o(19 DOWNTO 15) <= delay_data_output_from_r1(19 DOWNTO 15);
  delay_data_output_o(24 DOWNTO 20) <= delay_data_output_from_r1(24 DOWNTO 20);
  delay_data_output_o(29 DOWNTO 25) <= delay_data_output_from_r1(29 DOWNTO 25);
  delay_data_output_o(34 DOWNTO 30) <= delay_data_output_from_r1(34 DOWNTO 30);
  delay_data_output_o(39 DOWNTO 35) <= delay_data_output_from_r1(39 DOWNTO 35);
  delay_data_output_o(44 DOWNTO 40) <= delay_data_output_from_r1(44 DOWNTO 40);
  delay_data_output_o(49 DOWNTO 45) <= delay_data_output_from_r1(49 DOWNTO 45);
  delay_data_output_o(54 DOWNTO 50) <= delay_data_output_from_r1(54 DOWNTO 50);
  delay_data_output_o(59 DOWNTO 55) <= delay_data_output_from_r2(4 DOWNTO 0);
  delay_data_output_o(64 DOWNTO 60) <= delay_data_output_from_r1(59 DOWNTO 55);
  delay_data_output_o(69 DOWNTO 65) <= delay_data_output_from_r1(64 DOWNTO 60);
  delay_data_output_o(74 DOWNTO 70) <= delay_data_output_from_r1(69 DOWNTO 65);
  delay_data_output_o(79 DOWNTO 75) <= delay_data_output_from_r2(9 DOWNTO 5);

END arch; -- arch