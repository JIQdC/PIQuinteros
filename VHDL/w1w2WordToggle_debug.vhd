----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Conmutador entre dos palabras de N bits. Versión para debug hacia FIFO.
-- 
-- Dependencies: None.
-- 
-- Revision: 2019-10-29
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity w1w2WordToggle_debug is
    generic(
        N: integer := 14 --cantidad de bits del contador
    );
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        w1,w2: in std_logic_vector((N-1) downto 0);
        d_out: out std_logic_vector((N-1) downto 0)
    );
end w1w2WordToggle_debug;

architecture arch of w1w2WordToggle_debug is
    signal zerosNbits: std_logic_vector((N-1) downto 0) := (others => '0');
    --registro para el toggle
    signal d_reg, d_next: std_logic_vector((N-1) downto 0) := (others => '0');

begin
    --state register
    process(clk,rst_n)
    begin
        if (rst_n='0') then
            d_reg <= zerosNbits;
        elsif(rising_edge(clk)) then
            d_reg <= d_next;
        end if;
    end process;

    --actualizaciones
    d_next <=   w2 when d_reg=w1 else
                w1;
    
    --output logic
    d_out <= d_reg;    
    
end arch; -- arch