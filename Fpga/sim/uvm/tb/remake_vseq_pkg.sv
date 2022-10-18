// Package: remake_vseq_pkg
// Package of the sequencies used to estimulate the DUT

package remake_vseq_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import remake_defn_pkg::*;

  import stream_agent_pkg::*;
  import stream_ADDR1_agent_pkg::*;
  import stream_ADDR2_agent_pkg::*;
  import stream_slave_agent_pkg::*;

  // Class: remake_vseq_base
  // Class base for the sequences of the test
  class remake_vseq_base extends uvm_sequence #(uvm_sequence_item);
    // UVM Factory Registration Macro
    `uvm_object_utils(remake_vseq_base)

    // Sequencer for any sequencie item
    stream_sequencer stream_sqr;

    stream_ADDR1_sequencer awaddr_sqr;
    stream_sequencer wdata_sqr;
    stream_slave_sequencer bresp_sqr;


    stream_ADDR2_sequencer araddr_sqr;
    stream_slave_sequencer rresp_sqr;


    // Register map
    uvm_status_e status;

    function new(string name = "remake_vseq_base");
      super.new(name);
    endfunction : new

    task body;

    endtask : body

  endclass : remake_vseq_base


  // Class: remake_vseq_stream_trasm
  // Sequence to estimulate the DUT with random ETH packets
  class remake_vseq_stream_trasm extends remake_vseq_base;
    // UVM Factory Registration Macro
    `uvm_object_utils(remake_vseq_stream_trasm)
    logic [223:0] trama;

    function new(string name = "remake_vseq_stream_trasm");
      super.new(name);
    endfunction : new

    task body()

     real tono;
     logic [13:0] tono_adc;


      for (int i = 0; i < LARGO_TONO; i++) begin
        stream_seq_item item;
        item = stream_seq_item::type_id::create("item");
        tono = 4096*$cos(2*PI_CONST*$time * FREQ_TONO_GHz) + 4096*$cos(2*PI_CONST*$time * FREQ_TONO_GHz_2); //$cos() es en radianes
        $display("time: %t",$time);
        $display("cos arg: %f",2*PI_CONST*$time * FREQ_TONO_GHz);
        tono_adc = tono;
        $display("tono %f",tono);
        $display("tono_adc %d",tono_adc);
        for(int j = 0; j<ADC_WIDTH; j++) begin

          start_item(item, .sequencer(stream_sqr));

          if (!item.randomize() with {delay_cycles==0;}) begin
            `uvm_error(get_name(), "Failed to randomize stream_trasm_sqr error sequence item!");
          end

          item.data[0] = tono_adc[ADC_WIDTH-j-1];

          if (j<7) begin
           item.data[1] = 1;
          end else begin
            item.data[1] = 0;
          end

          item.data[2] = (j+1)%2;

        finish_item(item);
        end
      end

    endtask : body

  endclass : remake_vseq_stream_trasm


//AXI VSEQ
class remake_seq_read extends remake_vseq_base;
  `uvm_object_utils(remake_seq_read)

  rand logic [ADDR_WIDTH-1:0] addr;

  function new(string name = "remake_seq_read");
    super.new(name);
  endfunction : new

  task body();
     stream_ADDR2_seq_item stream_araddr_seq_item;
     stream_slave_seq_item stream_slave_rresp_seq_item;

    
    stream_araddr_seq_item = stream_ADDR2_seq_item::type_id::create("stream_araddr_seq_item");
    stream_slave_rresp_seq_item = stream_slave_seq_item::type_id::create("stream_slave_rresp_seq_item");

    fork
      begin
         start_item(stream_araddr_seq_item,.sequencer(araddr_sqr));

         if (!stream_araddr_seq_item.randomize() with {
            data == local:: addr;
            delay_cycles == 0;
          }) begin
        `uvm_error("remake_seq_read_stream", "Failed to randomize seq!");
          end
         finish_item(stream_araddr_seq_item);

      end
      begin
        start_item(stream_slave_rresp_seq_item,.sequencer(rresp_sqr));
        if (!stream_slave_rresp_seq_item.randomize() with {
            delay_cycles == 0;
          }) begin
        `uvm_error("remake_seq_read_stream_slave", "Failed to randomize seq!");
          end
         finish_item(stream_slave_rresp_seq_item);
      end
    join

    `uvm_info("remake_seq_read", {$sformatf("\nLectura de registro: \n adress:%b\n data:%h\n",addr,stream_slave_rresp_seq_item.data[DATA_WIDTH-1:0])},UVM_HIGH);


  endtask

  

endclass : remake_seq_read




class remake_seq_write extends remake_vseq_base;
  `uvm_object_utils(remake_seq_write)

  rand logic [ADDR_WIDTH-1:0] addr;
  rand logic [DATA_WIDTH-1:0] data;

  function new(string name = "remake_seq_write");
    super.new(name);
  endfunction : new

  task body();
     stream_ADDR1_seq_item stream_awaddr_seq_item;
     stream_seq_item stream_wdata_seq_item;
     stream_slave_seq_item stream_slave_bresp_seq_item;

    
    stream_awaddr_seq_item = stream_ADDR1_seq_item::type_id::create("stream_awaddr_seq_item");
    stream_wdata_seq_item = stream_seq_item::type_id::create("stream_wdata_seq_item");
    stream_slave_bresp_seq_item = stream_slave_seq_item::type_id::create("stream_slave_bresp_seq_item");

    fork
      begin
         start_item(stream_awaddr_seq_item,.sequencer(awaddr_sqr));

         if (!stream_awaddr_seq_item.randomize() with {
            data == local:: addr;
            delay_cycles == 0;
          }) begin
        `uvm_error("remake_seq_write_stream1", "Failed to randomize seq!");
          end
         finish_item(stream_awaddr_seq_item);

      end
      begin
         start_item(stream_wdata_seq_item,.sequencer(wdata_sqr));

         if (!stream_wdata_seq_item.randomize() with {
            delay_cycles == 0;
          }) begin
        `uvm_error("remake_seq_write_stream2", "Failed to randomize seq!");
          end

          stream_wdata_seq_item.data = {data,WSTRB_AGREGADO};
         finish_item(stream_wdata_seq_item);

      end
      begin
        start_item(stream_slave_bresp_seq_item,.sequencer(bresp_sqr));
        if (!stream_slave_bresp_seq_item.randomize() with {
            delay_cycles == 0;
          }) begin
        `uvm_error("remake_seq_write_stream_slave", "Failed to randomize seq!");
          end
         finish_item(stream_slave_bresp_seq_item);
      end
    join

    `uvm_info("remake_seq_write", {$sformatf("\nEscritura de registro: \n adress:%b\n data:%h\n bresp:%2b\n",addr,data,stream_slave_bresp_seq_item.data)},UVM_HIGH);


  endtask

  

endclass : remake_seq_write



endpackage : remake_vseq_pkg
