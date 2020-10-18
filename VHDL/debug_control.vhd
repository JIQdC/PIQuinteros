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
-- Revision: 2020-10-10
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
    enable_i   : in std_logic;                                    --global enable
    control_i  : in std_logic_vector(3 downto 0);                 --multiplexer control
    usr_w2w1_i : in std_logic_vector((2 * RES_ADC - 1) downto 0); --user constants
    data_i     : in std_logic_vector((RES_ADC - 1) downto 0);     --deserializer data
    valid_i    : in std_logic;                                    --deserializer trigger

    counter_count_i : in std_logic_vector((RES_ADC - 1) downto 0);
    counter_ce_o    : out std_logic;

    data_o  : out std_logic_vector((RES_ADC - 1) downto 0);
    valid_o : out std_logic
  );
end debug_control;

architecture arch of debug_control is
  signal onesNbits  : std_logic_vector((RES_ADC - 1) downto 0) := (others => '1');
  signal zerosNbits : std_logic_vector((RES_ADC - 1) downto 0) := (others => '0');

  signal midscaleShort : std_logic_vector(13 downto 0) := "10000000000000";
  signal sync_1x       : std_logic_vector(13 downto 0) := "00000001111111";
  signal mix_freq      : std_logic_vector(13 downto 0) := "10100001100111";

  --Xilinx parameters
  attribute X_INTERFACE_INFO                      : string;
  attribute X_INTERFACE_INFO of counter_ce_o      : signal is "xilinx.com:signal:clockenable:1.0 counter_ce_o CE";
  attribute X_INTERFACE_PARAMETER                 : string;
  attribute X_INTERFACE_PARAMETER of counter_ce_o : signal is "POLARITY ACTIVE_HIGH";

begin
  --data multiplexing
  data_o <=
    zerosNbits when (control_i = "0000" or control_i = "0011" or enable_i = '0') else --Off(default) / -Full-scale short / Disabled
    midscaleShort when (control_i = "0001" or control_i = "1011") else                --Midscale short / one bit high
    onesNbits when control_i = "0010" else                                            --+Full-scale short
    usr_w2w1_i((2 * RES_ADC - 1) downto RES_ADC) when control_i = "1001" else         --usr_w2
    usr_w2w1_i((RES_ADC - 1) downto 0) when control_i = "1000" else                   --usr_w1
    sync_1x when control_i = "1010" else                                              --1x sync
    mix_freq when control_i = "1100" else                                             --mixed frequency
    counter_count_i when control_i = "1111" else                                      --contador de RES_ADC bits (no incluido en secuencias de fábrica)
    data_i when control_i = "1101" else                                               --señal del deserializador (no incluido en secuencias de fábrica)
    zerosNbits;

  --valid multiplexing       
  valid_o <=
    '0' when (control_i = "0000" or enable_i = '0') else
    valid_i;

  --counter CE
  counter_ce_o <= '1' when control_i = "1111" else
    '0';

end arch;