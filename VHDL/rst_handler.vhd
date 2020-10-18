----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Reset handler
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-09-25
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity rst_handler is
    port (
        rst_fifo_i        : in std_logic;
        async_rst_i       : in std_logic;
        rst_peripherals_i : in std_logic_vector(1 downto 0);

        rst_fifo_o        : out std_logic;
        async_rst_o       : out std_logic
    );
end rst_handler;

architecture arch of rst_handler is
    --Xilinx attributes
    attribute X_INTERFACE_INFO : string;
    attribute X_INTERFACE_INFO of rst_fifo_i : signal is "xilinx.com:signal:reset:1.0 rst_fifo_i RST";
    attribute X_INTERFACE_INFO of async_rst_i : signal is "xilinx.com:signal:reset:1.0 async_rst_i RST";
    attribute X_INTERFACE_INFO of rst_peripherals_i : signal is "xilinx.com:signal:reset:1.0 rst_peripherals_i RST";
    attribute X_INTERFACE_INFO of rst_fifo_o : signal is "xilinx.com:signal:reset:1.0 rst_fifo_o RST";
    attribute X_INTERFACE_INFO of async_rst_o : signal is "xilinx.com:signal:reset:1.0 async_rst_o RST";

    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_PARAMETER of rst_fifo_i : signal is "POLARITY ACTIVE_HIGH";
    attribute X_INTERFACE_PARAMETER of async_rst_i : signal is "POLARITY ACTIVE_HIGH";
    attribute X_INTERFACE_PARAMETER of rst_peripherals_i : signal is "POLARITY ACTIVE_HIGH";
    attribute X_INTERFACE_PARAMETER of rst_fifo_o : signal is "POLARITY ACTIVE_HIGH";
    attribute X_INTERFACE_PARAMETER of async_rst_o : signal is "POLARITY ACTIVE_HIGH";

begin
    rst_fifo_o <= rst_fifo_i or rst_peripherals_i(1);
    async_rst_o <= async_rst_i or rst_peripherals_i(0);
end arch; -- arch