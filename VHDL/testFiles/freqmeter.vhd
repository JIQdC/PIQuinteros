----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Frecuencímetro 
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-07-16
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity freqmeter is
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        data: in std_logic;
        d_out: out std_logic_vector(15 downto 0)
    );
end freqmeter;

architecture arch of freqmeter is
    signal zeros: unsigned(15 downto 0) := (others => '0');
    signal ones: unsigned(15 downto 0) := (others => '1');
    --registro para el contador
    signal acum_reg, acum_next: unsigned(15 downto 0) := (others => '0');
    --registro para la salida
    signal count_reg, count_next: unsigned(15 downto 0) := (others => '0');

    signal data_reg, data_next: std_logic := '0';
    --aux para suma
    signal sum: unsigned(15 downto 0) := (others => '0');

begin
    --state register
    process(clk,rst_n)
    begin
        if (rst_n='0') then
            acum_reg <= zeros;
            count_reg <= zeros;
            data_reg <= '0';
        elsif(rising_edge(clk)) then
            acum_reg <= acum_next;
            count_reg <= count_next;
            data_reg <= data_next;
        end if;
    end process;

    --next-state logic
    process(acum_reg,count_reg,data_reg,data)
    begin
        data_next <= data;

        if(data_reg = '0' and data = '1') then
            count_next <= acum_reg;
            acum_next <= zeros;
        elsif (not (count_reg = ones)) then
            acum_next <= acum_reg + 1;
            count_next <= count_reg;
        else
            acum_next <= acum_reg;
            count_next <= count_reg;
        end if;

    end process;

    d_out <= std_logic_vector(count_reg + 1);    
    
end arch; -- arch
