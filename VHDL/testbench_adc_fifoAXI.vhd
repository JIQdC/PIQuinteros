----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name:
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para módulo de control de ADC con interfaz AXI
-- 
-- Dependencies: 
-- 
-- Revision: 2019-12-20
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

entity TestADC_fifoAXI is
        --  no ports - this is a testbench;
end TestADC_fifoAXI;
    
architecture sim of TestADC_fifoAXI is

    signal rst_n: std_logic := '0';
    signal rst: std_logic := '1';
    constant N: integer := 14;
    --proc_clk
    signal proc_clk: std_logic;    
    --ADC model
    signal adc_DCO: std_logic;
    signal adc_FCO: std_logic_vector(0 to 0);
    signal adc_D: std_logic_vector(0 to 0);
    signal control: std_logic_vector(3 downto 0) := (others => '0');
    signal usr_w1, usr_w2: std_logic_vector(13 downto 0) := (others => '0');
    --ADC control
    signal S_AXI_0_awaddr : STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
    signal S_AXI_0_awprot : STD_LOGIC_VECTOR ( 2 downto 0 ) := (others => '0');
    signal S_AXI_0_awvalid : STD_LOGIC := '0';
    signal S_AXI_0_awready : STD_LOGIC;
    signal S_AXI_0_wdata : STD_LOGIC_VECTOR ( 31 downto 0 )  := (others => '0');
    signal S_AXI_0_wstrb : STD_LOGIC_VECTOR ( 3 downto 0 ) := (others => '0');
    signal S_AXI_0_wvalid : STD_LOGIC := '0';
    signal S_AXI_0_wready : STD_LOGIC;
    signal S_AXI_0_bresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S_AXI_0_bvalid : STD_LOGIC;
    signal S_AXI_0_bready : STD_LOGIC := '0';
    signal S_AXI_0_araddr : STD_LOGIC_VECTOR ( 3 downto 0 );-- := (others => '0');
    signal S_AXI_0_arprot : STD_LOGIC_VECTOR ( 2 downto 0 ) := (others => '0');
    signal S_AXI_0_arvalid : STD_LOGIC := '0';
    signal S_AXI_0_arready : STD_LOGIC;
    signal S_AXI_0_rdata : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal S_AXI_0_rresp : STD_LOGIC_VECTOR ( 1 downto 0 );
    signal S_AXI_0_rvalid : STD_LOGIC;
    signal S_AXI_0_rready : STD_LOGIC := '0';
    --AXI master
    signal M_AXI_AWADDR: std_logic_vector(31 downto 0);
    signal M_AXI_ARADDR: std_logic_vector(31 downto 0);


begin
    --rst no negado para el módulo DDR
    rst <= not(rst_n);

    ADC: entity work.ADCmodel_wrapper(arch)
        generic map(
            N => N,
            T_SAMPLE => 14 ns,
            T_DELAY => 2.3 ns,
            T_SIM_LIMIT => 10 us,
            T_CLK_PERIOD => 1 ns
            )
        port map(
            rst_n => rst_n, usr_w1 => usr_w1, usr_w2 => usr_w2,
            control => control, adc_DCO => adc_DCO, adc_FCO => adc_FCO(0), adc_D => adc_D(0)
            );

    clk_proc: entity work.tb_clk(sim)
        generic map(
            T_SIM_LIMIT  => 10 us,
            T_CLK_PERIOD => 10.309 ns --corresponde a FCLK = 97 MHz
        )
        port map(
            clk_o => proc_clk-- : out std_logic := '0');
        );

    ADC_control: entity work.ADC_control_wrapper(STRUCTURE)
        port map(
            S_AXI_ACLK_0 => proc_clk,
            S_AXI_ARESETN_0 => rst_n,
            adc_DCO_i => adc_DCO,
            adc_FCO_i => adc_FCO,
            adc_d_i => adc_D,
            fifo_clk_rd_i => proc_clk,
            rst_i => rst,
            S_AXI_0_awaddr => S_AXI_0_awaddr,   -- in STD_LOGIC_VECTOR ( 3 downto 0 );
            S_AXI_0_awprot => S_AXI_0_awprot,   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
            S_AXI_0_awvalid => S_AXI_0_awvalid, -- : in STD_LOGIC;
            S_AXI_0_awready => S_AXI_0_awready, -- : out STD_LOGIC;
            S_AXI_0_wdata => S_AXI_0_wdata,     --: in STD_LOGIC_VECTOR ( 31 downto 0 );
            S_AXI_0_wstrb => S_AXI_0_wstrb,     --: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S_AXI_0_wvalid => S_AXI_0_wvalid,   -- : in STD_LOGIC;
            S_AXI_0_wready => S_AXI_0_wready,   --: out STD_LOGIC;
            S_AXI_0_bresp => S_AXI_0_bresp,     --: out STD_LOGIC_VECTOR ( 1 downto 0 );
            S_AXI_0_bvalid => S_AXI_0_bvalid,   --: out STD_LOGIC;
            S_AXI_0_bready => S_AXI_0_bready,   --: in STD_LOGIC;
            S_AXI_0_araddr => S_AXI_0_araddr,   --: in STD_LOGIC_VECTOR ( 3 downto 0 );
            S_AXI_0_arprot => S_AXI_0_arprot,   --: in STD_LOGIC_VECTOR ( 2 downto 0 );
            S_AXI_0_arvalid => S_AXI_0_arvalid, -- : in STD_LOGIC;
            S_AXI_0_arready => S_AXI_0_arready, --: out STD_LOGIC;
            S_AXI_0_rdata => S_AXI_0_rdata,     --: out STD_LOGIC_VECTOR ( 31 downto 0 );
            S_AXI_0_rresp => S_AXI_0_rresp,     --: out STD_LOGIC_VECTOR ( 1 downto 0 );
            S_AXI_0_rvalid => S_AXI_0_rvalid,   --: out STD_LOGIC;
            S_AXI_0_rready => S_AXI_0_rready    --: in STD_LOGIC        
        );

    S_AXI_0_awaddr <= M_AXI_AWADDR(3 downto 0);
    S_AXI_0_araddr <= M_AXI_ARADDR(3 downto 0);

    AXI_master: entity work.axi_mst_FIFOtest(rtl)
        port map(
            M_AXI_ACLK => proc_clk,             --: in std_logic;
            M_AXI_ARESETN => rst_n,              --: in std_logic;
            M_AXI_AWADDR => M_AXI_AWADDR,       --: out std_logic_vector(31 downto 0);
            M_AXI_AWPROT => S_AXI_0_awprot,     --: out std_logic_vector(2 downto 0);
            M_AXI_AWVALID => S_AXI_0_awvalid,   --: out std_logic;
            M_AXI_AWREADY => S_AXI_0_awready,   --: in std_logic;
            M_AXI_WDATA => S_AXI_0_wdata,       --: out std_logic_vector(31 downto 0);
            M_AXI_WSTRB => S_AXI_0_wstrb,       --: out std_logic_vector(3 downto 0);.
            M_AXI_WVALID => S_AXI_0_wvalid,     --: out std_logic;
            M_AXI_WREADY => S_AXI_0_wready,     --: in std_logic;
            M_AXI_BRESP => S_AXI_0_bresp,       --: in std_logic_vector(1 downto 0);
            M_AXI_BVALID => S_AXI_0_bvalid,     --: in std_logic;
            M_AXI_BREADY => S_AXI_0_bready,     --: out std_logic;axi_mst_m02
            M_AXI_ARADDR => M_AXI_ARADDR,       --: out std_logic_vector(31 downto 0);
            M_AXI_ARPROT => S_AXI_0_arprot,     --: out std_logic_vector(2 downto 0);
            M_AXI_ARVALID => S_AXI_0_arvalid,   --: out std_logic;
            M_AXI_ARREADY => S_AXI_0_arready,   --: in std_logic;
            M_AXI_RDATA => S_AXI_0_rdata,       --: in std_logic_vector(31 downto 0);
            M_AXI_RRESP => S_AXI_0_rresp,       --: in std_logic_vector(1 downto 0);
            M_AXI_RVALID => S_AXI_0_rvalid,     --: in std_logic;
            M_AXI_RREADY => S_AXI_0_rready      --: out std_logic
        );

    

    simProcess: process
    begin
        --pruebo una secuencia de salida
        control <= "1111";
        usr_w1 <= "01000000000000";
        --reseteo por un tiempo
        rst_n <= '0';
        wait for 50 ns;
        rst_n <= '1';

        --veo que pasa...
        wait;

    end process;
end sim;