----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: Guillermo Guichal
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Ejemplos b�sicos de dise�o VHDL
-- 
-- Dependencies: None.
-- 
-- Revision: 2016-02-18.01
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_clk is
    generic(T_SIM_LIMIT  : time := 10000 ms;
            T_CLK_PERIOD : time := 15.625 ns);
    port ( clk_o  : out std_logic := '0');
end tb_clk;

architecture sim of tb_clk is

    constant T_CLK_HIGH   : time := T_CLK_PERIOD/2;

begin

    process
    begin
        clk_o <= '0';

        while (now < T_SIM_LIMIT) loop
            wait for T_CLK_PERIOD - T_CLK_HIGH;
            clk_o <= '1';
            wait for T_CLK_HIGH; 
            clk_o <= '0';
        end loop;
        report "Fin de simulación.";
        wait;
    end process;    
      
end sim;
