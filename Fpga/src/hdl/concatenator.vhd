library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity concatenator is
  generic (
    DATA_WIDTH_1 : integer := 8;
    DATA_WIDTH_2 : integer := 8
  );
  port (
    sys_clk_i : in std_logic;
    sys_rst_i : in std_logic;
    data_1_i  : in std_logic_vector(DATA_WIDTH_1 - 1 downto 0);
    data_2_i  : in std_logic_vector(DATA_WIDTH_2 - 1 downto 0);
    data_o    : out std_logic_vector(DATA_WIDTH_1 + DATA_WIDTH_2 - 1 downto 0)
  );
end concatenator;

architecture Behavioral of concatenator is
begin
  process (sys_clk_i, sys_rst_i)
  begin
    if (sys_rst_i = '1') then
      data_o <= (others => '0');
    elsif (rising_edge(sys_clk_i)) then
      data_o <= data_1_i & data_2_i;
    end if;
  end process;
end Behavioral;
