`ifndef STREAM_SEQUENCER_SVH
`define STREAM_SEQUENCER_SVH

class stream_sequencer extends uvm_sequencer #(stream_seq_item);
  `uvm_component_utils(stream_sequencer);

  function new(input string name, uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass : stream_sequencer

`endif
