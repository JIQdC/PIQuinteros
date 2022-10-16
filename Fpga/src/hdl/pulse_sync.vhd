library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity pulse_sync is
    generic (FF_COUNT : integer := 3);
    port (
        src_clk    : in std_logic;
        src_rst_i  : in std_logic;
        dest_clk   : in std_logic;
        dest_rst_i : in std_logic;
        pulse_i    : in std_logic;
        pulse_o    : out std_logic
    );
end pulse_sync;

architecture arch of pulse_sync is
    signal src_pulse_reg : std_logic;
    signal transition_reg : std_logic;
    signal dest_pulse_reg : std_logic_vector(1 downto 0);

    attribute ASYNC_REG : string;
    attribute ASYNC_REG of dest_pulse_reg : signal is "TRUE";

begin
    toggle : process (src_clk, src_rst_i)
    begin
        if src_rst_i = '1' then
            src_pulse_reg <= '0';
        elsif rising_edge(src_clk) then
            if pulse_i = '1' then
                src_pulse_reg <= not src_pulse_reg;
            end if;
        end if;
    end process;

    sync : process (dest_clk, dest_rst_i)
    begin
        if dest_rst_i = '1' then
            transition_reg <= '0';
            dest_pulse_reg <= (others => '0');
        elsif rising_edge(dest_clk) then
            dest_pulse_reg(0) <= src_pulse_reg;
            dest_pulse_reg(1) <= dest_pulse_reg(0);
            transition_reg <= dest_pulse_reg(1);
        end if;
    end process;
    pulse_o <= dest_pulse_reg(1) xor transition_reg;
end arch;
