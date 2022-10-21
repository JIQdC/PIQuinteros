`ifndef STREAM_ADDR1_SEQUENCER_SVH
`define STREAM_ADDR1_SEQUENCER_SVH

class stream_ADDR1_sequencer extends uvm_sequencer #(stream_ADDR1_seq_item);
  `uvm_component_utils(stream_ADDR1_sequencer);

  function new(input string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : stream_ADDR1_sequencer

`endif