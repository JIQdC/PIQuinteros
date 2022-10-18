package stream_slave_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int MAX_DATA_WIDTH = 256;
  typedef logic [MAX_DATA_WIDTH - 1 : 0] max_data_t;

  `include "stream_slave_seq_item.svh"
  `include "stream_slave_abstract_class.svh"
  `include "stream_slave_agent_config.svh"
  `include "stream_slave_driver.svh"
  `include "stream_slave_monitor.svh"
  `include "stream_slave_sequencer.svh"
  `include "stream_slave_agent.svh"

  // Utility sequences
  `include "stream_slave_seq.svh"
endpackage
