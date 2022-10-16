--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Mon Nov 11 08:02:18 2019
--Host        : jiqdc-ubuntu running 64-bit Ubuntu 18.04.3 LTS
--Command     : generate_target DDRmodule_wrapper.bd
--Design      : DDRmodule_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
entity DDRmodule_wrapper is
  port (
    clk_in    : in std_logic;
    clk_out   : out std_logic;
    data_in   : in std_logic_vector (0 to 0);
    data_out  : out std_logic_vector (1 downto 0);
    frame_in  : in std_logic_vector (0 to 0);
    frame_out : out std_logic_vector (1 downto 0);
    rst       : in std_logic
  );
end DDRmodule_wrapper;

architecture STRUCTURE of DDRmodule_wrapper is
  component DDRmodule is
    port (
      clk_in    : in std_logic;
      clk_out   : out std_logic;
      data_in   : in std_logic_vector (0 to 0);
      data_out  : out std_logic_vector (1 downto 0);
      rst       : in std_logic;
      frame_out : out std_logic_vector (1 downto 0);
      frame_in  : in std_logic_vector (0 to 0)
    );
  end component DDRmodule;
begin
  DDRmodule_i : component DDRmodule
    port map(
      clk_in                => clk_in,
      clk_out               => clk_out,
      data_in(0)            => data_in(0),
      data_out(1 downto 0)  => data_out(1 downto 0),
      frame_in(0)           => frame_in(0),
      frame_out(1 downto 0) => frame_out(1 downto 0),
      rst                   => rst
    );
  end STRUCTURE;
