----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Reset handler
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-03-07
-- Additional Comments: Administrador de reset para módulos debug y FIFO
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity rst_handler is
    port(
        rst_fifo_i: in std_logic;
        rst_debug_i: in std_logic;
        rst_interconnect_i: in std_logic_vector(1 downto 0);

        rst_fifo_o: out std_logic;
        rst_debug_o: out std_logic
    );
end rst_handler;

architecture arch of rst_handler is
begin
    rst_fifo_o <= rst_fifo_i or rst_interconnect_i(1);
    rst_debug_o <= rst_debug_i or rst_interconnect_i(0);
end arch; -- arch
