----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: SPI 3 wire
-- 
-- Dependencies: None.
-- 
-- Revision: 2019-11-15
-- Additional Comments: Este modelo DEBE SER SINTETIZABLE!!
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity SPI_3wire is
    port(
        --FPGA clock and reset
        fpga_clk: in std_logic;
        rst_n: in std_logic;
        --from/to processor
        proc_sclk: in std_logic;
        proc_ss1: in std_logic;
        proc_ss2: in std_logic;
        proc_mosi: in std_logic;
        proc_miso: out std_logic;
        --from/to ADC
        adc_sclk: out std_logic;
        adc_ss1: out std_logic;
        adc_ss2: out std_logic;
        adc_sdio: inout std_logic;
        --read enable and tristate
        read_en: in std_logic;
        tristate: out std_logic;
        --test output for sdio
        test_sdio_o: out std_logic
    );
end SPI_3wire;



architecture arch of SPI_3wire is
    signal p_inout: std_logic;
    signal tristate_en: std_logic := '0';
    signal ssel: std_logic := '1';   
    
    type state_t is (read,write);
    signal state_reg, state_next: state_t := write;
    
begin
    --READ ENABLE LOGIC
    --both slaves are equally important
    ssel <= proc_ss1 and proc_ss2;

    --state update
    process(fpga_clk,rst_n)
    begin
        if(rst_n = '0') then
            state_reg <= write;
        elsif(rising_edge(fpga_clk)) then
            state_reg <= state_next;
        end if;
    end process;

    --next state logic and tristate_en logic. Transitions between states can only happen when ssel is asserted
    process(state_reg,ssel,read_en)
    begin
        case state_reg is
            when write =>
                if(ssel = '1' and read_en = '1') then
                    state_next <= read;
                end if;
                tristate_en <= '0';
            when read =>
                if(ssel = '1' and read_en = '0') then
                    state_next <= write;
                end if;
                tristate_en <= '1';
        end case;
    end process;

    --tristate logic
    adc_sdio <= p_inout;
    p_inout <= proc_mosi when (tristate_en = '0') else 'Z';
    
    --OUTPUT MAPPING
    adc_sclk <= proc_sclk;
    adc_ss1 <= proc_ss1;
    adc_ss2 <= proc_ss2;
    proc_miso <= p_inout;
    tristate <= tristate_en;

    --test output logic
    test_sdio_o <= proc_mosi when (tristate_en = '0') else adc_sdio;
   
end arch; -- arch
