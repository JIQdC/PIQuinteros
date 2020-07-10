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
-- Revision: 2019-11-09
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

entity TestADC_DDR_deser is
        --  no ports - this is a testbench;
end TestADC_DDR_deser;
    
architecture sim of TestADC_DDR_deser is

    signal rst_n: std_logic := '0';
    constant N: integer := 14;    
    --ADC model
    signal adc_DCO: std_logic;
    signal adc_FCO: std_logic_vector(0 to 0);
    signal adc_D: std_logic_vector(0 to 0);
    signal control: std_logic_vector(3 downto 0) := (others => '0');
    signal usr_w1, usr_w2: std_logic_vector(13 downto 0) := (others => '0');
    --DDR mod
    signal ddr_clk_out: std_logic;
    signal ddr_data_out: std_logic_vector(1 downto 0);
    signal ddr_frame_out: std_logic_vector(1 downto 0);
    signal rst: std_logic := '0';
    --deser
    signal deser_data_out: std_logic_vector((N-1) downto 0);
    signal deser_data_valid: std_logic;

begin
    --rst no negado para el módulo DDR
    rst <= not(rst_n);

    ADC: entity work.ADCmodel_wrapper(arch)
        generic map(
            N => N,
            T_SAMPLE => 14 ns,
            T_DELAY => 2.3 ns,
            T_SIM_LIMIT => 10 us,
            T_CLK_PERIOD => 1 ns
            )
        port map(
            rst_n => rst_n, usr_w1 => usr_w1, usr_w2 => usr_w2,
            control => control, adc_DCO => adc_DCO, adc_FCO => adc_FCO(0), adc_D => adc_D(0)
            );

    DDRmod: entity work.DDRmodule_wrapper(STRUCTURE)
        port map(
            clk_in => adc_DCO, clk_out => ddr_clk_out, data_in => adc_D, data_out => ddr_data_out, frame_in => adc_FCO, frame_out => ddr_frame_out, rst => rst
            );

    deser: entity work.deserializer(arch)
        generic map(
            N => N
        )
        port map(
            d_in => ddr_data_out, d_clk_in => ddr_clk_out, d_frame => ddr_frame_out(0), d_out => deser_data_out, d_valid => deser_data_valid
        );

    simProcess: process
    begin
        --pruebo una secuencia de salida
        control <= "1111";
        usr_w1 <= "01000000000000";
        --reseteo por un tiempo
        rst_n <= '0';
        wait for 50 ns;
        rst_n <= '1';
        --wait for 50 ns;
        --rst_n <= '0';
        --veo que pasa...
        wait;

    end process;
end sim;