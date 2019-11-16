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
        --tri-state control
        tristate_en: in std_logic
    );
end SPI_3wire;



architecture arch of SPI_3wire is
    signal p_inout: std_logic;
    
begin

    --TSB: OBUFT
    --port map(I => proc_mosi, O => adc_sdio, T => tristate_en);
    adc_sdio <= p_inout;
    p_inout <= proc_mosi when (tristate_en = '0') else 'Z';

    adc_sclk <= proc_sclk;
    adc_ss1 <= proc_ss1;
    adc_ss2 <= proc_ss2;
    proc_miso <= p_inout;

   
end arch; -- arch
