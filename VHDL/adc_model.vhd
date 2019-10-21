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
-- Revision: 2019-10-11
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity ADC_model is
    generic(
        N: integer := 14; --cantidad de bits del ADC
        t_sample : time := 7.69 ns; --tiempo en nanosegundos
        t_data : time := 549.29 ps;
        t_delay : time := 274.64 ps
        --t_FCO : real := 2.3 ns --propagación hasta frame
    );
    port(
        rst_n: in std_logic;
        d_in: in std_logic_vector((N-1) downto 0);
        DCO: out std_logic;
        FCO: out std_logic;
        DATA: out std_logic
    );
end ADC_model;

architecture arch of ADC_model is
    --variables para los tiempos de los clocks
    constant nseg: time := 1 ns;
    --signal t_data, t_sample, t_delay: time;
    --signal t_data_real, N_real, t_delay_real: real;
    --registro para almacenar el dato que entra en paralelo
    signal data_reg, data_next: std_logic_vector((N-1) downto 0) := (others => '0');
    --señales auxiliares para los clocks internos
    signal clk_int,FCO_int,DCO_int,DATA_int: std_logic := '0';
    --registro de estado
	type state_type is (capture, tx);
    signal state_reg,state_next: state_type;
    --contador
    signal cont_reg,cont_next: integer := 0;

begin
    --convert: process
    --begin
    --    N_real <= real(N);
    --    t_data_real <= t_sample_real/N_real;
    --    t_delay_real <= t_sample_real/(real(2)*N_real);
    --    t_data <= t_data_real * nseg;--tiempo de bit
    --    t_sample <= t_sample_real * nseg; --tiempo de muestra
    --    t_delay <= t_delay_real * nseg;
    --    wait;
    --end process;

    -- clock interno al doble de la tasa de datos
    clk_int_process: process
    begin
            clk_int <= '1';
            wait for t_data/4;
            clk_int <= '0';
            wait for t_data/4;
    end process;

    --Proceso para generar la señal de frame
    FCO_int_process: process
    begin
            FCO_int <= '1';
            wait for t_sample/2;
            FCO_int <= '0';
            wait for t_sample/2;
    end process;
    
    -- DCO interno a la tasa de datos
    DCO_int_process: process
    begin
            DCO_int <= '1';
            wait for t_data/2;
            DCO_int <= '0';
            wait for t_data/2;
    end process;    

    --state register
    process(clk_int,rst_n)
    begin
        if (rst_n='0') then
            --el estado on reset del modelo es capturar, de esta forma, debería sincronizarse
            --todo con los relojes (porque empieza capturando)
            state_reg <= capture;
            data_reg <= (others=>'0');
            cont_reg <= 0;
        elsif(rising_edge(clk_int)) then
            state_reg <= state_next;
            data_reg <= data_next;
            cont_reg <= cont_next;
        end if;
    end process;

    --next state logic
    process(data_reg,state_reg,cont_reg,FCO_int,d_in)
    begin
        --default
        data_next <= data_reg;
        state_next <= state_reg;

        case state_reg is
            when capture =>
                cont_next <= N-1;
                data_next <= d_in;
                state_next <= tx;
            when tx =>
                if (cont_reg > 0) then
                    cont_next <= cont_reg - 1;
                    state_next <= tx;
                else
                    state_next <= capture;
                end if;
        end case;
    end process;

    --output logic
    process(data_reg,state_reg)
    begin
        --default
        DATA_int <= '0';

        case state_reg is
            when capture =>
                DATA_int <= data_reg(cont_reg);
            when tx =>
                DATA_int <= data_reg(cont_reg);
        end case;
    end process;

    --delays para acomodar todo
    DATA <= DATA_int;
    FCO <= FCO_int;
    DCO <= DCO_int;     

   
end arch; -- arch
