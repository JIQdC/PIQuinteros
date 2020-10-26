----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Downsampler treshold loadable register
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-09-30
-- Additional Comments:
-- Corregido para 
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity downsampler_tresh_reg is
  generic (
    N_tr_b : integer := 10
  );
  port (
    d_clk_i        : in std_logic;
    rst_i          : in std_logic;
    treshold_i     : in std_logic_vector((N_tr_b - 1) downto 0);
    treshold_ld_i  : in std_logic;
    treshold_reg_o : out std_logic_vector((N_tr_b - 1) downto 0)
  );
end downsampler_tresh_reg;

architecture arch of downsampler_tresh_reg is

  signal tresh_reg, tresh_next : std_logic_vector((N_tr_b - 1) downto 0) := (others => '0');

  --Xilinx attributes
  attribute X_INTERFACE_INFO                 : string;
  attribute X_INTERFACE_INFO of d_clk_i      : signal is "xilinx.com:signal:clock:1.0 d_clk_i CLK";
  attribute X_INTERFACE_INFO of rst_i        : signal is "xilinx.com:signal:reset:1.0 rst_i RST";
  attribute X_INTERFACE_PARAMETER            : string;
  attribute X_INTERFACE_PARAMETER of d_clk_i : signal is "ASSOCIATED_ASYNC_RESET rst";
  attribute X_INTERFACE_PARAMETER of rst_i   : signal is "POLARITY ACTIVE_HIGH";

begin

  process (d_clk_i, rst_i)
  begin
    if (rst_i = '1') then
      tresh_reg <= (others => '0');
    elsif (rising_edge(d_clk_i)) then
      tresh_reg <= tresh_next;
    end if;
  end process;

  process (tresh_reg, treshold_i, treshold_ld_i)
  begin
    tresh_next     <= tresh_reg;
    treshold_reg_o <= tresh_reg;

    if (treshold_ld_i = '1') then
      tresh_next <= treshold_i;
    end if;
  end process;

end arch; -- arch