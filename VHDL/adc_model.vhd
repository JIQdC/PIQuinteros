----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Modelo del conversor AD9249
-- 
-- Dependencies: None.
-- 
-- Revision: 2019-10-21
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity ADC_model is
    generic(
        N: integer := 14; --cantidad de bits del ADC
        T_SAMPLE : time := 14 ns; --período de muestreo del ADC
        T_DELAY : time := 2.3 ns --tiempo de propagación entre muestreo y dato
    );
    port(
        rst_n: in std_logic;
        d_in: in std_logic_vector((N-1) downto 0);
        usr_ready: out std_logic; --flag que indica si ya se enganchó con adc_FCO
        adc_DCO: out std_logic;
        adc_FCO: out std_logic;
        adc_D: out std_logic
    );
end ADC_model;

architecture arch of ADC_model is
    --variables para los tiempos de los clocks
    constant T_BIT: time := T_SAMPLE/N;
    --registro para almacenar el dato que entra en paralelo
    signal adc_D_reg, adc_D_next: std_logic_vector((N-1) downto 0) := (others => '0');
    --señales auxiliares para los clocks internos
    signal clk_int,adc_FCO_int,adc_DCO_int,adc_D_int: std_logic := '0';
    --registro de estado
	type state_type is (idle,capture, tx);
    signal state_reg,state_next: state_type;
    --contador
    signal cont_reg,cont_next: integer := 0;

begin
    -- clock interno a la tasa de datos
    clk_int_process: process
    begin
            clk_int <= '1';
            wait for T_BIT/2;
            clk_int <= '0';
            wait for T_BIT/2;
    end process;

    --Proceso para generar la señal de frame
    adc_FCO_int_process: process
    begin
            adc_FCO_int <= '1';
            wait for T_SAMPLE/2;
            adc_FCO_int <= '0';
            wait for T_SAMPLE/2;
    end process;
    
    -- adc_DCO interno a la mitad de la tasa de datos (porque levanto datos en ambos flancos)
    adc_DCO_int_process: process
    begin
            adc_DCO_int <= '1';
            wait for T_BIT;
            adc_DCO_int <= '0';
            wait for T_BIT;
    end process;    

    --state register
    process(clk_int,rst_n)
    begin
        if (rst_n='0') then
            --el estado on reset del modelo es idle (espera a adc_FCO)
            state_reg <= idle;
            adc_D_reg <= (others=>'0');
            cont_reg <= 0;
        elsif(rising_edge(clk_int)) then
            state_reg <= state_next;
            adc_D_reg <= adc_D_next;
            cont_reg <= cont_next;
        end if;
    end process;

    --next state logic
    process(adc_D_reg,state_reg,cont_reg,adc_FCO_int,d_in)
    begin
        --default
        adc_D_next <= adc_D_reg;
        state_next <= state_reg;

        case state_reg is
            when idle =>
                --este estado debería ocurrir solo una vez, para engancharse con adc_FCO
                if(rising_edge(adc_FCO_int)) then
                    cont_next <= N-1;
                    adc_D_next <= d_in;
                    state_next <= tx;
                end if;
                --sino, queda en idle            
            when capture =>
                cont_next <= N-1;
                adc_D_next <= d_in;
                state_next <= tx;
            when tx =>
                if (cont_reg > 1) then
                    cont_next <= cont_reg - 1;
                    state_next <= tx;
                else
                    cont_next <= cont_reg - 1;
                    state_next <= capture;
                end if;
        end case;
    end process;

    --la salida siempre es...
    adc_D_int <= adc_D_reg(cont_reg);
    --flag que indica cuándo se enganchó con adc_FCO
    process(state_reg)
    begin
        case state_reg is
            when idle =>
                usr_ready <= '0';
            when others =>
                usr_ready <= '1';
        end case;
    end process;

    --delays para acomodar todo. todas las señales de salida tienen T_DELAY con respecto a la entrada
    --adc_FCO y adc_DCO se retardan T_BIT adicional para coincidir con el flujo de datos
    adc_D <= transport adc_D_int after T_DELAY;
    adc_FCO <= transport adc_FCO_int after T_BIT+T_DELAY;
    adc_DCO <= transport adc_DCO_int after T_BIT+T_DELAY+T_BIT/2; --retardo de T_BIT/2 para que los flancos queden en el centro de los datos
   
end arch; -- arch
