--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.1 (lin64) Build 2552052 Fri May 24 14:47:09 MDT 2019
--Date        : Fri Dec 20 09:22:51 2019
--Host        : jiqdc-ubuntu running 64-bit Ubuntu 18.04.3 LTS
--Command     : generate_target ADC_control.bd
--Design      : ADC_control
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ADC_control is
  port (
    S_AXI_0_araddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_arready : out STD_LOGIC;
    S_AXI_0_arvalid : in STD_LOGIC;
    S_AXI_0_awaddr : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_0_awready : out STD_LOGIC;
    S_AXI_0_awvalid : in STD_LOGIC;
    S_AXI_0_bready : in STD_LOGIC;
    S_AXI_0_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_bvalid : out STD_LOGIC;
    S_AXI_0_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_rready : in STD_LOGIC;
    S_AXI_0_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_0_rvalid : out STD_LOGIC;
    S_AXI_0_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_0_wready : out STD_LOGIC;
    S_AXI_0_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_0_wvalid : in STD_LOGIC;
    S_AXI_ACLK_0 : in STD_LOGIC;
    S_AXI_ARESETN_0 : in STD_LOGIC;
    adc_DCO_i : in STD_LOGIC;
    adc_FCO_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    adc_d_i : in STD_LOGIC_VECTOR ( 0 to 0 );
    fifo_clk_rd_i : in STD_LOGIC;
    rst_i : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of ADC_control : entity is "ADC_control,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=ADC_control,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=6,numReposBlks=6,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of ADC_control : entity is "ADC_control.hwdef";
end ADC_control;

architecture STRUCTURE of ADC_control is
  component ADC_control_DDR_data_0 is
  port (
    data_in_from_pins : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk_in : in STD_LOGIC;
    io_reset : in STD_LOGIC;
    data_in_to_device : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component ADC_control_DDR_data_0;
  component ADC_control_DDR_frame_0 is
  port (
    data_in_from_pins : in STD_LOGIC_VECTOR ( 0 to 0 );
    clk_in : in STD_LOGIC;
    io_reset : in STD_LOGIC;
    clk_out : out STD_LOGIC;
    data_in_to_device : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );
  end component ADC_control_DDR_frame_0;
  component ADC_control_adc_control_saxi_0_0 is
  port (
    S_AXI_ACLK : in STD_LOGIC;
    S_AXI_ARESETN : in STD_LOGIC;
    S_AXI_AWADDR : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_AWVALID : in STD_LOGIC;
    S_AXI_AWREADY : out STD_LOGIC;
    S_AXI_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_WVALID : in STD_LOGIC;
    S_AXI_WREADY : out STD_LOGIC;
    S_AXI_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_BVALID : out STD_LOGIC;
    S_AXI_BREADY : in STD_LOGIC;
    S_AXI_ARADDR : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ARVALID : in STD_LOGIC;
    S_AXI_ARREADY : out STD_LOGIC;
    S_AXI_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_RVALID : out STD_LOGIC;
    S_AXI_RREADY : in STD_LOGIC;
    fifo_dout_i : in STD_LOGIC_VECTOR ( 13 downto 0 );
    fifo_empty_i : in STD_LOGIC;
    fifo_full_i : in STD_LOGIC;
    fifo_ov_i : in STD_LOGIC;
    fifo_rd_rst_busy_i : in STD_LOGIC;
    fifo_wr_rst_busy_i : in STD_LOGIC;
    fifo_rd_en_o : out STD_LOGIC
  );
  end component ADC_control_adc_control_saxi_0_0;
  component ADC_control_deserializer_0_0 is
  port (
    d_in : in STD_LOGIC_VECTOR ( 1 downto 0 );
    d_clk_in : in STD_LOGIC;
    d_frame : in STD_LOGIC;
    d_out : out STD_LOGIC_VECTOR ( 13 downto 0 );
    d_valid : out STD_LOGIC
  );
  end component ADC_control_deserializer_0_0;
  component ADC_control_fifo_generator_0_0 is
  port (
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 13 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 13 downto 0 );
    full : out STD_LOGIC;
    overflow : out STD_LOGIC;
    empty : out STD_LOGIC;
    wr_rst_busy : out STD_LOGIC;
    rd_rst_busy : out STD_LOGIC
  );
  end component ADC_control_fifo_generator_0_0;
  component ADC_control_xlslice_0_0 is
  port (
    Din : in STD_LOGIC_VECTOR ( 1 downto 0 );
    Dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component ADC_control_xlslice_0_0;
  signal S_AXI_0_1_ARADDR : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal S_AXI_0_1_ARPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_ARREADY : STD_LOGIC;
  signal S_AXI_0_1_ARVALID : STD_LOGIC;
  signal S_AXI_0_1_AWADDR : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal S_AXI_0_1_AWPROT : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal S_AXI_0_1_AWREADY : STD_LOGIC;
  signal S_AXI_0_1_AWVALID : STD_LOGIC;
  signal S_AXI_0_1_BREADY : STD_LOGIC;
  signal S_AXI_0_1_BRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_BVALID : STD_LOGIC;
  signal S_AXI_0_1_RDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXI_0_1_RREADY : STD_LOGIC;
  signal S_AXI_0_1_RRESP : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal S_AXI_0_1_RVALID : STD_LOGIC;
  signal S_AXI_0_1_WDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXI_0_1_WREADY : STD_LOGIC;
  signal S_AXI_0_1_WSTRB : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal S_AXI_0_1_WVALID : STD_LOGIC;
  signal S_AXI_ACLK_0_1 : STD_LOGIC;
  signal adc_control_saxi_0_fifo_rd_en_o : STD_LOGIC;
  signal aresetn_0_1 : STD_LOGIC;
  signal clk_in_0_1 : STD_LOGIC;
  signal data_in_from_pins_0_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal data_in_from_pins_1_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal deserializer_0_d_out : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal deserializer_0_d_valid : STD_LOGIC;
  signal fifo_generator_0_dout : STD_LOGIC_VECTOR ( 13 downto 0 );
  signal fifo_generator_0_empty : STD_LOGIC;
  signal fifo_generator_0_full : STD_LOGIC;
  signal fifo_generator_0_overflow : STD_LOGIC;
  signal fifo_generator_0_rd_rst_busy : STD_LOGIC;
  signal fifo_generator_0_wr_rst_busy : STD_LOGIC;
  signal io_reset_0_1 : STD_LOGIC;
  signal rd_clk_0_1 : STD_LOGIC;
  signal selectio_wiz_0_clk_out : STD_LOGIC;
  signal selectio_wiz_0_data_in_to_device : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal selectio_wiz_1_data_in_to_device : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal xlslice_0_Dout : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of S_AXI_0_arready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_arvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_awready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_awvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_bready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_bvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_rready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_rvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RVALID";
  attribute X_INTERFACE_INFO of S_AXI_0_wready : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WREADY";
  attribute X_INTERFACE_INFO of S_AXI_0_wvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WVALID";
  attribute X_INTERFACE_INFO of S_AXI_ACLK_0 : signal is "xilinx.com:signal:clock:1.0 CLK.S_AXI_ACLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of S_AXI_ACLK_0 : signal is "XIL_INTERFACENAME CLK.S_AXI_ACLK_0, ASSOCIATED_BUSIF S_AXI_0, ASSOCIATED_RESET S_AXI_ARESETN_0, CLK_DOMAIN ADC_control_S_AXI_ACLK_0, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of S_AXI_ARESETN_0 : signal is "xilinx.com:signal:reset:1.0 RST.S_AXI_ARESETN_0 RST";
  attribute X_INTERFACE_PARAMETER of S_AXI_ARESETN_0 : signal is "XIL_INTERFACENAME RST.S_AXI_ARESETN_0, INSERT_VIP 0, POLARITY ACTIVE_LOW";
  attribute X_INTERFACE_INFO of adc_DCO_i : signal is "xilinx.com:signal:clock:1.0 CLK.ADC_DCO_I CLK";
  attribute X_INTERFACE_PARAMETER of adc_DCO_i : signal is "XIL_INTERFACENAME CLK.ADC_DCO_I, CLK_DOMAIN ADC_control_adc_DCO_i, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of fifo_clk_rd_i : signal is "xilinx.com:signal:clock:1.0 CLK.FIFO_CLK_RD_I CLK";
  attribute X_INTERFACE_PARAMETER of fifo_clk_rd_i : signal is "XIL_INTERFACENAME CLK.FIFO_CLK_RD_I, CLK_DOMAIN ADC_control_fifo_clk_rd_i, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of rst_i : signal is "xilinx.com:signal:reset:1.0 RST.RST_I RST";
  attribute X_INTERFACE_PARAMETER of rst_i : signal is "XIL_INTERFACENAME RST.RST_I, INSERT_VIP 0, POLARITY ACTIVE_HIGH";
  attribute X_INTERFACE_INFO of S_AXI_0_araddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARADDR";
  attribute X_INTERFACE_PARAMETER of S_AXI_0_araddr : signal is "XIL_INTERFACENAME S_AXI_0, ADDR_WIDTH 12, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN ADC_control_S_AXI_ACLK_0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of S_AXI_0_arprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 ARPROT";
  attribute X_INTERFACE_INFO of S_AXI_0_awaddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWADDR";
  attribute X_INTERFACE_INFO of S_AXI_0_awprot : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 AWPROT";
  attribute X_INTERFACE_INFO of S_AXI_0_bresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 BRESP";
  attribute X_INTERFACE_INFO of S_AXI_0_rdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RDATA";
  attribute X_INTERFACE_INFO of S_AXI_0_rresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 RRESP";
  attribute X_INTERFACE_INFO of S_AXI_0_wdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WDATA";
  attribute X_INTERFACE_INFO of S_AXI_0_wstrb : signal is "xilinx.com:interface:aximm:1.0 S_AXI_0 WSTRB";
begin
  S_AXI_0_1_ARADDR(3 downto 0) <= S_AXI_0_araddr(3 downto 0);
  S_AXI_0_1_ARPROT(2 downto 0) <= S_AXI_0_arprot(2 downto 0);
  S_AXI_0_1_ARVALID <= S_AXI_0_arvalid;
  S_AXI_0_1_AWADDR(3 downto 0) <= S_AXI_0_awaddr(3 downto 0);
  S_AXI_0_1_AWPROT(2 downto 0) <= S_AXI_0_awprot(2 downto 0);
  S_AXI_0_1_AWVALID <= S_AXI_0_awvalid;
  S_AXI_0_1_BREADY <= S_AXI_0_bready;
  S_AXI_0_1_RREADY <= S_AXI_0_rready;
  S_AXI_0_1_WDATA(31 downto 0) <= S_AXI_0_wdata(31 downto 0);
  S_AXI_0_1_WSTRB(3 downto 0) <= S_AXI_0_wstrb(3 downto 0);
  S_AXI_0_1_WVALID <= S_AXI_0_wvalid;
  S_AXI_0_arready <= S_AXI_0_1_ARREADY;
  S_AXI_0_awready <= S_AXI_0_1_AWREADY;
  S_AXI_0_bresp(1 downto 0) <= S_AXI_0_1_BRESP(1 downto 0);
  S_AXI_0_bvalid <= S_AXI_0_1_BVALID;
  S_AXI_0_rdata(31 downto 0) <= S_AXI_0_1_RDATA(31 downto 0);
  S_AXI_0_rresp(1 downto 0) <= S_AXI_0_1_RRESP(1 downto 0);
  S_AXI_0_rvalid <= S_AXI_0_1_RVALID;
  S_AXI_0_wready <= S_AXI_0_1_WREADY;
  S_AXI_ACLK_0_1 <= S_AXI_ACLK_0;
  aresetn_0_1 <= S_AXI_ARESETN_0;
  clk_in_0_1 <= adc_DCO_i;
  data_in_from_pins_0_1(0) <= adc_d_i(0);
  data_in_from_pins_1_1(0) <= adc_FCO_i(0);
  io_reset_0_1 <= rst_i;
  rd_clk_0_1 <= fifo_clk_rd_i;
DDR_data: component ADC_control_DDR_data_0
     port map (
      clk_in => clk_in_0_1,
      data_in_from_pins(0) => data_in_from_pins_1_1(0),
      data_in_to_device(1 downto 0) => selectio_wiz_1_data_in_to_device(1 downto 0),
      io_reset => io_reset_0_1
    );
DDR_frame: component ADC_control_DDR_frame_0
     port map (
      clk_in => clk_in_0_1,
      clk_out => selectio_wiz_0_clk_out,
      data_in_from_pins(0) => data_in_from_pins_0_1(0),
      data_in_to_device(1 downto 0) => selectio_wiz_0_data_in_to_device(1 downto 0),
      io_reset => io_reset_0_1
    );
adc_control_saxi_0: component ADC_control_adc_control_saxi_0_0
     port map (
      S_AXI_ACLK => S_AXI_ACLK_0_1,
      S_AXI_ARADDR(3 downto 0) => S_AXI_0_1_ARADDR(3 downto 0),
      S_AXI_ARESETN => aresetn_0_1,
      S_AXI_ARPROT(2 downto 0) => S_AXI_0_1_ARPROT(2 downto 0),
      S_AXI_ARREADY => S_AXI_0_1_ARREADY,
      S_AXI_ARVALID => S_AXI_0_1_ARVALID,
      S_AXI_AWADDR(3 downto 0) => S_AXI_0_1_AWADDR(3 downto 0),
      S_AXI_AWPROT(2 downto 0) => S_AXI_0_1_AWPROT(2 downto 0),
      S_AXI_AWREADY => S_AXI_0_1_AWREADY,
      S_AXI_AWVALID => S_AXI_0_1_AWVALID,
      S_AXI_BREADY => S_AXI_0_1_BREADY,
      S_AXI_BRESP(1 downto 0) => S_AXI_0_1_BRESP(1 downto 0),
      S_AXI_BVALID => S_AXI_0_1_BVALID,
      S_AXI_RDATA(31 downto 0) => S_AXI_0_1_RDATA(31 downto 0),
      S_AXI_RREADY => S_AXI_0_1_RREADY,
      S_AXI_RRESP(1 downto 0) => S_AXI_0_1_RRESP(1 downto 0),
      S_AXI_RVALID => S_AXI_0_1_RVALID,
      S_AXI_WDATA(31 downto 0) => S_AXI_0_1_WDATA(31 downto 0),
      S_AXI_WREADY => S_AXI_0_1_WREADY,
      S_AXI_WSTRB(3 downto 0) => S_AXI_0_1_WSTRB(3 downto 0),
      S_AXI_WVALID => S_AXI_0_1_WVALID,
      fifo_dout_i(13 downto 0) => fifo_generator_0_dout(13 downto 0),
      fifo_empty_i => fifo_generator_0_empty,
      fifo_full_i => fifo_generator_0_full,
      fifo_ov_i => fifo_generator_0_overflow,
      fifo_rd_en_o => adc_control_saxi_0_fifo_rd_en_o,
      fifo_rd_rst_busy_i => fifo_generator_0_rd_rst_busy,
      fifo_wr_rst_busy_i => fifo_generator_0_wr_rst_busy
    );
deserializer_0: component ADC_control_deserializer_0_0
     port map (
      d_clk_in => selectio_wiz_0_clk_out,
      d_frame => xlslice_0_Dout(0),
      d_in(1 downto 0) => selectio_wiz_0_data_in_to_device(1 downto 0),
      d_out(13 downto 0) => deserializer_0_d_out(13 downto 0),
      d_valid => deserializer_0_d_valid
    );
fifo_generator_0: component ADC_control_fifo_generator_0_0
     port map (
      din(13 downto 0) => deserializer_0_d_out(13 downto 0),
      dout(13 downto 0) => fifo_generator_0_dout(13 downto 0),
      empty => fifo_generator_0_empty,
      full => fifo_generator_0_full,
      overflow => fifo_generator_0_overflow,
      rd_clk => rd_clk_0_1,
      rd_en => adc_control_saxi_0_fifo_rd_en_o,
      rd_rst_busy => fifo_generator_0_rd_rst_busy,
      rst => io_reset_0_1,
      wr_clk => selectio_wiz_0_clk_out,
      wr_en => deserializer_0_d_valid,
      wr_rst_busy => fifo_generator_0_wr_rst_busy
    );
xlslice_0: component ADC_control_xlslice_0_0
     port map (
      Din(1 downto 0) => selectio_wiz_1_data_in_to_device(1 downto 0),
      Dout(0) => xlslice_0_Dout(0)
    );
end STRUCTURE;
