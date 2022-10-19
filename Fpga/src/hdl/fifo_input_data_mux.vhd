library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity fifo_input_data_mux is
  port (
    sys_clk_i            : in std_logic;
    sys_rst_i            : in std_logic;

    -- Mux control
    data_mux_sel_i       : in std_logic_vector(1 downto 0);

    -- Data from preprocessing logic
    data_preproc_i       : in std_logic_vector(31 downto 0);
    data_preproc_valid_i : in std_logic;

    -- Data from debug counter
    data_counter_i       : in std_logic_vector(31 downto 0);
    data_counter_valid_i : in std_logic;

    -- Raw data from deserializer
    data_raw_i           : in std_logic_vector(13 downto 0);
    data_raw_valid_i     : in std_logic;

    -- Output data
    data_o               : out std_logic_vector(31 downto 0);
    data_valid_o         : out std_logic
  );

end entity fifo_input_data_mux;

architecture arch of fifo_input_data_mux is
  signal data_raw_shift_reg : std_logic_vector(31 downto 0);
  signal data_raw_toggle_reg : std_logic;
begin

  aproc_data_mux : process (sys_clk_i, sys_rst_i)
  begin
    if sys_rst_i = '1' then
      data_valid_o <= '0';
      data_raw_toggle_reg <= '0';
    elsif rising_edge(sys_clk_i) then

      data_valid_o <= '0';

      case data_mux_sel_i is
        when "00" => --disabled
          data_valid_o <= '0';
        when "01" => --preprocessing data
          if (data_preproc_valid_i = '1') then
            data_o <= data_preproc_i;
            data_valid_o <= '1';
          end if;
        when "10" => -- debug counter
          if (data_counter_valid_i = '1') then
            data_o <= data_counter_i;
            data_valid_o <= '1';
          end if;
        when "11" => -- raw data. Group by two to fit in FIFO input
          if (data_raw_valid_i = '1') then
            data_raw_shift_reg(31 downto 16) <= data_raw_shift_reg(15 downto 0);
            data_raw_shift_reg(15 downto 0) <= "00" & data_raw_i;
            data_raw_toggle_reg <= not data_raw_toggle_reg;
            if (data_raw_toggle_reg = '1') then
              data_o <= data_raw_shift_reg;
              data_valid_o <= '1';
            end if;
          end if;
        when others =>
          data_valid_o <= '0';
      end case;
    end if;
  end process aproc_data_mux;

end architecture arch;
