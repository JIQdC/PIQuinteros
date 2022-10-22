library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cdc_comparator is
  generic (
    SIZE : integer := 32
  );
  port (
    clk_i     : in std_logic;
    rst_ni    : in std_logic;
    data_1_in : in std_logic_vector(SIZE - 1 downto 0);
    data_2_in : in std_logic_vector(SIZE - 1 downto 0);
    data_out  : out std_logic_vector(SIZE - 1 downto 0)
  );
end cdc_comparator;

architecture rtl of cdc_comparator is
  signal reg : std_logic_vector(SIZE - 1 downto 0);
begin
  proc_name : process (clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_ni = '0' then
        reg <= (others => '0');
      else
        if data_1_in = data_2_in then
          reg <= data_1_in;
        else
          reg <= reg;
        end if;
      end if;
    end if;
  end process proc_name;
  data_out <= reg;
end architecture rtl;
