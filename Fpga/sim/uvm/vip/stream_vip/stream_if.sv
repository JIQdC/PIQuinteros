`ifndef STREAM_IF_SVH
`define STREAM_IF_SVH

//  Interface: stream_if
//
interface stream_if #(
    int DATA_WIDTH = 32
) (
    input logic rst_n,
    input logic clk
);

  logic                      ready;
  logic [DATA_WIDTH - 1 : 0] data;
  logic                      valid = 1'b0;

  // synthesis translate_off

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import stream_agent_pkg::*;

  class stream_concrete_class #(
      parameter int DATA_WIDTH = 32
  ) extends stream_abstract_class;
    `uvm_component_param_utils(stream_concrete_class#(DATA_WIDTH));

    max_data_t mask;

    function new(string name = "stream_concrete_class", uvm_component parent = null);
      super.new(name, parent);
      mask = (1 << DATA_WIDTH) - 1;
    endfunction : new

    function int get_data_width();
      return DATA_WIDTH;
    endfunction : get_data_width

    task wait_reset();
      @(posedge rst_n);
    endtask : wait_reset

    task wait_clocks(int cycles = 1);
      repeat (cycles) @(posedge clk);
    endtask : wait_clocks

    task do_drive(stream_seq_item item);
      repeat (item.delay_cycles) @(posedge clk);

      data  <= item.data & mask;
      valid <= 1;

      @(posedge clk);

      while (!(valid && ready)) begin
        @(posedge clk);
      end

      data  <= 'x;
      valid <= 0;
    endtask : do_drive

    task do_monitor(stream_seq_item item);
      @(posedge clk);

      while (!(valid && ready)) begin
        @(posedge clk);
      end

      item.data = data & mask;
    endtask : do_monitor

  endclass : stream_concrete_class

  function automatic void register_interface(string interface_name);
    string path_name;
    path_name = $sformatf("*.%s", interface_name);
    stream_abstract_class::type_id::set_inst_override(
        stream_concrete_class#(DATA_WIDTH)::get_type(), path_name, null);
  endfunction
  // synthesis translate_on

endinterface : stream_if


`endif
