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
-- Additional Comments: single channel version
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

use work.fifo_record_pkg.all;

entity adc_control_wrapper_1ch is
  generic (
    -- Core ID and version
    USER_CORE_ID_VER : std_logic_vector(31 downto 0) := X"00020003";
    RES_ADC          : integer                       := 14;          --ADC bit resolution
    FIFO_EMPTY_VAL   : std_logic_vector(31 downto 0) := X"00000DEF"; --output value when attempting to read from empty FIFO
    N_tr_b           : integer                       := 10           --bits for downsampler treshold register
  );
  port (
    --AXI interface
    S_AXI_ACLK           : in std_logic;
    S_AXI_ARESETN        : in std_logic;
    S_AXI_AWADDR         : in std_logic_vector(10 - 1 downto 0);
    S_AXI_AWPROT         : in std_logic_vector(2 downto 0);
    S_AXI_AWVALID        : in std_logic;
    S_AXI_AWREADY        : out std_logic;
    S_AXI_WDATA          : in std_logic_vector(32 - 1 downto 0);
    S_AXI_WSTRB          : in std_logic_vector((32/8) - 1 downto 0);
    S_AXI_WVALID         : in std_logic;
    S_AXI_WREADY         : out std_logic;
    S_AXI_BRESP          : out std_logic_vector(1 downto 0);
    S_AXI_BVALID         : out std_logic;
    S_AXI_BREADY         : in std_logic;
    S_AXI_ARADDR         : in std_logic_vector(10 - 1 downto 0);
    S_AXI_ARPROT         : in std_logic_vector(2 downto 0);
    S_AXI_ARVALID        : in std_logic;
    S_AXI_ARREADY        : out std_logic;
    S_AXI_RDATA          : out std_logic_vector(32 - 1 downto 0);
    S_AXI_RRESP          : out std_logic_vector(1 downto 0);
    S_AXI_RVALID         : out std_logic;
    S_AXI_RREADY         : in std_logic;

    --external reset for peripherals
    rst_peripherals_i    : in std_logic;

    --ADC signals
    adc_DCO_p_i          : in std_logic;
    adc_DCO_n_i          : in std_logic;
    adc_FCO_p_i          : in std_logic;
    adc_FCO_n_i          : in std_logic;
    adc_data_p_i         : in std_logic;
    adc_data_n_i         : in std_logic;
    adc_FCOlck_o         : out std_logic;

    --downsampler control signals
    treshold_value_i     : in std_logic_vector((N_tr_b - 1) downto 0);
    treshold_ld_i        : in std_logic;

    --delay control signals
    delay_locked_o       : out std_logic;
    delay_data_ld_i      : in std_logic;
    delay_data_input_i   : in std_logic_vector((5 - 1) downto 0);
    delay_data_output_o  : out std_logic_vector((5 - 1) downto 0);
    delay_frame_ld_i     : in std_logic;
    delay_frame_input_i  : in std_logic_vector((5 - 1) downto 0);
    delay_frame_output_o : out std_logic_vector((5 - 1) downto 0);

    --external trigger
    ext_trigger_i        : in std_logic
  );
end adc_control_wrapper_1ch;

architecture arch of adc_control_wrapper_1ch is

  --Xilinx attributes
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_DCO_p_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO_i CLK_P";
  attribute X_INTERFACE_INFO of adc_DCO_n_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO_i CLK_N";
  attribute X_INTERFACE_INFO of adc_FCO_p_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO_i V_P";
  attribute X_INTERFACE_INFO of adc_FCO_n_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO_i V_N";
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
  signal debug_control_from_AXI : std_logic_vector((4 - 1) downto 0) := (others => '0');
  signal debug_w2w1_from_AXI : std_logic_vector((28 - 1) downto 0) := (others => '0');
  signal fifo_rd_en_from_AXI : std_logic_vector(0 downto 0) := (others => '0');
  signal fifo_out_to_AXI : fifo_out_vector_t(0 downto 0);
  signal delay_refclk_to_bufg, delay_refclk : std_logic;

begin

  data_control_inst : entity work.data_control(rtl)
    generic map(
      USER_CORE_ID_VER => USER_CORE_ID_VER,
      N                => 1,
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

  ---- DELAY CONTROL
  -- instantiate BUFG for external ref clk, and IDELAYCTRL to control IDELAYs in receivers

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

  --receiver for single ADC signal
  adc_receiver_inst : entity work.adc_receiver(arch)
    generic map(
      RES_ADC => RES_ADC,
      N       => 1,
      N_tr_b  => N_tr_b
    )
    port map(
      fpga_clk_i           => S_AXI_ACLK,
      async_rst_i          => debug_rst,

      adc_clk_p_i          => adc_DCO_p_i,
      adc_clk_n_i          => adc_DCO_n_i,
      adc_frame_p_i        => adc_FCO_p_i,
      adc_frame_n_i        => adc_FCO_n_i,
      adc_data_p_i(0)      => adc_data_p_i,
      adc_data_n_i(0)      => adc_data_n_i,
      adc_FCOlck_o         => adc_FCOlck_o,

      treshold_value_i     => treshold_value_i,
      treshold_ld_i        => treshold_ld_i,

      debug_enable_i       => debug_enable_from_AXI,
      debug_control_i      => debug_control_from_AXI,
      debug_w2w1_i         => debug_w2w1_from_AXI,

      fifo_rst_i           => fifo_rst,
      fifo_rd_en_i         => fifo_rd_en_from_AXI,
      fifo_out_o           => fifo_out_to_AXI,

      delay_refclk_i       => delay_refclk,
      delay_data_ld_i(0)   => delay_data_ld_i,
      delay_data_input_i   => delay_data_input_i,
      delay_data_output_o  => delay_data_output_o,
      delay_frame_ld_i     => delay_frame_ld_i,
      delay_frame_input_i  => delay_frame_input_i,
      delay_frame_output_o => delay_frame_output_o
    );

  --reset handling
  fifo_rst <= fifo_rst_from_AXI or rst_peripherals_i;
  debug_rst <= async_rst_from_AXI or rst_peripherals_i;

end arch; -- arch
