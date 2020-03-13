----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Create Date: 09/20/2019 03:33:59 PM
-- Design Name: 
-- Module Name: TestAXI - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para transacciones AXI con dos slaves
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
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

entity TestAXI is
    --  no ports - this is a testbench;
end TestAXI;
    
architecture sim of TestAXI is

    signal clk, rst_n, rst : std_logic;
    signal rst_n_v: std_logic_vector(0 downto 0);
    
    signal axi_wstrb                : std_logic_vector(3 downto 0);
    signal axi_bresp, axi_rresp   : std_logic_vector(1 downto 0);
    signal axi_rdata, axi_wdata   : std_logic_vector(31 downto 0);
    signal axi_arprot, axi_awprot : std_logic_vector(2 downto 0);         
    signal axi_araddr, axi_awaddr : std_logic_vector(31 downto 0); 
    signal axi_awvalid, axi_awready, axi_wready, axi_wvalid, axi_bready, 
            axi_arvalid, axi_arready, axi_rready  : std_logic_vector(0 downto 0);
    signal axi_bvalid : std_logic_vector(0 downto 0) := "0"; -- Inicio en 0 para simulaciones de esclavo
    signal axi_rvalid : std_logic_vector(0 downto 0) := "0"; -- Inicio en 0 para simulaciones de esclavo

    --ADC
    signal usr_w1, usr_w2: std_logic_vector(13 downto 0) := "10000000000000";
    signal control: std_logic_vector(3 downto 0) := "1111";
    signal adc_DCO, adc_FCO, adc_D: std_logic := '0';        
    
    begin

        rst_n <= rst_n_v(0);
    
    -- sim_clk: entity work.tb_clk(sim)
    --         generic map(T_SIM_LIMIT => 10 us, T_CLK_PERIOD => 10 ns)
    --         port map(clk_o => clk);

    -- sim_rst_n: entity work.tb_rst(sim)
    --         generic map(RST_ACTIVO => '0', T_RST_INICIO => 600 ns, T_RST_ACTIVO => 300 ns)
    --         port map(rst_async_o => open, rst_sync_o => rst_n, clk_i => clk);

    -- sim_rst: entity work.tb_rst(sim)
    -- generic map(RST_ACTIVO => '1', T_RST_INICIO => 600 ns, T_RST_ACTIVO => 300 ns)
    -- port map(rst_async_o => open, rst_sync_o => rst, clk_i => clk);        
    -- Master 
    AXI_master: entity work.axi_mst_m02(rtl) -- para simulacion RTL
    --  DUT: entity work.axi_mst_m02(STRUCTURE) -- Para simulacion post synthesis
        generic map(TEST_TARGET_SLAVE_BASE_ADDR => x"44A10000")
        port map(
        
        M_AXI_ACLK    => clk, 
        M_AXI_ARESETN => rst_n, 

        M_AXI_AWADDR  => axi_awaddr,   -- out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_AWPROT  => axi_awprot,   -- out std_logic_vector(2 downto 0);
                            
        M_AXI_AWVALID => axi_awvalid(0),  -- out std_logic;
        M_AXI_AWREADY => axi_awready(0),  -- in std_logic;
        M_AXI_WDATA   => axi_wdata,    -- out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_WSTRB   => axi_wstrb,    -- out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
        M_AXI_WVALID  => axi_wvalid(0),   -- out std_logic;
        M_AXI_WREADY  => axi_wready(0),   -- in std_logic;
        M_AXI_BRESP   => axi_bresp,    -- in std_logic_vector(1 downto 0);
        M_AXI_BVALID  => axi_bvalid(0),   -- in std_logic;
        M_AXI_BREADY  => axi_bready(0),   -- out std_logic;
        M_AXI_ARADDR  => axi_araddr,   -- out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
        M_AXI_ARPROT  => axi_arprot,   -- out std_logic_vector(2 downto 0);
        M_AXI_ARVALID => axi_arvalid(0),  -- out std_logic;
        M_AXI_ARREADY => axi_arready(0),  -- in std_logic;
        M_AXI_RDATA   => axi_rdata,    -- in std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
        M_AXI_RRESP   => axi_rresp,    -- in std_logic_vector(1 downto 0);
        M_AXI_RVALID  => axi_rvalid(0),   -- in std_logic;
        M_AXI_RREADY  => axi_rready(0) ); -- out std_logic
    
    ADC: entity work.ADCmodel_wrapper
    port map(
        rst_n => rst_n,
        usr_w1 => usr_w1,
        usr_w2 => usr_w2,
        control => control,
        adc_DCO => adc_DCO,
        adc_FCO => adc_FCO,
        adc_D => adc_D
    );
    -- Slave: uso el ciaa-top-wrapper
    AXI_slave: entity work.SistAdq_test1_wrapper(STRUCTURE)
        port map(
            clk_o => clk,
            rst_n_o => rst_n_v,
            adc_DCO2_n_i => not(adc_DCO),   --: in STD_LOGIC;
            adc_DCO2_p_i => adc_DCO,   --: in STD_LOGIC;
            adc_bank12_n_i(1) => not(adc_D), -- : in STD_LOGIC_VECTOR ( 1 downto 0 );
            adc_bank12_n_i(0) => not(adc_FCO),
            adc_bank12_p_i(1) => adc_D, --in STD_LOGIC_VECTOR ( 1 downto 0 );
            adc_bank12_p_i(0) => adc_FCO,
            S00_AXI_0_araddr=>axi_araddr , -- in STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_0_arburst=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 1 downto 0 );     NOT DECLARED
            S00_AXI_0_arcache=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 3 downto 0 );     NOT DECLARED
            --S00_AXI_0_arid=>(others=>'0'), -- in STD_LOGIC_VECTOR ( 11 downto 0 );          NOT DECLARED
            S00_AXI_0_arlen=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 3 downto 0 );         NOT DECLARED
            S00_AXI_0_arlock=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 1 downto 0 );       NOT DECLARED
            S00_AXI_0_arprot=>axi_arprot , -- in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_0_arqos=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 3 downto 0 );         NOT DECLARED
            S00_AXI_0_arready=>axi_arready , -- out STD_LOGIC;
            S00_AXI_0_arsize=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 2 downto 0 );       NOT DECLARED
            S00_AXI_0_arvalid=>axi_arvalid , -- in STD_LOGIC;
            S00_AXI_0_awaddr=>axi_awaddr , -- in STD_LOGIC_VECTOR ( 31 downto 0 );
            S00_AXI_0_awburst=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 1 downto 0 );     NOT DECLARED
            S00_AXI_0_awcache=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 3 downto 0 );     NOT DECLARED
            --S00_AXI_0_awid=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 11 downto 0 );          NOT DECLARED
            S00_AXI_0_awlen=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 3 downto 0 );         NOT DECLARED
            S00_AXI_0_awlock=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 1 downto 0 );       NOT DECLARED
            S00_AXI_0_awprot=>axi_awprot , -- in STD_LOGIC_VECTOR ( 2 downto 0 );
            S00_AXI_0_awqos=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 3 downto 0 );         NOT DECLARED
            S00_AXI_0_awready=>axi_awready , -- out STD_LOGIC;
            S00_AXI_0_awsize=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 2 downto 0 );       NOT DECLARED
            S00_AXI_0_awvalid=>axi_awvalid , -- in STD_LOGIC;
            --S00_AXI_0_bid=> open , -- out STD_LOGIC_VECTOR ( 11 downto 0 );           NOT DECLARED
            S00_AXI_0_bready=>axi_bready , -- in STD_LOGIC;
            S00_AXI_0_bresp=>axi_bresp , -- out STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_0_bvalid=>axi_bvalid , -- out STD_LOGIC;
            S00_AXI_0_rdata=>axi_rdata , -- out STD_LOGIC_VECTOR ( 31 downto 0 );
            --S00_AXI_0_rid=>open , -- out STD_LOGIC_VECTOR ( 11 downto 0 );           NOT DECLARED
            S00_AXI_0_rlast=>open , -- out STD_LOGIC;                          NOT DECLARED
            S00_AXI_0_rready=>axi_rready , -- in STD_LOGIC;
            S00_AXI_0_rresp=>axi_rresp , -- out STD_LOGIC_VECTOR ( 1 downto 0 );
            S00_AXI_0_rvalid=>axi_rvalid , -- out STD_LOGIC;
            S00_AXI_0_wdata=>axi_wdata , -- in STD_LOGIC_VECTOR ( 31 downto 0 );
            --S00_AXI_0_wid=>(others=>'0') , -- in STD_LOGIC_VECTOR ( 11 downto 0 );            NOT DECLARED
            S00_AXI_0_wlast=>"0" , -- in STD_LOGIC;                       NOT DECLARED
            S00_AXI_0_wready=>axi_wready , -- out STD_LOGIC;
            S00_AXI_0_wstrb=>axi_wstrb , -- in STD_LOGIC_VECTOR ( 3 downto 0 );
            S00_AXI_0_wvalid=>axi_wvalid -- in STD_LOGIC    
        );
end sim;
