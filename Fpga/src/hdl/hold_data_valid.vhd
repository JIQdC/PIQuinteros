library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity hold_data_valid is
  generic (
    DATA_LENGTH    : integer := 32;
    NUM_OF_PERIODS : integer := 2);
  port (
    clk_i         : in std_logic;
    rst_ni        : in std_logic;
    s_axis_tdata  : in std_logic_vector(DATA_LENGTH - 1 downto 0);
    s_axis_tvalid : in std_logic;
    m_axis_tdata  : out std_logic_vector(DATA_LENGTH - 1 downto 0);
    m_axis_tvalid : out std_logic;
    current_cycle : out std_logic_vector(2 downto 0)
  );
end hold_data_valid;

architecture rtl of hold_data_valid is
  type state_type is (IDLE, HOLD);
  signal state : state_type := IDLE;
  signal count : integer := 0;
  signal s_axis_tdata_reg : std_logic_vector(DATA_LENGTH - 1 downto 0);
  signal s_axis_tvalid_reg : std_logic;
begin
  fsm : process (clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      state <= IDLE;
      count <= 0;
      s_axis_tdata_reg <= (others => '0');
      s_axis_tvalid_reg <= '0';
    elsif rising_edge(clk_i) then
      case state is
        when IDLE =>
          count <= 0;
          if s_axis_tvalid = '1' then
            state <= HOLD;
            count <= count + 1;

            s_axis_tdata_reg <= s_axis_tdata;
            s_axis_tvalid_reg <= '1';
          end if;
        when HOLD =>
          if count < NUM_OF_PERIODS then
            count <= count + 1;
            s_axis_tdata_reg <= s_axis_tdata_reg;
            s_axis_tvalid_reg <= '1';
          else
            state <= IDLE;
            s_axis_tvalid_reg <= '0';
          end if;
        when others =>
          state <= IDLE;
      end case;
    end if;
  end process;

  m_axis_tdata <= s_axis_tdata_reg;
  m_axis_tvalid <= s_axis_tvalid_reg;
  current_cycle <= std_logic_vector(to_unsigned(count, 3));
end rtl;
