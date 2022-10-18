package stream_ADDR2_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int MAX_DATA_WIDTH = 256;
  localparam int DATA_WIDTH_A2 = 40;
  typedef logic [MAX_DATA_WIDTH - 1 : 0] max_data_t;

  `include "stream_ADDR2_seq_item.svh"
  `include "stream_ADDR2_abstract_class.svh"
  `include "stream_ADDR2_agent_config.svh"
  `include "stream_ADDR2_driver.svh"
  `include "stream_ADDR2_monitor.svh"
  `include "stream_ADDR2_sequencer.svh"
  `include "stream_ADDR2_agent.svh"


endpackage
