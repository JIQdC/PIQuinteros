----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Divisor de clock
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-07-19
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity clk_divider is
  generic (
    half_pulse_count : integer := 512 --up to 2047
  );
  port (
    rst_n   : in std_logic;
    clk_in  : in std_logic;
    clk_out : out std_logic
  );
end clk_divider;

architecture arch of clk_divider is
  signal zeros : unsigned(10 downto 0) := (others => '0');
  --registro para el contador
  signal acum_reg, acum_next : unsigned(10 downto 0) := (others => '0');
  signal acum_max            : unsigned(10 downto 0) := to_unsigned(half_pulse_count - 1, 11);
  --registro para la salida
  signal clk_reg, clk_next : std_logic := '0';

begin
  --state register
  process (clk_in, rst_n)
  begin
    if (rst_n = '0') then
      acum_reg <= zeros;
      clk_reg  <= '0';
    elsif (rising_edge(clk_in)) then
      acum_reg <= acum_next;
      clk_reg  <= clk_next;
    end if;
  end process;

  --next-state logic
  process (acum_reg, clk_reg)
  begin
    clk_next  <= clk_reg;
    acum_next <= acum_reg + 1;

    if (acum_reg >= acum_max) then
      clk_next  <= not(clk_reg);
      acum_next <= zeros;
    end if;

  end process;

  clk_out <= clk_reg;

end arch; -- arch