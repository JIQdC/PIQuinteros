----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for deserializer
-- 
-- Dependencies: 
-- 
-- Revision: 2020-11-16
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity test_deser is
  --  no ports - this is a testbench;
end test_deser;

architecture sim of test_deser is

  signal rst_n, rst : std_logic := '0';
  signal adc_DCO_p, adc_FCO_p, adc_D_p,
  adc_DCO_n, adc_FCO_n, adc_D_n : std_logic;
  signal control                : std_logic_vector(3 downto 0)  := (others => '0');
  signal usr_w1, usr_w2         : std_logic_vector(13 downto 0) := (others => '0');
  signal delay_ref_clk          : std_logic                     := '0';
  signal frame_n                : std_logic                     := '0';

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
      control => control, adc_DCO_p => adc_DCO_p, adc_FCO_p => adc_FCO_p, adc_D_p => adc_D_p,
      adc_DCO_n => adc_DCO_n, adc_FCO_n => adc_FCO_n, adc_D_n => adc_D_n
    );

--  SelectIO : entity work.deser_test_wrapper(STRUCTURE)
--    port map(
--      clk_in_n_0               => adc_DCO_n,
--      clk_in_p_0               => adc_DCO_p,
--      data_in_from_pins_n_0(1) => adc_D_n,
--      data_in_from_pins_n_0(0) => adc_FCO_n,
--      data_in_from_pins_p_0(1) => adc_D_p,
--      data_in_from_pins_p_0(0) => adc_FCO_p,
--      io_reset_0               => rst
--    );

  simProcess : process
  begin
    --pruebo una secuencia de salida
    control <= "1111";
    --reseteo por un tiempo
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';

    --veo que pasa...
    wait;

  end process;
end sim;