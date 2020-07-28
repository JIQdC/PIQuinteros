----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Módulo para debug y control de señales hacia FIFO
-- 
-- Dependencies: 
-- 
-- Revision: 2020-07-23
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity debug_control is
    generic(
        N: integer := 14
    );
    port(
        control_i: in std_logic_vector(3 downto 0);             --señal de control
        usr_w1_i, usr_w2_i: in std_logic_vector((N-1) downto 0);--palabras configurables por el usuario
        d_out_i: in std_logic_vector((N-1) downto 0);           --datos del deserializador
        d_valid_i: in std_logic;                                --trigger del deserializador

        --entrada de counter
        counter_count_i: in std_logic_vector((N-1) downto 0);
        --salida hacia counter
        counter_ce_o: out std_logic;

        --salidas hacia FIFO
        d_out_o: out std_logic_vector((N-1) downto 0);
        wr_en_o: out std_logic
        );
end debug_control;

architecture arch of debug_control is
    --señales constantes
    signal onesNbits: std_logic_vector((N-1) downto 0) := (others => '1');
    signal zerosNbits: std_logic_vector((N-1) downto 0) := (others => '0');

    --señal para midscale short
    signal midscaleShort: std_logic_vector(13 downto 0) := "10000000000000";
    --señales para 1x sync
    signal sync_1x: std_logic_vector(13 downto 0) := "00000001111111";
    --señales para mixed frequency
    signal mix_freq: std_logic_vector(13 downto 0) := "10100001100111";

begin
    --multiplexo la salida hacia FIFO
    d_out_o <=
        zerosNbits when (control_i="0000" or control_i="0011") else     --Off(default) / -Full-scale short
        midscaleShort when (control_i="0001" or control_i="1011") else  --Midscale short / one bit high
        onesNbits when control_i="0010" else                            --+Full-scale short
        usr_w1_i when control_i="1000" else                             --usr_w1
        usr_w2_i when control_i="1001" else                             --usr_w2
        sync_1x when control_i="1010" else                              --1x sync
        mix_freq when control_i="1100" else                             --mixed frequency
        counter_count_i when control_i="1111" else                      --contador de N bits (no incluido en secuencias de fábrica)
        d_out_i when control_i="1101" else                              --señal del deserializador (no incluido en secuencias de fábrica)
        zerosNbits;  
        
    --multiplexo wr_en.         
    wr_en_o <=
        '0' when control_i="0000" else
        d_valid_i;

    --clock enable para contador
    counter_ce_o <= '1' when control_i="1111" else
                    '0';

end arch;