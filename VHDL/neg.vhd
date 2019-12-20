library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity inverter is
    port(
        a: in std_logic;
        a_n: out std_logic
    );
end inverter;

architecture arch of inverter is
    
begin
    a_n <= not a;
   
end arch; -- arch
