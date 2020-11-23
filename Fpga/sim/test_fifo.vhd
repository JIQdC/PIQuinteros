----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for FIFO
-- 
-- Dependencies: 
-- 
-- Revision: 2020-11-18
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity test_fifo is
  --  no ports - this is a testbench;
end test_fifo;

architecture sim of test_fifo is

  signal rst_n, rst : std_logic := '0';
  signal adc_DCO_p, adc_FCO_p, adc_D_p,
  adc_DCO_n, adc_FCO_n, adc_D_n                  : std_logic;
  signal adc_control, debug_control              : std_logic_vector(3 downto 0)  := (others => '0');
  signal usr_w1, usr_w2                          : std_logic_vector(13 downto 0) := (others => '0');
  signal delay_ref_clk                           : std_logic                     := '0';
  signal frame_n                                 : std_logic                     := '0';
  signal treshold                                : std_logic_vector(9 downto 0)  := (others => '0');
  signal deb_enable, tresh_ld                    : std_logic                     := '0';
  signal rd_clk, rd_en, wr_rst_busy, rd_rst_busy : std_logic                     := '0';
  signal fifo_reset, fifo_prog_full              : std_logic                     := '0';

  constant TRESHOLD_VALUE : integer := 9;
  constant RD_CLK_PERIOD  : time    := 4 ns;

begin
  rst <= not (rst_n);

  DUT : entity work.ADCmodel_wrapper(arch)
    generic map(
      N            => 14,
      T_SAMPLE     => 14 ns,
      T_DELAY      => 2.3 ns,
      T_CLK_PERIOD => 1 ns
    )
    port map(
      rst_n => rst_n, usr_w1 => usr_w1, usr_w2 => usr_w2,
      control => adc_control, adc_DCO_p => adc_DCO_p, adc_FCO_p => adc_FCO_p, adc_D_p => adc_D_p,
      adc_DCO_n => adc_DCO_n, adc_FCO_n => adc_FCO_n, adc_D_n => adc_D_n
    );

  fifo : entity work.fifo_test_wrapper(STRUCTURE)
    port map(
      clk_in_n_0                 => adc_DCO_n,
      clk_in_p_0                 => adc_DCO_p,
      data_in_from_pins_n_0(1)   => adc_D_n,
      data_in_from_pins_n_0(0)   => adc_FCO_n,
      data_in_from_pins_p_0(1)   => adc_D_p,
      data_in_from_pins_p_0(0)   => adc_FCO_p,
      io_reset_0                 => rst,
      control_i_0                => debug_control,
      enable_i_0                 => deb_enable,
      treshold_i_0               => treshold,
      treshold_ld_i_0            => tresh_ld,
      usr_w2w1_i_0(27 downto 14) => usr_w2,
      usr_w2w1_i_0(13 downto 0)  => usr_w1,
      rd_clk_0                   => rd_clk,
      rd_en_0                    => rd_en,
      wr_rst_busy_0              => wr_rst_busy,
      rd_rst_busy_0              => rd_rst_busy,
      fifo_rst_0                 => fifo_reset,
      prog_full_0                => fifo_prog_full
    );

  rd_clk_inst : entity work.tb_clk(sim)
    generic map(
      T_CLK_PERIOD => RD_CLK_PERIOD
    )
    port map(
      clk_o => rd_clk
    );

  simProcess : process
  begin
    --counter as ADC simulator test data. Use "1F00" as initial value
    adc_control <= "1111";
    usr_w1      <= "01" & x"F00";

    --triger reset
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';
    wait for 50 ns;

    --trigger FIFO reset. Be careful with FIFO signals
    fifo_reset <= '1';
    wait until ((rd_rst_busy = '1') and (wr_rst_busy = '1'));
    fifo_reset <= '0';
    wait until ((rd_rst_busy = '0') and (wr_rst_busy = '0'));

    --load downsampler treshold: keep 1 out of TRESHOLD_VALUE+1 samples
    treshold <= std_logic_vector(to_unsigned(TRESHOLD_VALUE, 10));
    tresh_ld <= '1';
    wait for 20 ns;
    tresh_ld <= '0';

    --set debug control to output deserializer data
    debug_control <= "1101";
    deb_enable    <= '1';

    --wait until PROG_FULL is asserted and read 10 samples
    wait until fifo_prog_full = '1';
    rd_en <= '1';
    wait for 10 * RD_CLK_PERIOD;
    rd_en <= '0';

    --read 
    wait;

  end process;
end sim;