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
-- Revision: 2020-02-28
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
        clk_fpga_i: in std_logic;                               --clock de FPGA
        frame_i: in std_logic;                                  --señal frame de ADC
        clk_adc_i: in std_logic;                                --clock de ADC
        select_clk_i: in std_logic;                             --selector de señal de clock
        rst_i: in std_logic;                                    --reset para módulos de debug
        control_i: in std_logic_vector(3 downto 0);             --señal de control
        usr_w1_i, usr_w2_i: in std_logic_vector((N-1) downto 0);--palabras configurables por el usuario
        d_out_i: in std_logic_vector((N-1) downto 0);           --datos del deserializador
        d_valid_i: in std_logic;                                --trigger del deserializador

        --salidas hacia FIFO
        d_out_o: out std_logic_vector((N-1) downto 0);
        wr_en_o: out std_logic;
        wr_clk_o: out std_logic
        );
end debug_control;

architecture arch of debug_control is
    --señales constantes
    signal onesNbits: std_logic_vector((N-1) downto 0) := (others => '1');
    signal zerosNbits: std_logic_vector((N-1) downto 0) := (others => '0');

    --"cables"
    signal clk, rst_n: std_logic;
    signal d, d_wordToggle, d_contN, d_chk, d_usrToggle, d_oneZero: std_logic_vector((N-1) downto 0);
    --señal para midscale short
    signal midscaleShort: std_logic_vector(13 downto 0) := "10000000000000";    --señales para checkerboard
    signal chk_1: std_logic_vector(13 downto 0) := "10101010101010";
    signal chk_2: std_logic_vector(13 downto 0) := "01010101010101";
    --señales para 1x sync
    signal sync_1x: std_logic_vector(13 downto 0) := "00000001111111";
    --señales para mixed frequency
    signal mix_freq: std_logic_vector(13 downto 0) := "10100001100111";

    --señal para selección de clock
    signal bufgmux_S: std_logic := '0';
begin
    --negación de reset
    rst_n <= not(rst_i);

    --selector de clock
    clk <=  clk_fpga_i when (select_clk_i = '1') else
            frame_i;

    --INSTANCIACIÓN DE COMPONENTES

    --wordToggle con palabras personalizadas
    usr_wordToggle: entity work.w1w2WordToggle_debug(arch)
        generic map(N => N)
        port map(clk => clk, rst_n => rst_n, w1 => usr_w1_i, w2 => usr_w2_i, d_out => d_usrToggle);
    --checkerboard usando wordToggle
    checkerboard: entity work.w1w2WordToggle_debug(arch)
        generic map(N => N)
        port map(clk => clk, rst_n => rst_n, w1 => chk_1, w2 => chk_2, d_out => d_chk);
    --one/zero word toggle usando wordToggle
    oneZeroWordToggle: entity work.w1w2WordToggle_debug(arch)
        generic map(N => N)
        port map(clk => clk, rst_n => rst_n, w1 => onesNbits, w2 => zerosNbits, d_out => d_oneZero);
    --contador (no incluido en modelos del ADC)
    cont: entity work.contNbits_debug(arch)
        generic map(N => N)
        port map(clk => clk, rst_n => rst_n, d_in => usr_w1_i, d_out => d_contN); 

    --multiplexo la salida hacia FIFO
    d_out_o <=
        zerosNbits when (control_i="0000" or control_i="0011") else     --Off(default) / -Full-scale short
        midscaleShort when (control_i="0001" or control_i="1011") else  --Midscale short / one bit high
        onesNbits when control_i="0010" else                          --+Full-scale short
        d_chk when control_i="0100" else                              --checkerboard
        d_oneZero when control_i="0111" else                          --one/zero word toggle
        d_usrToggle when control_i="1000" else                        --user input
        chk_1 when control_i="1001" else                              --1/0 bit toggle
        sync_1x when control_i="1010" else                            --1x sync
        mix_freq when control_i="1100" else                           --mixed frequency
        d_contN when control_i="1111" else                            --contador de N bits (no incluido en secuencias de fábrica)
        d_out_i when control_i="1101" else                            --señal del deserializador (no incluido en secuencias de fábrica)
        zerosNbits;  
        
    --multiplexo wr_en. Para los módulos de debug es directamente el clk que se esté usando        
    wr_en_o <=
        d_valid_i when control_i="1101" else
        '0' when control_i="0000" else
        '1';

    -- --multiplexo clk de escritura. Si los datos son del ADC (o si se usa el clk del ADC para los módulos de debug), se usa ese clk
    -- bufgmux_S <=    '0' when (select_clk_i = '0' or control_i="1101") else
    --                 '1';

    -- BUFGMUX_inst: BUFGMUX
    -- port map
    -- (
    --     O => wr_clk_o, I0 => clk_adc_i, I1 => clk_fpga_i, S => bufgmux_S
    -- );
    wr_clk_o <= clk_adc_i;
    -- wr_clk_o <=
    --     clk_adc_i when (select_clk_i = '0' or control_i="1101") else
    --     clk_fpga_i;

end arch;