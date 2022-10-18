`timescale 1ps/1ps
module remake_top;

  // Imports.
  import uvm_pkg::*;
  import remake_defn_pkg::*;
  import remake_test_pkg::*;


  `include "uvm_macros.svh"

  // Clock and reset signals.
  logic axi_clk;
  logic adc_clk;
  logic rst_n;
  logic aux_rst_n;
  logic cpo;  //señal a conectar al DUT en cpo
  logic fco;  //señal a conectar al DUT en fco
  logic pd;  //señal a conectar al DUT en pd

  stream_if #(
      .DATA_WIDTH(3)
  ) stream_if_inst (
      .rst_n(aux_rst_n),
      .clk  (adc_clk)
  );
  assign stream_if_inst.ready = 1'b1;


  stream_ADDR1_if awaddr_if (
      .clk  (axi_clk),
      .rst_n(aux_rst_n)
  );

  stream_if #(
      .DATA_WIDTH(DATA_WIDTH + WSTRB_WIDTH)
  ) wdata_if (
      .clk  (axi_clk),
      .rst_n(aux_rst_n)
  );

  stream_slave_if #(
      .DATA_WIDTH(2)
  ) bresp_if (
      .clk  (axi_clk),
      .rst_n(aux_rst_n)
  );


 stream_ADDR2_if  araddr_if (
      .clk  (axi_clk),
      .rst_n(aux_rst_n)
  );


  stream_slave_if #(
      .DATA_WIDTH(DATA_WIDTH + 2)
  ) rresp_if (
      .clk  (axi_clk),
      .rst_n(aux_rst_n)
  );




  always_comb begin
    cpo <= #(CLK_PERIOD / 2) stream_if_inst.data[2];
    fco <= stream_if_inst.data[1];
    pd  <= stream_if_inst.data[0];
  end

  //DUT
SistAdq_i SistAdq (
    .AXI_ACLK(axi_clk),
    .AXI_ARESETN(rst_n),
    .AXI_IN_araddr(araddr_if.data[ADDR_WIDTH-1:0]),
    .AXI_IN_arprot(3'b0),
    .AXI_IN_arready(araddr_if.ready),
    .AXI_IN_arvalid(araddr_if.valid),
    .AXI_IN_awaddr(awaddr_if.data[ADDR_WIDTH-1:0]),
    .AXI_IN_awprot(3'b0),
    .AXI_IN_awready(awaddr_if.ready),
    .AXI_IN_awvalid(awaddr_if.valid),
    .AXI_IN_bready(bresp_if.ready),
    .AXI_IN_bresp(bresp_if.data[1:0]),
    .AXI_IN_bvalid(bresp_if.valid),
    .AXI_IN_rdata(rresp_if.data[DATA_WIDTH-1:0]),
    .AXI_IN_rready(rresp_if.ready),
    .AXI_IN_rresp(rresp_if.data[DATA_WIDTH + 1:DATA_WIDTH ]),
    .AXI_IN_rvalid(rresp_if.valid),
    .AXI_IN_wdata(wdata_if.data[DATA_WIDTH+WSTRB_WIDTH-1:WSTRB_WIDTH]),
    .AXI_IN_wready (wdata_if.ready),
    .AXI_IN_wstrb(wdata_if.data[WSTRB_WIDTH-1:0]),
    .AXI_IN_wvalid(wdata_if.valid),
    .FIXED_IO_0_mio(),
    .FIXED_IO_0_ps_clk(),
    .FIXED_IO_0_ps_porb(),
    .FIXED_IO_0_ps_srstb(),
    .adc_DCO1_i_clk_n(~cpo),
    .adc_DCO1_i_clk_p(cpo),
    .adc_DCO2_i_clk_n(~cpo),
    .adc_DCO2_i_clk_p(cpo),
    .adc_FCO1_i_v_n(~fco),
    .adc_FCO1_i_v_p(fco),
    .adc_FCO2_i_v_n(~fco),
    .adc_FCO2_i_v_p(fco),
    .adc_data_i_v_n(~pd),
    .adc_data_i_v_p(pd),
    .adc_sclk_o(),
    .adc_sdio_o(),
    .adc_ss1_o(),
    .adc_ss2_o(),
    .dout0_o(),
    .dout1_o(),
    .ext_trigger_i(1'b0),
    .fmc_present_i(1'b1),
    .led_green_o(),
    .led_red_o(),
    .vadj_en_o()
    );
  // Clock and reset initial block.
  // Clock and reset initial block.
  initial begin

    fork
        begin
            // Initialize clock to 0 and reset_n to TRUE.
            adc_clk   = 0;
            rst_n = 0;
            aux_rst_n = 0;
            //#(CLK_PERIOD/2) adc_clk <= ~adc_clk;
            // Wait for reset completion (RESET_CLOCK_COUNT).
            repeat (RESET_CLOCK_COUNT) begin
            #(ADC_CLK_PERIOD / 2) adc_clk = 0;
            #(ADC_CLK_PERIOD - ADC_CLK_PERIOD / 2) adc_clk = 1;
            end

            aux_rst_n = 1;

            repeat (RESET_CLOCK_COUNT) begin
            #(ADC_CLK_PERIOD / 2) adc_clk = 0;
            #(ADC_CLK_PERIOD - ADC_CLK_PERIOD / 2) adc_clk = 1;
            end
            // Set rst to FALSE.
            rst_n = 1;
            forever begin
            #(ADC_CLK_PERIOD / 2) adc_clk = 0;
            #(ADC_CLK_PERIOD - ADC_CLK_PERIOD / 2) adc_clk = 1;
            end
        end

        begin
            // Initialize clock to 0 and reset_n to TRUE.
            axi_clk   = 0;
            forever begin
            #(AXI_CLK_PERIOD / 2) axi_clk = 0;
            #(AXI_CLK_PERIOD - AXI_CLK_PERIOD / 2) axi_clk = 1;
            end
        end
    join
  end


  initial begin
    // Set default verbosity level for all TB components.
    uvm_top.set_report_verbosity_level(UVM_HIGH);
    // Set time format for simulation.
    $timeformat(-12, 1, " ps", 1);

    // Configure some simulation options.
    uvm_top.enable_print_topology = 1;
    uvm_top.finish_on_completion  = 0;
    // Register concrete classes
    stream_if_inst.register_interface("stream_if");
    // Register concrete classes
    awaddr_if.register_interface("awaddr_if");
    wdata_if.register_interface("wdata_if");
    bresp_if.register_interface("bresp_if");

    araddr_if.register_interface("araddr_if");
    rresp_if.register_interface("rresp_if");
    // Test name must be set from the simulator's command line.
    run_test();
    $stop();
  end



endmodule : remake_top
