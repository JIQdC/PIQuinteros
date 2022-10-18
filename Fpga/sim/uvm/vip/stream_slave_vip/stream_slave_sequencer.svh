`ifndef STREAM_SLAVE_SEQUENCER_SVH
`define STREAM_SLAVE_SEQUENCER_SVH

class stream_slave_sequencer extends uvm_sequencer #(stream_slave_seq_item);
    `uvm_component_utils(stream_slave_sequencer);

    function new(string name = "stream_slave_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new

endclass: stream_slave_sequencer

`endif
