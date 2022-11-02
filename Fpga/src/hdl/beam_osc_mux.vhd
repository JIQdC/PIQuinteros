library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity beam_osc_mux is
  port (
    sys_clk_i    : in std_logic;
    async_rst_ni : in std_logic;
    beam_sel     : in std_logic_vector(2 downto 0);
    beams_data_i : in std_logic_vector(32 * 5 - 1 downto 0);
    beam_data_o  : out std_logic_vector(32 - 1 downto 0)
  );
end beam_osc_mux;

architecture rtl of beam_osc_mux is
  signal beam_data_reg : std_logic_vector(32 - 1 downto 0);
begin
  process (sys_clk_i, async_rst_ni)
  begin
    if (async_rst_ni = '0') then
      beam_data_reg <= (others => '0');
    elsif (rising_edge(sys_clk_i)) then
      case beam_sel is
        when "000" =>
          beam_data_reg <= beams_data_i(32 * 1 - 1 downto 32 * 0);
        when "001" =>
          beam_data_reg <= beams_data_i(32 * 2 - 1 downto 32 * 1);
        when "010" =>
          beam_data_reg <= beams_data_i(32 * 3 - 1 downto 32 * 2);
        when "011" =>
          beam_data_reg <= beams_data_i(32 * 4 - 1 downto 32 * 3);
        when "100" =>
          beam_data_reg <= beams_data_i(32 * 5 - 1 downto 32 * 4);
        when others =>
          beam_data_reg <= (others => '0');
      end case;

    end if;
  end process;

  beam_data_o <= beam_data_reg;
end rtl;
