library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity valid_data_holder is
    generic(DATA_LENGTH : integer := 32);
    port(
        clk_i         : in std_logic;
        rst_ni        : in std_logic;
        s_axis_tdata  : in std_logic_vector(DATA_LENGTH - 1 downto 0);
        s_axis_tvalid : in std_logic;
        m_axis_tdata  : out std_logic_vector(DATA_LENGTH - 1 downto 0);
        m_axis_tvalid : out std_logic
    );
end valid_data_holder;

architecture rtl of valid_data_holder is
    signal data_reg : std_logic_vector(DATA_LENGTH - 1 downto 0);
    signal valid_reg : std_logic;
begin
   main: process(clk_i)
   begin
    if rising_edge(clk_i) then
        if rst_ni = '0' then
            data_reg <= (others => '0');
            valid_reg <= '0';
        else
            data_reg <= data_reg;
            valid_reg <= s_axis_tvalid;
            if s_axis_tvalid = '1' then
                data_reg <= s_axis_tdata;
            end if;
        end if;
    end if;
   end process main;
   m_axis_tdata <= data_reg;
   m_axis_tvalid <= valid_reg;
    
end architecture rtl;