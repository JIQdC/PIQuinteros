----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Deserializador
-- 
-- Dependencies: None.
-- 
-- Revision: 2019-11-04
-- Additional Comments: Este modelo DEBE SER SINTETIZABLE!!
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
        --rst_n: in std_logic;
        d_in: in std_logic_vector(1 downto 0);
        d_clk_in: in std_logic;
        d_frame: in std_logic;
        d_out: out std_logic_vector((N-1) downto 0);
        d_valid: out std_logic
    );
end deserializer;

architecture arch of deserializer is

    --registro de estado
	type state_type is (capture,done);
    signal state_reg,state_next: state_type;

    signal d_reg, d_next: std_logic_vector((N-1) downto 0) := (others => '0');

    begin

        process(d_clk_in, d_frame)
        begin
            if(rising_edge(d_frame)) then
                d_reg <= d_next;
                state_reg <= done;
                d_out <= d_reg;
                d_valid <= '1';
            elsif(rising_edge(d_clk_in)) then
                d_out <= (others => '0');
                d_valid <= '0';
                d_reg <= d_next;
            end if;
        end process;

        process(d_clk_in,d_in)
        begin
            d_next <= d_reg((N-3) downto 0) & d_in(0) & d_in(1);
        end process;
   
end arch; -- arch
