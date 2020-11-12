----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Wrapper for frame clocking wizard
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-11-11
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity frame_clk_wiz is
  port (
    -- Clock out ports
    clk_to_preproc : out std_logic;
    fifo_wr_clk    : out std_logic;
    clk_to_counter : out std_logic;
    clk_to_debug   : out std_logic;
    -- Status and control signals
    reset   : in std_logic;
    locked  : out std_logic;
    clk_in1 : in std_logic
  );
end frame_clk_wiz;

architecture rtl of frame_clk_wiz is
  component clk_wiz_0
    port (-- Clock in ports
      -- Clock out ports
      clk_to_preproc : out std_logic;
      fifo_wr_clk    : out std_logic;
      clk_to_counter : out std_logic;
      clk_to_debug   : out std_logic;
      -- Status and control signals
      reset   : in std_logic;
      locked  : out std_logic;
      clk_in1 : in std_logic
    );
  end component;
begin
  clk_wiz_inst : clk_wiz_0
  port map(
    -- Clock out ports  
    clk_to_preproc => clk_to_preproc,
    fifo_wr_clk    => fifo_wr_clk,
    clk_to_counter => clk_to_counter,
    clk_to_debug   => clk_to_debug,
    -- Status and control signals                
    reset  => reset,
    locked => locked,
    -- Clock in ports
    clk_in1 => clk_in1
  );

end rtl;