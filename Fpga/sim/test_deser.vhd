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
  SIGNAL adc_D_p_vec : std_logic_vector(15 downto 0) := (others => adc_D_p);
  SIGNAL adc_D_n_vec : std_logic_vector(15 downto 0) := (others => adc_D_n);
begin
  rst <= not (rst_n);

  adc : entity work.ADCmodel_wrapper(arch)
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
  DUT : ENTITY work.SistAdq_wrapper(STRUCTURE)
    PORT MAP(
      FIXED_IO_0_mio => open,
      FIXED_IO_0_ps_clk => open,
      FIXED_IO_0_ps_porb => open,
      FIXED_IO_0_ps_srstb => open,
      adc_DCO1_i_clk_n => adc_DCO_n,
      adc_DCO1_i_clk_p => adc_DCO_p,
      adc_DCO2_i_clk_n => adc_DCO_n,
      adc_DCO2_i_clk_p => adc_DCO_p,
      adc_FCO1_i_v_n => adc_FCO_n,
      adc_FCO1_i_v_p => adc_FCO_p,
      adc_FCO2_i_v_n => adc_FCO_n,
      adc_FCO2_i_v_p => adc_FCO_p,
      adc_data_i_v_n => adc_D_n_vec,
      adc_data_i_v_p => adc_D_p_vec,
      adc_sclk_o => open,
      adc_sdio_o => open,
      adc_ss1_o => open,
      adc_ss2_o => open,
      dout0_o => open,
      dout1_o => open,
      ext_trigger_i => '0',
      fmc_present_i => '0',
      led_green_o => open,
      led_red_o => open ,
      vadj_en_o => open
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