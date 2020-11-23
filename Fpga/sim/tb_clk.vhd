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
-- Revision: 2020-11-16
-- Additional Comments: JIQdC: removed annoying simulation limit
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_clk is
  generic (
    T_CLK_PERIOD : time := 15.625 ns
  );
  port (clk_o : out std_logic := '0');
end tb_clk;

architecture sim of tb_clk is

  constant T_CLK_HIGH : time := T_CLK_PERIOD/2;

begin

  process
  begin
    clk_o <= '0';

    wait for T_CLK_PERIOD - T_CLK_HIGH;
    clk_o <= '1';
    wait for T_CLK_HIGH;
    clk_o <= '0';

  end process;

end sim;