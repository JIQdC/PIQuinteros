----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Create Date: 09/20/2019 03:33:59 PM
-- Design Name: 
-- Module Name: TestAXI - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para transacciones AXI con dos slaves
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
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

entity TestADCmodel is
    --  no ports - this is a testbench;
end TestADCmodel;
    
architecture sim of TestADCmodel is

    signal clk, rst_n : std_logic;
    signal data_in: std_logic_vector(13 downto 0) := "10101011101010";
    signal DCO, FCO, DATA: std_logic := '0';
    
    begin
    
    U1: entity work.tb_clk(sim)
            port map(clk_o => clk);

    U2: entity work.tb_rst(sim)
            generic map(RST_ACTIVO => '0', T_RST_INICIO => 0 ns, T_RST_ACTIVO => 60 ns)
            port map(rst_async_o => open, rst_sync_o => rst_n, clk_i => clk);

    DUT: entity work.ADC_model(arch)
            port map(rst_n => rst_n, d_in => data_in, DCO => DCO, FCO => FCO, DATA => DATA);
        
        
end sim;
