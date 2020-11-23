----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Contador de N bits. Este contador toma como value on reset, el dato d_in
-- que se le pasa como entrada. Luego suma con cada flanco descendente de la señal.
-- Las señales rst_n, usr_ready, sirven como resets. 
-- 
-- Dependencies: None.
-- 
-- Revision: 2019-10-29
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity contNbits is
  generic (
    N : integer := 14 --cantidad de bits del contador
  );
  port (
    clk       : in std_logic;
    rst_n     : in std_logic;
    d_in      : in std_logic_vector((N - 1) downto 0);
    usr_ready : in std_logic; --flag que indica si ya se enganchó con adc_FCO
    usr_done  : in std_logic; --flag que indica si ya se capturó el dato
    d_out     : out std_logic_vector((N - 1) downto 0)
  );
end contNbits;

architecture arch of contNbits is
  signal zerosNbits : std_logic_vector((N - 1) downto 0) := (others => '0');
  signal onesNbits  : std_logic_vector((N - 1) downto 0) := (others => '1');
  --registro para el contador
  signal d_reg, d_next : std_logic_vector((N - 1) downto 0) := (others => '0');
  --aux para suma
  signal sum : unsigned((N - 1) downto 0) := (others => '0');

begin
  --state register
  process (clk, rst_n, usr_ready)
  begin
    if (rst_n = '0' or usr_ready = '0') then
      d_reg <= d_in;
    elsif (rising_edge(clk)) then
      d_reg <= d_next;
    end if;
  end process;

  --actualizaciones
  sum <= unsigned(d_reg) + 1;

  d_next <= std_logic_vector(sum) when (falling_edge(usr_done) and not (d_reg = onesNbits)) else --si aún no llegué al máximo, sumo
    zerosNbits when falling_edge(usr_done) else                                                    --si llegué al máximo, reseteo
    d_reg;                                                                                         --si no pasó ninguna de las anteriores, me quedo donde estoy

  --output logic
  d_out <= d_reg;

end arch; -- arch