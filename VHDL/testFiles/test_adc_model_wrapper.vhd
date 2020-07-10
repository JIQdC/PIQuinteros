----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench de secuencias de prueba del modelo del AD9249
-- 
-- Dependencies: 
-- 
-- Revision: 2019-10-29
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestADCmodelWrapper is
        --  no ports - this is a testbench;
end TestADCmodelWrapper;
    
architecture sim of TestADCmodelWrapper is

    signal rst_n: std_logic := '0';
    signal adc_DCO, adc_FCO, adc_D: std_logic;
    signal control: std_logic_vector(3 downto 0) := (others => '0');
    signal usr_w1, usr_w2: std_logic_vector(13 downto 0) := (others => '0');

begin

    DUT: entity work.ADCmodel_wrapper(arch)
        generic map(
            N => 14,
            T_SAMPLE => 14 ns,
            T_DELAY => 2.3 ns,
            T_SIM_LIMIT => 10 us,
            T_CLK_PERIOD => 1 ns
            )
        port map(
            rst_n => rst_n, usr_w1 => usr_w1, usr_w2 => usr_w2,
            control => control, adc_DCO => adc_DCO, adc_FCO => adc_FCO, adc_D => adc_D
            );

    simProcess: process
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