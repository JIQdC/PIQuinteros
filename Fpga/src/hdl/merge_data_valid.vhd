library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity merge_data_valid is
  generic (
    DATA_WIDTH : integer := 32;
    GROUP_BY   : integer := 2);
  port (
    clk_i         : in std_logic;
    rst_ni        : in std_logic;
    s_axis_tdata  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_axis_tvalid : in std_logic;
    m_axis_tdata  : out std_logic_vector(DATA_WIDTH * GROUP_BY - 1 downto 0);
    m_axis_tvalid : out std_logic_vector(GROUP_BY - 1 downto 0)
  );
end merge_data_valid;
architecture rtl of merge_data_valid is
  type state_type is (IDLE, GROUPPING);
  signal state : state_type := IDLE;
  signal count : integer := 0;
  signal data_reg : std_logic_vector(DATA_WIDTH * GROUP_BY - 1 downto 0);
  signal valid_reg : std_logic_vector(GROUP_BY - 1 downto 0);
begin
  process (clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      state <= IDLE;
      count <= 0;
      data_reg <= (others => '0');
      valid_reg <= (others => '0');
    elsif rising_edge(clk_i) then
      valid_reg <= (others => '0');
      case state is
        when IDLE =>
          if s_axis_tvalid = '1' then
            state <= GROUPPING;
            count <= 0;
            data_reg(DATA_WIDTH - 1 downto 0) <= s_axis_tdata;
          end if;
        when GROUPPING =>
          if (s_axis_tvalid = '1') then
            if count < GROUP_BY - 1 then
              count <= count + 1;
              data_reg(DATA_WIDTH * (count + 1) - 1 downto DATA_WIDTH * count) <= s_axis_tdata;
            else
              state <= IDLE;
              count <= 0;
              valid_reg <= (others => '1');
            end if;
          end if;
      end case;

    end if;
  end process;

  m_axis_tdata <= data_reg;
  m_axis_tvalid <= valid_reg;
end rtl;
