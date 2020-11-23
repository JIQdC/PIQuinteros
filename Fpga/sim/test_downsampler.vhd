----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for downsampler
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

entity test_downsampler is
  --  no ports - this is a testbench;
end test_downsampler;

architecture sim of test_downsampler is

  signal rst_n, rst : std_logic := '0';
  signal adc_DCO_p, adc_FCO_p, adc_D_p,
  adc_DCO_n, adc_FCO_n, adc_D_n     : std_logic;
  signal adc_control, debug_control : std_logic_vector(3 downto 0)  := (others => '0');
  signal usr_w1, usr_w2             : std_logic_vector(13 downto 0) := (others => '0');
  signal delay_ref_clk              : std_logic                     := '0';
  signal frame_n                    : std_logic                     := '0';
  signal treshold                   : std_logic_vector(9 downto 0)  := (others => '0');
  signal deb_enable, tresh_ld       : std_logic                     := '0';

  constant TRESHOLD_VALUE : integer := 15;

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

  downsampler : entity work.downsampler_test_wrapper(STRUCTURE)
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
      usr_w2w1_i_0(13 downto 0)  => usr_w1
    );

  simProcess : process
  begin
    --counter as ADC simulator test data. Use "1F00" as initial value
    adc_control <= "1111";
    usr_w1      <= "01" & x"F00";

    --trigger reset
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';
    wait for 50 ns;

    --load downsampler treshold: keep 1 out of TRESHOLD_VALUE+1 samples
    treshold <= std_logic_vector(to_unsigned(TRESHOLD_VALUE, 10));
    tresh_ld <= '1';
    wait for 20 ns;
    tresh_ld <= '0';

    --set debug control to output deserializer data
    debug_control <= "1101";
    deb_enable    <= '1';

    wait for 1000 ns;

    --set debug control to output binary counter data
    debug_control <= "1111";
    wait;

  end process;
end sim;