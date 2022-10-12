library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity my_eight_regs_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface Eight_regs
		C_Eight_regs_DATA_WIDTH	: integer	:= 32;
		C_Eight_regs_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface Eight_regs
		eight_regs_aclk	: in std_logic;
		eight_regs_aresetn	: in std_logic;
		eight_regs_awaddr	: in std_logic_vector(C_Eight_regs_ADDR_WIDTH-1 downto 0);
		eight_regs_awprot	: in std_logic_vector(2 downto 0);
		eight_regs_awvalid	: in std_logic;
		eight_regs_awready	: out std_logic;
		eight_regs_wdata	: in std_logic_vector(C_Eight_regs_DATA_WIDTH-1 downto 0);
		eight_regs_wstrb	: in std_logic_vector((C_Eight_regs_DATA_WIDTH/8)-1 downto 0);
		eight_regs_wvalid	: in std_logic;
		eight_regs_wready	: out std_logic;
		eight_regs_bresp	: out std_logic_vector(1 downto 0);
		eight_regs_bvalid	: out std_logic;
		eight_regs_bready	: in std_logic;
		eight_regs_araddr	: in std_logic_vector(C_Eight_regs_ADDR_WIDTH-1 downto 0);
		eight_regs_arprot	: in std_logic_vector(2 downto 0);
		eight_regs_arvalid	: in std_logic;
		eight_regs_arready	: out std_logic;
		eight_regs_rdata	: out std_logic_vector(C_Eight_regs_DATA_WIDTH-1 downto 0);
		eight_regs_rresp	: out std_logic_vector(1 downto 0);
		eight_regs_rvalid	: out std_logic;
		eight_regs_rready	: in std_logic
	);
end my_eight_regs_v1_0;

architecture arch_imp of my_eight_regs_v1_0 is

	-- component declaration
	component my_eight_regs_v1_0_Eight_regs is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component my_eight_regs_v1_0_Eight_regs;

begin

-- Instantiation of Axi Bus Interface Eight_regs
my_eight_regs_v1_0_Eight_regs_inst : my_eight_regs_v1_0_Eight_regs
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_Eight_regs_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_Eight_regs_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> eight_regs_aclk,
		S_AXI_ARESETN	=> eight_regs_aresetn,
		S_AXI_AWADDR	=> eight_regs_awaddr,
		S_AXI_AWPROT	=> eight_regs_awprot,
		S_AXI_AWVALID	=> eight_regs_awvalid,
		S_AXI_AWREADY	=> eight_regs_awready,
		S_AXI_WDATA	=> eight_regs_wdata,
		S_AXI_WSTRB	=> eight_regs_wstrb,
		S_AXI_WVALID	=> eight_regs_wvalid,
		S_AXI_WREADY	=> eight_regs_wready,
		S_AXI_BRESP	=> eight_regs_bresp,
		S_AXI_BVALID	=> eight_regs_bvalid,
		S_AXI_BREADY	=> eight_regs_bready,
		S_AXI_ARADDR	=> eight_regs_araddr,
		S_AXI_ARPROT	=> eight_regs_arprot,
		S_AXI_ARVALID	=> eight_regs_arvalid,
		S_AXI_ARREADY	=> eight_regs_arready,
		S_AXI_RDATA	=> eight_regs_rdata,
		S_AXI_RRESP	=> eight_regs_rresp,
		S_AXI_RVALID	=> eight_regs_rvalid,
		S_AXI_RREADY	=> eight_regs_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
