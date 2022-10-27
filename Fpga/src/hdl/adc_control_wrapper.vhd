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
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

use work.fifo_record_pkg.all;

entity adc_control_wrapper is
  generic (
    -- Core ID and version
    USER_CORE_ID_VER : std_logic_vector(31 downto 0) := X"00020003";
    N                : integer                       := 16;          --number of ADC channels
    N1               : integer                       := 14;          --number of ADC channels in receiver 1
    N2               : integer                       := 2;           --number of ADC channels in receiver 2
    RES_ADC          : integer                       := 14;          --ADC bit resolution
    FIFO_EMPTY_VAL   : std_logic_vector(31 downto 0) := X"00000DEF"; --output value when attempting to read from empty FIFO
    N_tr_b           : integer                       := 10           --bits for downsampler treshold register
  );
  port (
    --AXI interface
    S_AXI_ACLK            : in std_logic;
    S_AXI_ARESETN         : in std_logic;
    S_AXI_AWADDR          : in std_logic_vector(10 - 1 downto 0);
    S_AXI_AWPROT          : in std_logic_vector(2 downto 0);
    S_AXI_AWVALID         : in std_logic;
    S_AXI_AWREADY         : out std_logic;
    S_AXI_WDATA           : in std_logic_vector(32 - 1 downto 0);
    S_AXI_WSTRB           : in std_logic_vector((32/8) - 1 downto 0);
    S_AXI_WVALID          : in std_logic;
    S_AXI_WREADY          : out std_logic;
    S_AXI_BRESP           : out std_logic_vector(1 downto 0);
    S_AXI_BVALID          : out std_logic;
    S_AXI_BREADY          : in std_logic;
    S_AXI_ARADDR          : in std_logic_vector(10 - 1 downto 0);
    S_AXI_ARPROT          : in std_logic_vector(2 downto 0);
    S_AXI_ARVALID         : in std_logic;
    S_AXI_ARREADY         : out std_logic;
    S_AXI_RDATA           : out std_logic_vector(32 - 1 downto 0);
    S_AXI_RRESP           : out std_logic_vector(1 downto 0);
    S_AXI_RVALID          : out std_logic;
    S_AXI_RREADY          : in std_logic;

    --AXI interface for preprocessing regs
    S_AXI_PREPROC_ACLK    : in std_logic;
    S_AXI_PREPROC_ARESETN : in std_logic;
    S_AXI_PREPROC_AWADDR  : in std_logic_vector(5 - 1 downto 0);
    S_AXI_PREPROC_AWPROT  : in std_logic_vector(2 downto 0);
    S_AXI_PREPROC_AWVALID : in std_logic;
    S_AXI_PREPROC_AWREADY : out std_logic;
    S_AXI_PREPROC_WDATA   : in std_logic_vector(32 - 1 downto 0);
    S_AXI_PREPROC_WSTRB   : in std_logic_vector((32/8) - 1 downto 0);
    S_AXI_PREPROC_WVALID  : in std_logic;
    S_AXI_PREPROC_WREADY  : out std_logic;
    S_AXI_PREPROC_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_PREPROC_BVALID  : out std_logic;
    S_AXI_PREPROC_BREADY  : in std_logic;
    S_AXI_PREPROC_ARADDR  : in std_logic_vector(5 - 1 downto 0);
    S_AXI_PREPROC_ARPROT  : in std_logic_vector(2 downto 0);
    S_AXI_PREPROC_ARVALID : in std_logic;
    S_AXI_PREPROC_ARREADY : out std_logic;
    S_AXI_PREPROC_RDATA   : out std_logic_vector(32 - 1 downto 0);
    S_AXI_PREPROC_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_PREPROC_RVALID  : out std_logic;
    S_AXI_PREPROC_RREADY  : in std_logic;

    --external reset for peripherals
    rst_peripherals_i     : in std_logic;

    --ADC signals
    adc_DCO1_p_i          : in std_logic;
    adc_DCO1_n_i          : in std_logic;
    adc_DCO2_p_i          : in std_logic;
    adc_DCO2_n_i          : in std_logic;
    adc_FCO1_p_i          : in std_logic;
    adc_FCO1_n_i          : in std_logic;
    adc_FCO2_p_i          : in std_logic;
    adc_FCO2_n_i          : in std_logic;
    adc_data_p_i          : in std_logic_vector((N - 1) downto 0);
    adc_data_n_i          : in std_logic_vector((N - 1) downto 0);
    adc_FCO1lck_o         : out std_logic;
    adc_FCO2lck_o         : out std_logic;

    --downsampler control signals
    treshold_value_i      : in std_logic_vector((N_tr_b - 1) downto 0);
    treshold_ld_i         : in std_logic;

    --delay control signals
    delay_locked_o        : out std_logic;
    delay_data_ld_i       : in std_logic_vector((N - 1) downto 0);
    delay_data_input_i    : in std_logic_vector((5 * N - 1) downto 0);
    delay_data_output_o   : out std_logic_vector((5 * N - 1) downto 0);
    delay_frame1_ld_i     : in std_logic;
    delay_frame1_input_i  : in std_logic_vector((5 - 1) downto 0);
    delay_frame1_output_o : out std_logic_vector((5 - 1) downto 0);
    delay_frame2_ld_i     : in std_logic;
    delay_frame2_input_i  : in std_logic_vector((5 - 1) downto 0);
    delay_frame2_output_o : out std_logic_vector((5 - 1) downto 0);

    --external trigger signal
    ext_trigger_i         : in std_logic
  );
end adc_control_wrapper;

architecture arch of adc_control_wrapper is
  --Xilinx attributes
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_DCO1_p_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO1_i CLK_P";
  attribute X_INTERFACE_INFO of adc_DCO1_n_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO1_i CLK_N";
  attribute X_INTERFACE_INFO of adc_DCO2_p_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO2_i CLK_P";
  attribute X_INTERFACE_INFO of adc_DCO2_n_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO2_i CLK_N";
  attribute X_INTERFACE_INFO of adc_FCO1_p_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO1_i V_P";
  attribute X_INTERFACE_INFO of adc_FCO1_n_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO1_i V_N";
  attribute X_INTERFACE_INFO of adc_FCO2_p_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO2_i V_P";
  attribute X_INTERFACE_INFO of adc_FCO2_n_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO2_i V_N";
  attribute X_INTERFACE_INFO of adc_data_p_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_data_i V_P";
  attribute X_INTERFACE_INFO of adc_data_n_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_data_i V_N";
  attribute X_INTERFACE_INFO of rst_peripherals_i : signal is "xilinx.com:signal:reset:1.0 rst_peripherals_i RST";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of rst_peripherals_i : signal is "POLARITY ACTIVE_HIGH";

  --label must be the same as label in idelay_wrapper.vhd
  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of IDELAYCTRL_inst : label is "Reception_Delays";

  signal async_rst_from_AXI, fifo_rst_from_AXI, fifo_rst, debug_rst : std_logic := '0';
  signal debug_enable_from_AXI : std_logic := '0';
  signal debug_control_from_AXI : std_logic_vector((N * 4 - 1) downto 0) := (others => '0');
  signal debug_control_to_r1 : std_logic_vector((N1 * 4 - 1) downto 0) := (others => '0');
  signal debug_control_to_r2 : std_logic_vector((N2 * 4 - 1) downto 0) := (others => '0');
  signal debug_w2w1_from_AXI : std_logic_vector((28 * N - 1) downto 0) := (others => '0');
  signal debug_w2w1_to_r1 : std_logic_vector((28 * N1 - 1) downto 0) := (others => '0');
  signal debug_w2w1_to_r2 : std_logic_vector((28 * N2 - 1) downto 0) := (others => '0');
  signal fifo_rd_en_from_AXI : std_logic_vector((N - 1) downto 0) := (others => '0');
  signal fifo_rd_en_to_r1 : std_logic_vector((N1 - 1) downto 0) := (others => '0');
  signal fifo_rd_en_to_r2 : std_logic_vector((N2 - 1) downto 0) := (others => '0');
  signal fifo_out_to_AXI : fifo_out_vector_t((N - 1) downto 0);
  signal fifo_out_from_r1 : fifo_out_vector_t((N1 - 1) downto 0);
  signal fifo_out_from_r2 : fifo_out_vector_t((N2 - 1) downto 0);
  signal adc_data_to_r1_p, adc_data_to_r1_n : std_logic_vector((N1 - 1) downto 0) := (others => '0');
  signal adc_data_to_r2_p, adc_data_to_r2_n : std_logic_vector((N2 - 1) downto 0) := (others => '0');
  signal delay_data_ld_to_r1 : std_logic_vector((N1 - 1) downto 0) := (others => '0');
  signal delay_data_ld_to_r2 : std_logic_vector((N2 - 1) downto 0) := (others => '0');
  signal delay_data_input_to_r1, delay_data_output_from_r1 : std_logic_vector((5 * N1 - 1) downto 0) := (others => '0');
  signal delay_data_input_to_r2, delay_data_output_from_r2 : std_logic_vector((5 * N2 - 1) downto 0) := (others => '0');
  signal delay_refclk : std_logic;

  --preprocessing signals
  signal fifo_input_mux_sel : std_logic_vector(2 downto 0);
  signal data_source_sel : std_logic_vector(1 downto 0) := (others => '0');
  signal ch_1_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_1_valid : std_logic := '0';
  signal ch_2_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_2_valid : std_logic := '0';
  signal ch_3_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_3_valid : std_logic := '0';
  signal ch_4_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_4_valid : std_logic := '0';
  signal ch_5_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_5_valid : std_logic := '0';

begin

  data_control_inst : entity work.data_control(rtl)
    generic map(
      USER_CORE_ID_VER => USER_CORE_ID_VER,
      N                => N,
      FIFO_EMPTY_VAL   => FIFO_EMPTY_VAL
    )
    port map(
      S_AXI_ACLK      => S_AXI_ACLK,    --: in std_logic;
      S_AXI_ARESETN   => S_AXI_ARESETN, -- in std_logic;
      S_AXI_AWADDR    => S_AXI_AWADDR,  --: in std_logic_vector(10-1 downto 0);
      S_AXI_AWPROT    => S_AXI_AWPROT,  --: in std_logic_vector(2 downto 0);
      S_AXI_AWVALID   => S_AXI_AWVALID, --: in std_logic;
      S_AXI_AWREADY   => S_AXI_AWREADY, -- : out std_logic;
      S_AXI_WDATA     => S_AXI_WDATA,
      S_AXI_WSTRB     => S_AXI_WSTRB,
      S_AXI_WVALID    => S_AXI_WVALID,
      S_AXI_WREADY    => S_AXI_WREADY,
      S_AXI_BRESP     => S_AXI_BRESP,
      S_AXI_BVALID    => S_AXI_BVALID,
      S_AXI_BREADY    => S_AXI_BREADY,
      S_AXI_ARADDR    => S_AXI_ARADDR,
      S_AXI_ARPROT    => S_AXI_ARPROT,
      S_AXI_ARVALID   => S_AXI_ARVALID,
      S_AXI_ARREADY   => S_AXI_ARREADY,
      S_AXI_RDATA     => S_AXI_RDATA,
      S_AXI_RRESP     => S_AXI_RRESP,
      S_AXI_RVALID    => S_AXI_RVALID,
      S_AXI_RREADY    => S_AXI_RREADY,
      async_rst_o     => async_rst_from_AXI,
      fifo_rst_o      => fifo_rst_from_AXI,
      debug_enable_o  => debug_enable_from_AXI,
      debug_control_o => debug_control_from_AXI,
      debug_w2w1_o    => debug_w2w1_from_AXI,
      fifo_rd_en_o    => fifo_rd_en_from_AXI,
      fifo_out_i      => fifo_out_to_AXI,
      ext_trigger_i   => ext_trigger_i
    );

  -- Preprocessing registers
  preprocessing_registers_inst : entity work.eight_regs_block(arch_imp)
    generic map(
      CORE_CONTROL => USER_CORE_ID_VER
    )
    port map(
      S_AXI_ACLK           => S_AXI_PREPROC_ACLK,
      S_AXI_ARESETN        => S_AXI_PREPROC_ARESETN,
      S_AXI_AWADDR         => S_AXI_PREPROC_AWADDR,
      S_AXI_AWPROT         => S_AXI_PREPROC_AWPROT,
      S_AXI_AWVALID        => S_AXI_PREPROC_AWVALID,
      S_AXI_AWREADY        => S_AXI_PREPROC_AWREADY,
      S_AXI_WDATA          => S_AXI_PREPROC_WDATA,
      S_AXI_WSTRB          => S_AXI_PREPROC_WSTRB,
      S_AXI_WVALID         => S_AXI_PREPROC_WVALID,
      S_AXI_WREADY         => S_AXI_PREPROC_WREADY,
      S_AXI_BRESP          => S_AXI_PREPROC_BRESP,
      S_AXI_BVALID         => S_AXI_PREPROC_BVALID,
      S_AXI_BREADY         => S_AXI_PREPROC_BREADY,
      S_AXI_ARADDR         => S_AXI_PREPROC_ARADDR,
      S_AXI_ARPROT         => S_AXI_PREPROC_ARPROT,
      S_AXI_ARVALID        => S_AXI_PREPROC_ARVALID,
      S_AXI_ARREADY        => S_AXI_PREPROC_ARREADY,
      S_AXI_RDATA          => S_AXI_PREPROC_RDATA,
      S_AXI_RRESP          => S_AXI_PREPROC_RRESP,
      S_AXI_RVALID         => S_AXI_PREPROC_RVALID,
      S_AXI_RREADY         => S_AXI_PREPROC_RREADY,
      fifo_input_mux_o     => fifo_input_mux_sel,
      data_source_selector => data_source_sel,

      --TODO: Hacer CDC para estas señales
      --Como el AXI_clk es de 200 MHz, y el preproc es 260 MHz, no debería haber problema
      --De todas formas, hay que hacerlo
      ch_1_freq_data       => ch_1_freq,
      ch_1_freq_valid      => ch_1_valid,
      ch_2_freq_data       => ch_2_freq,
      ch_2_freq_valid      => ch_2_valid,
      ch_3_freq_data       => ch_3_freq,
      ch_3_freq_valid      => ch_3_valid,
      ch_4_freq_data       => ch_4_freq,
      ch_4_freq_valid      => ch_4_valid,
      ch_5_freq_data       => ch_5_freq,
      ch_5_freq_valid      => ch_5_valid
    );

  --CRC block

  ---- DELAY CONTROL
  -- instantiate IBUFDS and BUFG for external ref clk, and IDELAYCTRL to control IDELAYs in receivers

  -- BUFG: Global Clock Simple Buffer
  --       Kintex-7
  BUFG_inst_IDELAYCTRL : BUFG
  port map(
    O => delay_refclk, -- 1-bit output: Clock output
    I => S_AXI_ACLK    -- 1-bit input: Clock input
  );

  -- IDELAYCTRL: IDELAYE2/ODELAYE2 Tap Delay Value Control
  --             Kintex-7
  IDELAYCTRL_inst : IDELAYCTRL
  port map(
    RDY    => delay_locked_o, -- 1-bit output: Ready output
    REFCLK => delay_refclk,   -- 1-bit input: Reference clock input
    RST    => debug_rst       -- 1-bit input: Active high reset input
  );

  --receiver for bank12 signals
  --bank12 has DCO2 and FCO2
  adc_receiver1_inst : entity work.adc_receiver(arch)
    generic map(
      RES_ADC => RES_ADC,
      N       => N1,
      N_tr_b  => N_tr_b
    )
    port map(
      fpga_clk_i           => S_AXI_ACLK,
      async_rst_i          => debug_rst,

      adc_clk_p_i          => adc_DCO2_p_i,
      adc_clk_n_i          => adc_DCO2_n_i,
      adc_frame_p_i        => adc_FCO2_p_i,
      adc_frame_n_i        => adc_FCO2_n_i,
      adc_data_p_i         => adc_data_to_r1_p,
      adc_data_n_i         => adc_data_to_r1_n,
      adc_FCOlck_o         => adc_FCO2lck_o,

      treshold_value_i     => treshold_value_i,
      treshold_ld_i        => treshold_ld_i,

      debug_enable_i       => debug_enable_from_AXI,
      debug_control_i      => debug_control_to_r1,
      debug_w2w1_i         => debug_w2w1_to_r1,

      fifo_rst_i           => fifo_rst,
      fifo_rd_en_i         => fifo_rd_en_to_r1,
      fifo_out_o           => fifo_out_from_r1,

      delay_refclk_i       => delay_refclk,
      delay_data_ld_i      => delay_data_ld_to_r1,
      delay_data_input_i   => delay_data_input_to_r1,
      delay_data_output_o  => delay_data_output_from_r1,
      delay_frame_ld_i     => delay_frame1_ld_i,
      delay_frame_input_i  => delay_frame1_input_i,
      delay_frame_output_o => delay_frame1_output_o,

      --preprocessing signals
      fifo_input_mux_sel_i => fifo_input_mux_sel,
      data_source_sel_i    => data_source_sel,
      ch_1_freq_i          => ch_1_freq,
      ch_1_freq_valid_i    => ch_1_valid,
      ch_2_freq_i          => ch_2_freq,
      ch_2_freq_valid_i    => ch_2_valid,
      ch_3_freq_i          => ch_3_freq,
      ch_3_freq_valid_i    => ch_3_valid,
      ch_4_freq_i          => ch_4_freq,
      ch_4_freq_valid_i    => ch_4_valid,
      ch_5_freq_i          => ch_5_freq,
      ch_5_freq_valid_i    => ch_5_valid
    );

  --receiver for bank13 signals
  --bank13 has DCO1 and FCO1
  adc_receiver2_inst : entity work.adc_receiver(arch)
    generic map(
      RES_ADC => RES_ADC,
      N       => N2,
      N_tr_b  => N_tr_b
    )
    port map(
      fpga_clk_i           => S_AXI_ACLK,
      async_rst_i          => debug_rst,

      adc_clk_p_i          => adc_DCO1_p_i,
      adc_clk_n_i          => adc_DCO1_n_i,
      adc_frame_p_i        => adc_FCO1_p_i,
      adc_frame_n_i        => adc_FCO1_n_i,
      adc_data_p_i         => adc_data_to_r2_p,
      adc_data_n_i         => adc_data_to_r2_n,
      adc_FCOlck_o         => adc_FCO1lck_o,

      treshold_value_i     => treshold_value_i,
      treshold_ld_i        => treshold_ld_i,

      debug_enable_i       => debug_enable_from_AXI,
      debug_control_i      => debug_control_to_r2,
      debug_w2w1_i         => debug_w2w1_to_r2,

      fifo_rst_i           => fifo_rst,
      fifo_rd_en_i         => fifo_rd_en_to_r2,
      fifo_out_o           => fifo_out_from_r2,

      delay_refclk_i       => delay_refclk,
      delay_data_ld_i      => delay_data_ld_to_r2,
      delay_data_input_i   => delay_data_input_to_r2,
      delay_data_output_o  => delay_data_output_from_r2,
      delay_frame_ld_i     => delay_frame2_ld_i,
      delay_frame_input_i  => delay_frame2_input_i,
      delay_frame_output_o => delay_frame2_output_o,

      --preprocessing signals
      fifo_input_mux_sel_i => fifo_input_mux_sel,
      data_source_sel_i    => data_source_sel,
      ch_1_freq_i          => ch_1_freq,
      ch_1_freq_valid_i    => ch_1_valid,
      ch_2_freq_i          => ch_2_freq,
      ch_2_freq_valid_i    => ch_2_valid,
      ch_3_freq_i          => ch_3_freq,
      ch_3_freq_valid_i    => ch_3_valid,
      ch_4_freq_i          => ch_4_freq,
      ch_4_freq_valid_i    => ch_4_valid,
      ch_5_freq_i          => ch_5_freq,
      ch_5_freq_valid_i    => ch_5_valid
    );

  --reset handling
  fifo_rst <= fifo_rst_from_AXI or rst_peripherals_i;
  debug_rst <= async_rst_from_AXI or rst_peripherals_i;

  --debug control mapping
  debug_control_to_r1(3 downto 0) <= debug_control_from_AXI(3 downto 0);
  debug_control_to_r1(7 downto 4) <= debug_control_from_AXI(7 downto 4);
  debug_control_to_r1(11 downto 8) <= debug_control_from_AXI(11 downto 8);
  debug_control_to_r1(15 downto 12) <= debug_control_from_AXI(15 downto 12);
  debug_control_to_r1(19 downto 16) <= debug_control_from_AXI(19 downto 16);
  debug_control_to_r1(23 downto 20) <= debug_control_from_AXI(23 downto 20);
  debug_control_to_r1(27 downto 24) <= debug_control_from_AXI(27 downto 24);
  debug_control_to_r1(31 downto 28) <= debug_control_from_AXI(31 downto 28);
  debug_control_to_r1(35 downto 32) <= debug_control_from_AXI(35 downto 32);
  debug_control_to_r1(39 downto 36) <= debug_control_from_AXI(39 downto 36);
  debug_control_to_r1(43 downto 40) <= debug_control_from_AXI(43 downto 40);
  debug_control_to_r2(3 downto 0) <= debug_control_from_AXI(47 downto 44);
  debug_control_to_r1(47 downto 44) <= debug_control_from_AXI(51 downto 48);
  debug_control_to_r1(51 downto 48) <= debug_control_from_AXI(55 downto 52);
  debug_control_to_r1(55 downto 52) <= debug_control_from_AXI(59 downto 56);
  debug_control_to_r2(7 downto 4) <= debug_control_from_AXI(63 downto 60);

  --debug w2w1 mapping
  debug_w2w1_to_r1(27 downto 0) <= debug_w2w1_from_AXI(27 downto 0);
  debug_w2w1_to_r1(55 downto 28) <= debug_w2w1_from_AXI(55 downto 28);
  debug_w2w1_to_r1(83 downto 56) <= debug_w2w1_from_AXI(83 downto 56);
  debug_w2w1_to_r1(111 downto 84) <= debug_w2w1_from_AXI(111 downto 84);
  debug_w2w1_to_r1(139 downto 112) <= debug_w2w1_from_AXI(139 downto 112);
  debug_w2w1_to_r1(167 downto 140) <= debug_w2w1_from_AXI(167 downto 140);
  debug_w2w1_to_r1(195 downto 168) <= debug_w2w1_from_AXI(195 downto 168);
  debug_w2w1_to_r1(223 downto 196) <= debug_w2w1_from_AXI(223 downto 196);
  debug_w2w1_to_r1(251 downto 224) <= debug_w2w1_from_AXI(251 downto 224);
  debug_w2w1_to_r1(279 downto 252) <= debug_w2w1_from_AXI(279 downto 252);
  debug_w2w1_to_r1(307 downto 280) <= debug_w2w1_from_AXI(307 downto 280);
  debug_w2w1_to_r2(27 downto 0) <= debug_w2w1_from_AXI(335 downto 308);
  debug_w2w1_to_r1(335 downto 308) <= debug_w2w1_from_AXI(363 downto 336);
  debug_w2w1_to_r1(363 downto 336) <= debug_w2w1_from_AXI(391 downto 364);
  debug_w2w1_to_r1(391 downto 364) <= debug_w2w1_from_AXI(419 downto 392);
  debug_w2w1_to_r2(55 downto 28) <= debug_w2w1_from_AXI(447 downto 420);

  --FIFO rd_en mapping
  fifo_rd_en_to_r1(0 downto 0) <= fifo_rd_en_from_AXI(0 downto 0);
  fifo_rd_en_to_r1(1 downto 1) <= fifo_rd_en_from_AXI(1 downto 1);
  fifo_rd_en_to_r1(2 downto 2) <= fifo_rd_en_from_AXI(2 downto 2);
  fifo_rd_en_to_r1(3 downto 3) <= fifo_rd_en_from_AXI(3 downto 3);
  fifo_rd_en_to_r1(4 downto 4) <= fifo_rd_en_from_AXI(4 downto 4);
  fifo_rd_en_to_r1(5 downto 5) <= fifo_rd_en_from_AXI(5 downto 5);
  fifo_rd_en_to_r1(6 downto 6) <= fifo_rd_en_from_AXI(6 downto 6);
  fifo_rd_en_to_r1(7 downto 7) <= fifo_rd_en_from_AXI(7 downto 7);
  fifo_rd_en_to_r1(8 downto 8) <= fifo_rd_en_from_AXI(8 downto 8);
  fifo_rd_en_to_r1(9 downto 9) <= fifo_rd_en_from_AXI(9 downto 9);
  fifo_rd_en_to_r1(10 downto 10) <= fifo_rd_en_from_AXI(10 downto 10);
  fifo_rd_en_to_r2(0 downto 0) <= fifo_rd_en_from_AXI(11 downto 11);
  fifo_rd_en_to_r1(11 downto 11) <= fifo_rd_en_from_AXI(12 downto 12);
  fifo_rd_en_to_r1(12 downto 12) <= fifo_rd_en_from_AXI(13 downto 13);
  fifo_rd_en_to_r1(13 downto 13) <= fifo_rd_en_from_AXI(14 downto 14);
  fifo_rd_en_to_r2(1 downto 1) <= fifo_rd_en_from_AXI(15 downto 15);

  --FIFO out mapping
  fifo_out_to_AXI(0 downto 0) <= fifo_out_from_r1(0 downto 0);
  fifo_out_to_AXI(1 downto 1) <= fifo_out_from_r1(1 downto 1);
  fifo_out_to_AXI(2 downto 2) <= fifo_out_from_r1(2 downto 2);
  fifo_out_to_AXI(3 downto 3) <= fifo_out_from_r1(3 downto 3);
  fifo_out_to_AXI(4 downto 4) <= fifo_out_from_r1(4 downto 4);
  fifo_out_to_AXI(5 downto 5) <= fifo_out_from_r1(5 downto 5);
  fifo_out_to_AXI(6 downto 6) <= fifo_out_from_r1(6 downto 6);
  fifo_out_to_AXI(7 downto 7) <= fifo_out_from_r1(7 downto 7);
  fifo_out_to_AXI(8 downto 8) <= fifo_out_from_r1(8 downto 8);
  fifo_out_to_AXI(9 downto 9) <= fifo_out_from_r1(9 downto 9);
  fifo_out_to_AXI(10 downto 10) <= fifo_out_from_r1(10 downto 10);
  fifo_out_to_AXI(11 downto 11) <= fifo_out_from_r2(0 downto 0);
  fifo_out_to_AXI(12 downto 12) <= fifo_out_from_r1(11 downto 11);
  fifo_out_to_AXI(13 downto 13) <= fifo_out_from_r1(12 downto 12);
  fifo_out_to_AXI(14 downto 14) <= fifo_out_from_r1(13 downto 13);
  fifo_out_to_AXI(15 downto 15) <= fifo_out_from_r2(1 downto 1);

  --ADC data mapping
  adc_data_to_r1_p(0 downto 0) <= adc_data_p_i(0 downto 0);
  adc_data_to_r1_p(1 downto 1) <= adc_data_p_i(1 downto 1);
  adc_data_to_r1_p(2 downto 2) <= adc_data_p_i(2 downto 2);
  adc_data_to_r1_p(3 downto 3) <= adc_data_p_i(3 downto 3);
  adc_data_to_r1_p(4 downto 4) <= adc_data_p_i(4 downto 4);
  adc_data_to_r1_p(5 downto 5) <= adc_data_p_i(5 downto 5);
  adc_data_to_r1_p(6 downto 6) <= adc_data_p_i(6 downto 6);
  adc_data_to_r1_p(7 downto 7) <= adc_data_p_i(7 downto 7);
  adc_data_to_r1_p(8 downto 8) <= adc_data_p_i(8 downto 8);
  adc_data_to_r1_p(9 downto 9) <= adc_data_p_i(9 downto 9);
  adc_data_to_r1_p(10 downto 10) <= adc_data_p_i(10 downto 10);
  adc_data_to_r2_p(0 downto 0) <= adc_data_p_i(11 downto 11);
  adc_data_to_r1_p(11 downto 11) <= adc_data_p_i(12 downto 12);
  adc_data_to_r1_p(12 downto 12) <= adc_data_p_i(13 downto 13);
  adc_data_to_r1_p(13 downto 13) <= adc_data_p_i(14 downto 14);
  adc_data_to_r2_p(1 downto 1) <= adc_data_p_i(15 downto 15);
  adc_data_to_r1_n(0 downto 0) <= adc_data_n_i(0 downto 0);
  adc_data_to_r1_n(1 downto 1) <= adc_data_n_i(1 downto 1);
  adc_data_to_r1_n(2 downto 2) <= adc_data_n_i(2 downto 2);
  adc_data_to_r1_n(3 downto 3) <= adc_data_n_i(3 downto 3);
  adc_data_to_r1_n(4 downto 4) <= adc_data_n_i(4 downto 4);
  adc_data_to_r1_n(5 downto 5) <= adc_data_n_i(5 downto 5);
  adc_data_to_r1_n(6 downto 6) <= adc_data_n_i(6 downto 6);
  adc_data_to_r1_n(7 downto 7) <= adc_data_n_i(7 downto 7);
  adc_data_to_r1_n(8 downto 8) <= adc_data_n_i(8 downto 8);
  adc_data_to_r1_n(9 downto 9) <= adc_data_n_i(9 downto 9);
  adc_data_to_r1_n(10 downto 10) <= adc_data_n_i(10 downto 10);
  adc_data_to_r2_n(0 downto 0) <= adc_data_n_i(11 downto 11);
  adc_data_to_r1_n(11 downto 11) <= adc_data_n_i(12 downto 12);
  adc_data_to_r1_n(12 downto 12) <= adc_data_n_i(13 downto 13);
  adc_data_to_r1_n(13 downto 13) <= adc_data_n_i(14 downto 14);
  adc_data_to_r2_n(1 downto 1) <= adc_data_n_i(15 downto 15);

  --delay data ld mapping
  delay_data_ld_to_r1(0 downto 0) <= delay_data_ld_i(0 downto 0);
  delay_data_ld_to_r1(1 downto 1) <= delay_data_ld_i(1 downto 1);
  delay_data_ld_to_r1(2 downto 2) <= delay_data_ld_i(2 downto 2);
  delay_data_ld_to_r1(3 downto 3) <= delay_data_ld_i(3 downto 3);
  delay_data_ld_to_r1(4 downto 4) <= delay_data_ld_i(4 downto 4);
  delay_data_ld_to_r1(5 downto 5) <= delay_data_ld_i(5 downto 5);
  delay_data_ld_to_r1(6 downto 6) <= delay_data_ld_i(6 downto 6);
  delay_data_ld_to_r1(7 downto 7) <= delay_data_ld_i(7 downto 7);
  delay_data_ld_to_r1(8 downto 8) <= delay_data_ld_i(8 downto 8);
  delay_data_ld_to_r1(9 downto 9) <= delay_data_ld_i(9 downto 9);
  delay_data_ld_to_r1(10 downto 10) <= delay_data_ld_i(10 downto 10);
  delay_data_ld_to_r2(0 downto 0) <= delay_data_ld_i(11 downto 11);
  delay_data_ld_to_r1(11 downto 11) <= delay_data_ld_i(12 downto 12);
  delay_data_ld_to_r1(12 downto 12) <= delay_data_ld_i(13 downto 13);
  delay_data_ld_to_r1(13 downto 13) <= delay_data_ld_i(14 downto 14);
  delay_data_ld_to_r2(1 downto 1) <= delay_data_ld_i(15 downto 15);

  --delay data input mapping
  delay_data_input_to_r1(4 downto 0) <= delay_data_input_i(4 downto 0);
  delay_data_input_to_r1(9 downto 5) <= delay_data_input_i(9 downto 5);
  delay_data_input_to_r1(14 downto 10) <= delay_data_input_i(14 downto 10);
  delay_data_input_to_r1(19 downto 15) <= delay_data_input_i(19 downto 15);
  delay_data_input_to_r1(24 downto 20) <= delay_data_input_i(24 downto 20);
  delay_data_input_to_r1(29 downto 25) <= delay_data_input_i(29 downto 25);
  delay_data_input_to_r1(34 downto 30) <= delay_data_input_i(34 downto 30);
  delay_data_input_to_r1(39 downto 35) <= delay_data_input_i(39 downto 35);
  delay_data_input_to_r1(44 downto 40) <= delay_data_input_i(44 downto 40);
  delay_data_input_to_r1(49 downto 45) <= delay_data_input_i(49 downto 45);
  delay_data_input_to_r1(54 downto 50) <= delay_data_input_i(54 downto 50);
  delay_data_input_to_r2(4 downto 0) <= delay_data_input_i(59 downto 55);
  delay_data_input_to_r1(59 downto 55) <= delay_data_input_i(64 downto 60);
  delay_data_input_to_r1(64 downto 60) <= delay_data_input_i(69 downto 65);
  delay_data_input_to_r1(69 downto 65) <= delay_data_input_i(74 downto 70);
  delay_data_input_to_r2(9 downto 5) <= delay_data_input_i(79 downto 75);

  --delay data output mapping
  delay_data_output_o(4 downto 0) <= delay_data_output_from_r1(4 downto 0);
  delay_data_output_o(9 downto 5) <= delay_data_output_from_r1(9 downto 5);
  delay_data_output_o(14 downto 10) <= delay_data_output_from_r1(14 downto 10);
  delay_data_output_o(19 downto 15) <= delay_data_output_from_r1(19 downto 15);
  delay_data_output_o(24 downto 20) <= delay_data_output_from_r1(24 downto 20);
  delay_data_output_o(29 downto 25) <= delay_data_output_from_r1(29 downto 25);
  delay_data_output_o(34 downto 30) <= delay_data_output_from_r1(34 downto 30);
  delay_data_output_o(39 downto 35) <= delay_data_output_from_r1(39 downto 35);
  delay_data_output_o(44 downto 40) <= delay_data_output_from_r1(44 downto 40);
  delay_data_output_o(49 downto 45) <= delay_data_output_from_r1(49 downto 45);
  delay_data_output_o(54 downto 50) <= delay_data_output_from_r1(54 downto 50);
  delay_data_output_o(59 downto 55) <= delay_data_output_from_r2(4 downto 0);
  delay_data_output_o(64 downto 60) <= delay_data_output_from_r1(59 downto 55);
  delay_data_output_o(69 downto 65) <= delay_data_output_from_r1(64 downto 60);
  delay_data_output_o(74 downto 70) <= delay_data_output_from_r1(69 downto 65);
  delay_data_output_o(79 downto 75) <= delay_data_output_from_r2(9 downto 5);

end arch; -- arch
