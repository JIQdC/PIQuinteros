----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Conmutador entre palabra de unos y palabra de ceros
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

entity oneZeroWordToggle is
    generic(
        N: integer := 14 --cantidad de bits del contador
    );
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        usr_ready: in std_logic;
        usr_done: in std_logic;
        d_out: out std_logic_vector((N-1) downto 0)
    );
end oneZeroWordToggle;

architecture arch of oneZeroWordToggle is
    signal zerosNbits: std_logic_vector((N-1) downto 0) := (others => '0');
    signal onesNbits: std_logic_vector((N-1) downto 0) := (others => '1');
    --registro para el toggle
    signal d_reg, d_next: std_logic_vector((N-1) downto 0) := (others => '0');

begin
    --state register
    process(clk,rst_n,usr_done)
    begin
        if (rst_n='0' or usr_ready='0') then
            d_reg <= zerosNbits;
        elsif(rising_edge(clk)) then
            d_reg <= d_next;
        end if;
    end process;

    --actualizaciones
    d_next <=   onesNbits when (d_reg=zerosNbits and falling_edge(usr_done)) else
                zerosNbits when falling_edge(usr_done) else
                d_reg;
    
    --output logic
    d_out <= d_reg;    
    
end arch; -- arch