package stream_ADDR1_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  localparam int MAX_DATA_WIDTH = 256;
  localparam int DATA_WIDTH_A1 = 40;
  typedef logic [MAX_DATA_WIDTH - 1 : 0] max_data_t;

  `include "stream_ADDR1_seq_item.svh"
  `include "stream_ADDR1_abstract_class.svh"
  `include "stream_ADDR1_agent_config.svh"
  `include "stream_ADDR1_driver.svh"
  `include "stream_ADDR1_monitor.svh"
  `include "stream_ADDR1_sequencer.svh"
  `include "stream_ADDR1_agent.svh"


endpackage
