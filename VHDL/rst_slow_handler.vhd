----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Reset handler for slow AXI interconnects
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-09-30
-- Additional Comments:
--  
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity rst_slow_handler is
    port (
        rstn_interconnect_i : in std_logic_vector(2 downto 0);
        rstn_S0_o           : out std_logic;
        rstn_M0_o           : out std_logic;
        rstn_M1_o           : out std_logic
    );
end rst_slow_handler;

architecture arch of rst_slow_handler is
    --Xilinx attributes
    attribute X_INTERFACE_INFO : string;
    attribute X_INTERFACE_INFO of rstn_interconnect_i : signal is "xilinx.com:signal:reset:1.0 rstn_interconnect_i RST";
    attribute X_INTERFACE_INFO of rstn_S0_o : signal is "xilinx.com:signal:reset:1.0 rstn_S0_o RST";
    attribute X_INTERFACE_INFO of rstn_M0_o : signal is "xilinx.com:signal:reset:1.0 rstn_M0_o RST";
    attribute X_INTERFACE_INFO of rstn_M1_o : signal is "xilinx.com:signal:reset:1.0 rstn_M1_o RST";

    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_PARAMETER of rstn_interconnect_i : signal is "POLARITY ACTIVE_LOW";
    attribute X_INTERFACE_PARAMETER of rstn_S0_o : signal is "POLARITY ACTIVE_LOW";
    attribute X_INTERFACE_PARAMETER of rstn_M0_o : signal is "POLARITY ACTIVE_LOW";
    attribute X_INTERFACE_PARAMETER of rstn_M1_o : signal is "POLARITY ACTIVE_LOW";

begin
    rstn_S0_o <= rstn_interconnect_i(2);
    rstn_M0_o <= rstn_interconnect_i(1);
    rstn_M1_o <= rstn_interconnect_i(0);

end arch; -- arch