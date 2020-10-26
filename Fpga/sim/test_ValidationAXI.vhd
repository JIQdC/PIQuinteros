----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: Testbench para validación AXI
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-07-10
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TestValidationAXI is
    --  no ports - this is a testbench;
end TestValidationAXI;

architecture sim of TestValidationAXI is
    signal axi_clk, rstn_axi_mst: std_logic := '0';
    signal word1, word0: STD_LOGIC_VECTOR(13 downto 0) := (others => '0');

    signal axi_wstrb                : std_logic_vector(3 downto 0);
    signal axi_bresp, axi_rresp   : std_logic_vector(1 downto 0);
    signal axi_rdata, axi_wdata   : std_logic_vector(31 downto 0);
    signal axi_arprot, axi_awprot : std_logic_vector(2 downto 0);         
    signal axi_araddr, axi_awaddr : std_logic_vector(31 downto 0) := (others => '0'); 
    signal axi_awvalid, axi_awready, axi_wready, axi_wvalid, axi_bready, 
            axi_arvalid, axi_arready, axi_rready  : std_logic;
    signal axi_bvalid : std_logic := '0'; -- Inicio en 0 para simulaciones de esclavo
    signal axi_rvalid : std_logic := '0'; -- Inicio en 0 para simulaciones de esclavo

begin

    RSTN_AXI_ENT: entity work.tb_rst(sim)
        generic map(RST_ACTIVO => '0', T_RST_INICIO => 0 us, T_RST_ACTIVO => 250 us)
        port map(rst_async_o => open, rst_sync_o => rstn_axi_mst, clk_i => axi_clk);

    MST_SIM: entity work.axi_mst_m02(rtl) -- para simulacion RTL
        port map(
        M_AXI_ACLK    => axi_clk, 
        M_AXI_ARESETN => rstn_axi_mst, 

        M_AXI_AWADDR  => axi_awaddr,   -- out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_AWPROT  => axi_awprot,   -- out std_logic_vector(2 downto 0);
                            
        M_AXI_AWVALID => axi_awvalid,  -- out std_logic;
        M_AXI_AWREADY => axi_awready,  -- in std_logic;
        M_AXI_WDATA   => axi_wdata,    -- out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_WSTRB   => axi_wstrb,    -- out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
        M_AXI_WVALID  => axi_wvalid,   -- out std_logic;
        M_AXI_WREADY  => axi_wready,   -- in std_logic;
        M_AXI_BRESP   => axi_bresp,    -- in std_logic_vector(1 downto 0);
        M_AXI_BVALID  => axi_bvalid,   -- in std_logic;
        M_AXI_BREADY  => axi_bready,   -- out std_logic;
        M_AXI_ARADDR  => axi_araddr,   -- out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_ARPROT  => axi_arprot,   -- out std_logic_vector(2 downto 0);
        M_AXI_ARVALID => axi_arvalid,  -- out std_logic;
        M_AXI_ARREADY => axi_arready,  -- in std_logic;
        M_AXI_RDATA   => axi_rdata,    -- in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_RRESP   => axi_rresp,    -- in std_logic_vector(1 downto 0);
        M_AXI_RVALID  => axi_rvalid,   -- in std_logic;
        M_AXI_RREADY  => axi_rready ); -- out std_logic

    DUT: entity work.ValidationAXI_test_wrapper(STRUCTURE)
        port map(
            axi_clk_o => axi_clk,
            S00_AXI_0_araddr => axi_araddr,
            S00_AXI_0_arburst => (others => '0'),--: in STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_0_arcache => (others => '0'),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_arlen => (others => '0'),--: in STD_LOGIC_VECTOR ( 7 downto 0 );
            S00_AXI_0_arlock => (others => '0'),--: in STD_LOGIC_VECTOR ( 0 to 0 );
            S00_AXI_0_arprot => axi_arprot,
            S00_AXI_0_arqos => (others => '0'),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_arready => axi_arready,
            S00_AXI_0_arregion => (others => '0'),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_arsize => (others => '0'),--: in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_0_arvalid => axi_arvalid,
            S00_AXI_0_awaddr => (others => '0'),--: in STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_0_awburst => (others => '0'),--: in STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_0_awcache => (others => '0'),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_awlen => (others => '0'),--: in STD_LOGIC_VECTOR ( 7 downto 0 );
            S00_AXI_0_awlock => (others => '0'),--: in STD_LOGIC_VECTOR ( 0 to 0 );
            S00_AXI_0_awprot => axi_awprot,
            S00_AXI_0_awqos => (others => '0'),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_awready => axi_awready,
            S00_AXI_0_awregion => (others => '0'),--: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_awsize => (others => '0'),--: in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_0_awvalid => axi_awvalid,
            S00_AXI_0_bready => axi_bready,
            S00_AXI_0_bresp => axi_bresp,
            S00_AXI_0_bvalid => axi_bvalid, 
            S00_AXI_0_rdata => axi_rdata,
            S00_AXI_0_rlast => open,--: out STD_LOGIC;
            S00_AXI_0_rready => axi_rready,
            S00_AXI_0_rresp => axi_rresp,
            S00_AXI_0_rvalid => axi_rvalid,
            S00_AXI_0_wdata => axi_wdata,
            S00_AXI_0_wlast => '0',--: in STD_LOGIC;
            S00_AXI_0_wready => axi_wready,
            S00_AXI_0_wstrb => axi_wstrb,
            S00_AXI_0_wvalid => axi_wvalid,
            dout0_o => open,
            dout1_o => open,
            dout3_o => open,
            led_green_o => open,
            led_red_o => open,
            vadj_en_o => open
        );

    word1 <= axi_rdata(27 downto 14);
    word0 <= axi_rdata(13 downto 0); 
        
end sim;