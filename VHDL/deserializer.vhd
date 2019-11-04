----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Deserializador
-- 
-- Dependencies: None.
-- 
-- Revision: 2019-11-04
-- Additional Comments: Este modelo DEBE SER SINTETIZABLE!!
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity deserializer is
    generic(
        N: integer := 14; --cantidad de bits del ADC
        N_b: integer := 4
    );
    port(
        rst_n: in std_logic;
        d_in: in std_logic;
        d_clk_in: in std_logic;
        d_frame: in std_logic;
        d_out: out std_logic_vector((N-1) downto 0);
        d_valid: out std_logic
    );
end deserializer;

architecture arch of deserializer is
    --constantes
    signal zerosNbits: std_logic_vector((N-1) downto 0) := (others => '0');
    signal d_reg, d_next: std_logic_vector((N-1) downto 0) := zerosNbits;
    --contador
    signal cont_reg, cont_next: unsigned((N_b) downto 0) := (others => '0');
    --valor de contador (ver que sintetice?)
    signal N_cont: unsigned((N_b) downto 0) := to_unsigned(N,N_b);
    --registro de estado
	type state_type is (idle,capture,valid);
    signal state_reg,state_next: state_type;

    begin
        --register
        process(d_clk_in,rst_n)
        begin
            if(rst_n = '0') then
                d_reg <= zerosNbits;
                cont_reg <= N_cont - 1;
                state_reg <= idle;
            elsif(rising_edge(d_clk_in)) then
                d_reg <= d_next;
                cont_reg <= cont_next;
                state_reg <= state_next;
            end if;
        end process;

        --next state logic
        process(state_reg,d_frame)
        begin
            --default
            state_next <= state_reg;
            cont_next <= cont_reg;
            d_next <= d_reg;

            case state_reg is
                when idle =>
                    if(rising_edge(d_frame)) then
                        --cont_next <= cont_reg - 1;
                        d_next <= d_reg((N-2) downto 0) & d_in;
                        state_next <= capture;
                    end if;
                when capture =>
                    if(cont_reg > to_unsigned(0,N_b)) then
                        cont_next <= cont_reg - 1;
                        d_next <= d_reg((N-2) downto 0) & d_in;
                    else --caso cont == 0
                        cont_next <= N_cont - 1; --reseteo contador
                        d_next <= d_reg((N-2) downto 0) & d_in;
                        state_next <= valid;
                    end if;
                when valid =>
                    --si llega otro dato, sigo capturando
                    if(rising_edge(d_frame)) then
                        cont_next <= cont_reg - 1;
                        d_next <= d_reg((N-2) downto 0) & d_in;
                        state_next <= capture;
                    --si no me llega otro frame, lo voy a esperar a idle
                    else
                        state_next <= idle;
                    end if;
        end case;
        end process;

        --output logic
        process(state_reg)
        begin
            --default
            d_out <= zerosNbits;
            d_valid <= '0';

            case state_reg is
                when idle =>

                when capture =>

                when valid =>
                    d_out <= d_reg;
                    d_valid <= '1';
            end case;

        end process;
   
end arch; -- arch
