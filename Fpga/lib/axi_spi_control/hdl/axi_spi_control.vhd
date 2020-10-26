----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Wrapper for AXI Quad SPI
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-10-25
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity axi_spi_control is
  port (
    s_axi_aclk    : in std_logic;
    s_axi_aresetn : in std_logic;
    s_axi_awaddr  : in std_logic_vector(6 downto 0);
    s_axi_awvalid : in std_logic;
    s_axi_awready : out std_logic;
    s_axi_wdata   : in std_logic_vector(31 downto 0);
    s_axi_wstrb   : in std_logic_vector(3 downto 0);
    s_axi_wvalid  : in std_logic;
    s_axi_wready  : out std_logic;
    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in std_logic;
    s_axi_araddr  : in std_logic_vector(6 downto 0);
    s_axi_arvalid : in std_logic;
    s_axi_arready : out std_logic;
    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in std_logic;
    adc_sdio_o    : out std_logic;
    adc_sclk_o    : out std_logic;
    adc_ss1_o     : out std_logic;
    adc_ss2_o     : out std_logic
  );
end axi_spi_control;

architecture rtl of axi_spi_control is
  component axi_quad_spi_0
    port (
      ext_spi_clk   : in std_logic;
      s_axi_aclk    : in std_logic;
      s_axi_aresetn : in std_logic;
      s_axi_awaddr  : in std_logic_vector(6 downto 0);
      s_axi_awvalid : in std_logic;
      s_axi_awready : out std_logic;
      s_axi_wdata   : in std_logic_vector(31 downto 0);
      s_axi_wstrb   : in std_logic_vector(3 downto 0);
      s_axi_wvalid  : in std_logic;
      s_axi_wready  : out std_logic;
      s_axi_bresp   : out std_logic_vector(1 downto 0);
      s_axi_bvalid  : out std_logic;
      s_axi_bready  : in std_logic;
      s_axi_araddr  : in std_logic_vector(6 downto 0);
      s_axi_arvalid : in std_logic;
      s_axi_arready : out std_logic;
      s_axi_rdata   : out std_logic_vector(31 downto 0);
      s_axi_rresp   : out std_logic_vector(1 downto 0);
      s_axi_rvalid  : out std_logic;
      s_axi_rready  : in std_logic;
      io0_i         : in std_logic;
      io0_o         : out std_logic;
      io0_t         : out std_logic;
      io1_i         : in std_logic;
      io1_o         : out std_logic;
      io1_t         : out std_logic;
      sck_i         : in std_logic;
      sck_o         : out std_logic;
      sck_t         : out std_logic;
      ss_i          : in std_logic_vector(1 downto 0);
      ss_o          : out std_logic_vector(1 downto 0);
      ss_t          : out std_logic;
      ip2intc_irpt  : out std_logic
    );
  end component;
begin
  axi_quad_spi_inst : axi_quad_spi_0
  port map(
    ext_spi_clk   => s_axi_aclk,
    s_axi_aclk    => s_axi_aclk,
    s_axi_aresetn => s_axi_aresetn,
    s_axi_awaddr  => s_axi_awaddr,
    s_axi_awvalid => s_axi_awvalid,
    s_axi_awready => s_axi_awready,
    s_axi_wdata   => s_axi_wdata,
    s_axi_wstrb   => s_axi_wstrb,
    s_axi_wvalid  => s_axi_wvalid,
    s_axi_wready  => s_axi_wready,
    s_axi_bresp   => s_axi_bresp,
    s_axi_bvalid  => s_axi_bvalid,
    s_axi_bready  => s_axi_bready,
    s_axi_araddr  => s_axi_araddr,
    s_axi_arvalid => s_axi_arvalid,
    s_axi_arready => s_axi_arready,
    s_axi_rdata   => s_axi_rdata,
    s_axi_rresp   => s_axi_rresp,
    s_axi_rvalid  => s_axi_rvalid,
    s_axi_rready  => s_axi_rready,
    io0_i         => '0',
    io0_o         => adc_sdio_o,
    io0_t         => open,
    io1_i         => '0',
    io1_o         => open,
    io1_t         => open,
    sck_i         => '0',
    sck_o         => adc_sclk_o,
    sck_t         => open,
    ss_o(1)       => adc_ss1_o,
    ss_o(0)       => adc_ss2_o,
    ss_i => (others => '0'),
    ss_t          => open,
    ip2intc_irpt  => open
  );

end rtl;