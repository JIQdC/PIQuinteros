library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cdc_two_ff_sync is
  generic (
    SIZE : integer := 32
  );
  port (
    clk_i    : in std_logic;
    rst_ni   : in std_logic;
    data_in  : in std_logic_vector(SIZE - 1 downto 0);
    data_out : out std_logic_vector(SIZE - 1 downto 0)
  );
end cdc_two_ff_sync;

architecture rtl of cdc_two_ff_sync is
  signal reg_1 : std_logic_vector(SIZE - 1 downto 0);
  signal reg_2 : std_logic_vector(SIZE - 1 downto 0);

begin
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      if (rst_ni = '0') then
        reg_1 <= (others => '0');
        reg_2 <= (others => '0');
      else
        reg_1 <= data_in;
        reg_2 <= reg_1;
      end if;
    end if;
  end process;
  data_out <= reg_2;
end architecture rtl;
