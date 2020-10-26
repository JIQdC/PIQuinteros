----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para modelo de conversor AD9249
-- 
-- Dependencies: 
-- 
-- Revision: 2019-10-21
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

entity TestADCmodelToggle is
        --  no ports - this is a testbench;
end TestADCmodelToggle;
    
architecture sim of TestADCmodelToggle is

        signal clk, rst_n, usr_ready, usr_done, adc_DCO, adc_FCO, adc_D: std_logic;
        signal d: std_logic_vector(13 downto 0);

begin
        U1: entity work.tb_clk(sim)
                generic map(T_SIM_LIMIT => 10 us, T_CLK_PERIOD => 1 ns)
                port map(clk_o => clk);

        U2: entity work.tb_rst(sim)
                generic map(RST_ACTIVO => '0', T_RST_INICIO => 0 ns, T_RST_ACTIVO => 27 ns)
                port map(rst_async_o => open, rst_sync_o => rst_n, clk_i => clk);

        U3: entity work.oneZeroWordToggle(arch)
                generic map(N => 14)
                port map(clk => clk, rst_n => rst_n, usr_ready => usr_ready,
                usr_done => usr_done, d_out => d);

        DUT: entity work.ADC_model(arch)
                generic map(N => 14, T_SAMPLE => 14 ns, T_DELAY => 2.3 ns)
                port map(rst_n => rst_n, d_in => d, adc_DCO => adc_DCO, adc_FCO => adc_FCO, adc_D => adc_D,
                usr_ready => usr_ready, usr_done => usr_done);

end sim;