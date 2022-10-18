`ifndef STREAM_ADDR2_SEQUENCER_SVH
`define STREAM_ADDR2_SEQUENCER_SVH

class stream_ADDR2_sequencer extends uvm_sequencer #(stream_ADDR2_seq_item);
  `uvm_component_utils(stream_ADDR2_sequencer);

  function new(input string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : stream_ADDR2_sequencer

`endif
