----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: Guillermo Guichal
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Ejemplos básicos de diseño VHDL
-- 
-- Dependencies: None.
-- 
-- Revision: 2016-02-18.01
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tb_rst is
    generic(RST_ACTIVO      : std_logic := '1';
            T_RST_INICIO    : time := 25 ns;
            T_RST_ACTIVO    : time := 111 ns);
    port ( rst_sync_o   : out std_logic;
           rst_async_o  : out std_logic;
           clk_i        : in  std_logic := '0');
end tb_rst;

architecture sim of tb_rst is

begin

    proc_rst_async: process
    begin
        -- Resets desactivados
        rst_async_o <= not RST_ACTIVO;
        -- Esperar un poco
        wait for T_RST_INICIO; 
        --Activa reset
        rst_async_o  <= RST_ACTIVO;
        wait for T_RST_ACTIVO; 
        -- Desactiva reset
        rst_async_o <= not RST_ACTIVO;
        wait; 
    end process;    
    
    proc_rst_sync: process
    begin
        -- Resets desactivados
        rst_sync_o <= not RST_ACTIVO;
        -- Esperar un poco
        wait for T_RST_INICIO; 
        --Activa reset con reloj
        wait on clk_i until clk_i = '1';
        rst_sync_o  <= RST_ACTIVO;
        wait for T_RST_ACTIVO; 
        -- Desctiva reset con reloj
        wait on clk_i until clk_i = '1';
        rst_sync_o <= not RST_ACTIVO;
        wait; 
    end process;    
    
      
end sim;
