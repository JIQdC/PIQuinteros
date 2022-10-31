library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity bit_selector is
    generic (
        INPUT_WIDTH : integer := 8;
        BIT_NUMBER : integer := 0
    );
    port (
        input : in std_logic_vector(INPUT_WIDTH-1 downto 0);
        output : out std_logic
    );
end bit_selector;

architecture Behavioral of bit_selector is
begin
    output <= input(BIT_NUMBER);
end Behavioral;