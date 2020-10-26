----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Downsampler
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-10-08
-- Additional Comments: Version with external treshold
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity downsampler is
  generic (
    N_tr_b : integer := 10
  );
  port (
    d_clk_i        : in std_logic;
    rst_i          : in std_logic;
    data_i         : in std_logic_vector(13 downto 0);
    d_valid_i      : in std_logic;
    treshold_reg_i : in std_logic_vector((N_tr_b - 1) downto 0);
    treshold_ld_i  : in std_logic;
    data_o         : out std_logic_vector(15 downto 0);
    d_valid_o      : out std_logic
  );
end downsampler;

architecture arch of downsampler is

  signal d_reg, d_next     : std_logic_vector(13 downto 0)   := (others => '0');
  signal cnt_reg, cnt_next : unsigned((N_tr_b - 1) downto 0) := (others => '0');
  signal zeros2            : std_logic_vector(1 downto 0)    := (others => '0');

  --Xilinx attributes
  attribute X_INTERFACE_INFO                 : string;
  attribute X_INTERFACE_INFO of d_clk_i      : signal is "xilinx.com:signal:clock:1.0 d_clk_i CLK";
  attribute X_INTERFACE_INFO of rst_i        : signal is "xilinx.com:signal:reset:1.0 rst_i RST";
  attribute X_INTERFACE_PARAMETER            : string;
  attribute X_INTERFACE_PARAMETER of d_clk_i : signal is "ASSOCIATED_ASYNC_RESET rst";
  attribute X_INTERFACE_PARAMETER of rst_i   : signal is "POLARITY ACTIVE_HIGH";

begin

  process (d_clk_i)
  begin
    if (rst_i = '1') then
      d_reg   <= (others => '0');
      cnt_reg <= (others => '0');
    elsif (rising_edge(d_clk_i)) then
      d_reg   <= d_next;
      cnt_reg <= cnt_next;
    end if;
  end process;

  process (d_reg, cnt_reg, data_i, d_valid_i, treshold_reg_i, treshold_ld_i)
  begin
    d_next   <= d_reg;
    cnt_next <= cnt_reg;

    d_valid_o <= '0';
    data_o    <= zeros2 & d_reg;

    if (d_valid_i = '1') then
      cnt_next <= cnt_reg + 1;
      if (cnt_reg >= (unsigned(treshold_reg_i))) then
        d_next    <= data_i;
        d_valid_o <= '1';
        cnt_next  <= (others => '0');
      end if;
    end if;

    if (treshold_ld_i = '1') then
      cnt_next <= (others => '0');
    end if;
  end process;

end arch; -- arch