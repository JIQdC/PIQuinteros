----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: FIFO input multiplexing for control and debugging
--
-- Dependencies:
--
-- Revision: 2020-11-19
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity debug_control is
  generic (
    RES_ADC : integer := 14
  );
  port (
    clock_i         : in std_logic;
    rst_i           : in std_logic;
    enable_i        : in std_logic;                                    --global enable
    control_i       : in std_logic_vector(3 downto 0);                 --multiplexer control
    usr_w2w1_i      : in std_logic_vector((2 * RES_ADC - 1) downto 0); --user constants
    data_i          : in std_logic_vector((RES_ADC - 1) downto 0);     --deserializer data
    valid_i         : in std_logic;                                    --deserializer trigger

    counter_count_i : in std_logic_vector((RES_ADC - 1) downto 0);
    counter_ce_o    : out std_logic;

    data_o          : out std_logic_vector((RES_ADC - 1) downto 0);
    valid_o         : out std_logic
  );
end debug_control;

architecture arch of debug_control is
  signal onesNbits : std_logic_vector((RES_ADC - 1) downto 0) := (others => '1');
  signal zerosNbits : std_logic_vector((RES_ADC - 1) downto 0) := (others => '0');

  constant midscaleShort : std_logic_vector(13 downto 0) := "10000000000000";
  constant sync_1x : std_logic_vector(13 downto 0) := "00000001111111";
  constant mix_freq : std_logic_vector(13 downto 0) := "10100001100111";

  signal out_reg, out_next : std_logic_vector((RES_ADC - 1) downto 0) := (others => '0');
  signal valid_reg, valid_next : std_logic := '0';
  signal counter_ce_reg, counter_ce_next : std_logic := '0';

  --Xilinx parameters
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of counter_ce_o : signal is "xilinx.com:signal:clockenable:1.0 counter_ce_o CE";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of counter_ce_o : signal is "POLARITY ACTIVE_HIGH";

begin
  process (clock_i, rst_i)
  begin
    if (rst_i = '1') then
      out_reg <= zerosNbits;
      valid_reg <= '0';
      counter_ce_reg <= '0';
    elsif (rising_edge(clock_i)) then
      out_reg <= out_next;
      valid_reg <= valid_next;
      counter_ce_reg <= counter_ce_next;
    end if;
  end process;

  process (out_reg, valid_reg, counter_ce_reg, control_i, enable_i, counter_count_i, data_i)
  begin
    out_next <= out_reg;
    valid_next <= valid_reg;
    counter_ce_next <= counter_ce_reg;

    if (control_i = "0000" or control_i = "0011" or enable_i = '0') then
      out_next <= zerosNbits;
    elsif (control_i = "1101") then
      out_next <= data_i;
    elsif (control_i = "1111") then
      out_next <= counter_count_i;
    elsif (control_i = "0001" or control_i = "1011") then
      out_next <= midscaleShort;
    elsif (control_i = "0010") then
      out_next <= onesNbits;
    elsif (control_i = "1001") then
      out_next <= usr_w2w1_i((2 * RES_ADC - 1) downto RES_ADC);
    elsif (control_i = "1000") then
      out_next <= usr_w2w1_i((RES_ADC - 1) downto 0);
    elsif (control_i = "1010") then
      out_next <= sync_1x;
    elsif (control_i = "1100") then
      out_next <= mix_freq;
    else
      out_next <= zerosNbits;
    end if;

    if (control_i = "0000" or enable_i = '0') then
      valid_next <= '0';
    else
      valid_next <= valid_i;
    end if;

    if (control_i = "1111" and enable_i = '1') then
      counter_ce_next <= '1';
    else
      counter_ce_next <= '0';
    end if;

  end process;

  data_o <= out_reg;
  valid_o <= valid_reg;
  counter_ce_o <= counter_ce_reg;

  --data multiplexing
  -- data_o <=
  --   zerosNbits when (control_i = "0000" or control_i = "0011" or enable_i = '0') else --Off(default) / -Full-scale short / Disabled
  --   midscaleShort when (control_i = "0001" or control_i = "1011") else                --Midscale short / one bit high
  --   onesNbits when control_i = "0010" else                                            --+Full-scale short
  --   usr_w2w1_i((2 * RES_ADC - 1) downto RES_ADC) when control_i = "1001" else         --usr_w2
  --   usr_w2w1_i((RES_ADC - 1) downto 0) when control_i = "1000" else                   --usr_w1
  --   sync_1x when control_i = "1010" else                                              --1x sync
  --   mix_freq when control_i = "1100" else                                             --mixed frequency
  --   counter_count_i when control_i = "1111" else                                      --contador de RES_ADC bits (no incluido en secuencias de fábrica)
  --   data_i when control_i = "1101" else                                               --señal del deserializador (no incluido en secuencias de fábrica)
  --   zerosNbits;

  -- --valid multiplexing
  -- valid_o <=
  --   '0' when (control_i = "0000" or enable_i = '0') else
  --   valid_i;

  -- --counter CE
  -- counter_ce_o <= '1' when control_i = "1111" else
  --   '0';

end arch;
