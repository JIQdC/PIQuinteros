----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Deserializer
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-09-24
-- Additional Comments:
-- Corregido para 
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity deserializer is
    generic(
        N: integer := 14 --cantidad de bits del ADC
    );
    port(
        d_in: in std_logic_vector(1 downto 0);
        d_clk_in: in std_logic;
        d_frame: in std_logic;
        d_out: out std_logic_vector((N-1) downto 0);
        d_valid: out std_logic
    );
end deserializer;

architecture arch of deserializer is

    signal d_reg, d_next:       std_logic_vector((N-1) downto 0) := (others => '0');
    signal out_reg, out_next:   std_logic_vector((N-1) downto 0) := (others => '0');
    signal f_reg, f_next:       std_logic;

    begin

        process(d_clk_in)
        begin
            if(rising_edge(d_clk_in)) then
                d_reg   <= d_next;
                out_reg <= out_next;
                f_reg   <= f_next;
            end if;
        end process;

        process(d_reg,f_reg,out_reg,d_in,d_frame)
        begin
            d_next <= d_reg((N-3) downto 0) & d_in(1) & d_in(0);
            f_next <= d_frame;
            if(f_reg = '0' and d_frame = '1') then --rising edge del frame
                out_next <= d_reg;
            else
                out_next <= out_reg;
            end if;
            if(f_reg = '1' and d_frame = '0') then --falling edge del frame
                d_valid <= '1';
            else
                d_valid <= '0';
            end if;
        end process;

        d_out   <= out_reg;
   
end arch; -- arch