----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Deserializer
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-09-29
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity deserializer is
    generic(
        RES_ADC:  integer := 14;    --ADC resolution, can take values 14 or 12
        N:        integer := 1      --ADC data channels  
    );
    port(
        d_in:       in std_logic_vector((N*2-1) downto 0);
        d_clk_in:   in std_logic;
        d_frame:    in std_logic;
        rst:        in std_logic;
        d_out:      out std_logic_vector((N*14-1) downto 0);
        d_valid:    out std_logic
    );
end deserializer;

architecture arch of deserializer is
    --Xilinx attributes
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of d_clk_in: SIGNAL is "xilinx.com:signal:clock:1.0 d_clk_in CLK";
    ATTRIBUTE X_INTERFACE_INFO of rst: SIGNAL is "xilinx.com:signal:reset:1.0 rst RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of d_clk_in: SIGNAL is "ASSOCIATED_ASYNC_RESET rst";
    ATTRIBUTE X_INTERFACE_PARAMETER of rst: SIGNAL is "POLARITY ACTIVE_HIGH";

    --design signals
    signal d_reg, d_next:       std_logic_vector(13 downto 0) := (others => '0');
    signal out_reg, out_next:   std_logic_vector(13 downto 0) := (others => '0');
    signal f_reg, f_next:       std_logic;
    signal zeros2:              std_logic_vector(1 downto 0) := (others => '0');
    --signal acum_reg, acum_next: unsigned(16 downto 0) := (others => '0');

    begin

        process(d_clk_in)
        begin
            if(rst = '1') then
                d_reg   <= (others => '0');
                out_reg <= (others => '0');
                f_reg   <= '0';
            elsif(rising_edge(d_clk_in)) then
                d_reg   <= d_next;
                out_reg <= out_next;
                f_reg   <= f_next;
            end if;
        end process;

        -- process(d_reg,f_reg,out_reg,d_in,d_frame)
        -- begin
        --     d_next <= d_reg(11 downto 0) & d_in(1) & d_in(0);
        --     f_next <= d_frame;
        --     if(f_reg = '0' and d_frame = '1') then --rising edge del frame
        --         out_next <= d_reg;
        --     else
        --         out_next <= out_reg;
        --     end if;
        --     if(f_reg = '1' and d_frame = '0') then --falling edge del frame
        --         d_valid <= '1';
        --     else
        --         d_valid <= '0';
        --     end if;
        -- end process;

        -- d_out   <=  out_reg when (RES_ADC = 14) else
        --             zeros2 & out_reg(11 downto 0);

        process(d_reg,f_reg,out_reg,d_in,d_frame)
        begin
            d_next <= d_reg(11 downto 0) & d_in(1) & d_in(0);
            f_next <= d_frame;
            if(f_reg = '0' and d_frame = '1') then --rising edge del frame
                out_next <= d_reg;
            else
                out_next <= out_reg;
            end if;
        end process;

        d_out   <=  out_reg when (RES_ADC = 14) else
                    zeros2 & out_reg(11 downto 0);

        d_valid <= not(d_frame);
   
end arch; -- arch