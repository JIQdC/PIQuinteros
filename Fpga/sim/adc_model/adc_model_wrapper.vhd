----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name:
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Wrapper del núcleo del ADC y de las secuencias de prueba.
-- 
-- Dependencies: 
-- 
-- Revision: 2020-11-16
-- Additional Comments:
-- Consideraciones de uso
-- * Las secuencias de uso se eligen mediante la palabra control de entrada. La codificación es la provista
-- en la hoja de datos del AD9249 (con excepción del contador, que se elige con la palabra "1111").
-- * Se debe resetear el modelo antes de empezar a simular, y se recomienda hacerlo luego de cambiar la
-- secuencia de salida.
-- * El tiempo del interno T_CLK_PERIOD debe elegirse mucho menor al tiempo de muestreo T_SAMPLE.
-- * Las palabras configurables usr_w1, usr_w2, se utilizan como entradas en modo user input.
-- * La palabra configurable usr_w1 se utiliza como valor inicial del contador.
-- * Se utiliza la codificación binaria con offset (V_min = 0...0 y V_max = 1...1).
-- * Los modos midscale short/one bit high, checkerboard, 1x sync y mixed frequency están definidos
-- solamente para N=14 bits.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ADCmodel_wrapper is
  generic (
    N            : integer := 14;
    T_SAMPLE     : time    := 14 ns;  --período de muestreo del ADC
    T_DELAY      : time    := 2.3 ns; --tiempo de propagación entre muestreo y dato
    T_CLK_PERIOD : time    := 1 ns    --período del clock usado para los generadores de secuencias 
  );
  port (
    rst_n                : in std_logic;                          --reset general
    usr_w1, usr_w2       : in std_logic_vector((N - 1) downto 0); --palabras configurables por el usuario
    control              : in std_logic_vector(3 downto 0);       --señal de control de 4 bits para elegir la secuencia de salida
    adc_DCO_p, adc_DCO_n : out std_logic;
    adc_FCO_p, adc_FCO_n : out std_logic;
    adc_D_p, adc_D_n     : out std_logic --señales de salida del ADC
  );
end ADCmodel_wrapper;

architecture arch of ADCmodel_wrapper is
  --"cables"
  signal clk, usr_ready, usr_done                                : std_logic;
  signal d, d_wordToggle, d_contN, d_chk, d_usrToggle, d_oneZero : std_logic_vector((N - 1) downto 0);
  signal adc_DCO, adc_FCO, adc_D                                 : std_logic := '0';
  --señales constantes
  signal onesNbits  : std_logic_vector((N - 1) downto 0) := (others => '1');
  signal zerosNbits : std_logic_vector((N - 1) downto 0) := (others => '0');
  --a partir de aquí, las señales valen sólo para N=14
  --señal para midscale short
  signal midscaleShort : std_logic_vector((N - 1) downto 0) := "10000000000000";
  --señales para checkerboard
  signal chk_1 : std_logic_vector((N - 1) downto 0) := "10101010101010";
  signal chk_2 : std_logic_vector((N - 1) downto 0) := "01010101010101";
  --señales para 1x sync
  signal sync_1x : std_logic_vector((N - 1) downto 0) := "00000001111111";
  --señales para mixed frequency
  signal mix_freq : std_logic_vector((N - 1) downto 0) := "10100001100111";
begin
  --INSTANCIACIÓN DE COMPONENTES

  --clock para los generadores
  tb_clk : entity work.tb_clk(sim)
    generic map(T_CLK_PERIOD => T_CLK_PERIOD)
    port map(clk_o           => clk);
  --wordToggle con palabras personalizadas
  usr_wordToggle : entity work.w1w2WordToggle(arch)
    generic map(N => N)
    port map(
      clk => clk, rst_n => rst_n, usr_ready => usr_ready,
      usr_done => usr_done, w1 => usr_w1, w2 => usr_w2, d_out => d_usrToggle);

  --checkerboard usando wordToggle
  checkerboard : entity work.w1w2WordToggle(arch)
    generic map(N => N)
    port map(
      clk => clk, rst_n => rst_n, usr_ready => usr_ready,
      usr_done => usr_done, w1 => chk_1, w2 => chk_2, d_out => d_chk);

  --one/zero word toggle usando wordToggle
  oneZeroWordToggle : entity work.w1w2WordToggle(arch)
    generic map(N => N)
    port map(
      clk => clk, rst_n => rst_n, usr_ready => usr_ready,
      usr_done => usr_done, w1 => onesNbits, w2 => zerosNbits, d_out => d_oneZero);

  --contador (no incluido en modelos del ADC)
  cont : entity work.contNbits(arch)
    generic map(N => N)
    port map(
      clk => clk, rst_n => rst_n, d_in => usr_w1, usr_ready => usr_ready,
      usr_done => usr_done, d_out => d_contN);

  --core del ADC
  DUT : entity work.ADC_model(arch)
    generic map(N => N, T_SAMPLE => T_SAMPLE, T_DELAY => T_DELAY)
    port map(
      rst_n => rst_n, d_in => d, adc_DCO => adc_DCO, adc_FCO => adc_FCO, adc_D => adc_D,
      usr_ready => usr_ready, usr_done => usr_done);

  --multiplexo la entrada al core del ADC
  d <=
    zerosNbits when (control = "0000" or control = "0011") else    --Off(default) / -Full-scale short
    midscaleShort when (control = "0001" or control = "1011") else --Midscale short / one bit high
    onesNbits when control = "0010" else                           --+Full-scale short
    d_chk when control = "0100" else                               --checkerboard
    d_oneZero when control = "0111" else                           --one/zero word toggle
    d_usrToggle when control = "1000" else                         --user input
    chk_1 when control = "1001" else                               --1/0 bit toggle
    sync_1x when control = "1010" else                             --1x sync
    mix_freq when control = "1100" else                            --mixed frequency
    d_contN when control = "1111" else                             --contador de N bits (no incluido en secuencias de fábrica)
    zerosNbits;

  --output drive
  adc_DCO_p <= adc_DCO;
  adc_DCO_n <= not(adc_DCO);
  adc_FCO_p <= adc_FCO;
  adc_FCO_n <= not(adc_FCO);
  adc_D_p   <= adc_D;
  adc_D_n   <= not(adc_D);

end arch;