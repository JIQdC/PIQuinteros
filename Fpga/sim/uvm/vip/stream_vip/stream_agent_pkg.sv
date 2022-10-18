package stream_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int MAX_DATA_WIDTH = 256;
  typedef logic [MAX_DATA_WIDTH - 1 : 0] max_data_t;

  `include "stream_seq_item.svh"
  `include "stream_abstract_class.svh"
  `include "stream_agent_config.svh"
  `include "stream_driver.svh"
  `include "stream_monitor.svh"
  `include "stream_sequencer.svh"
  `include "stream_agent.svh"

  // Utility sequences
  `include "stream_seq.svh"
endpackage
