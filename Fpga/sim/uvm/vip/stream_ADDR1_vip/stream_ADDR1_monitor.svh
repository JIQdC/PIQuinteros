`ifndef STREAM_ADDR1_MONITOR_SVH
`define STREAM_ADDR1_MONITOR_SVH

class stream_ADDR1_monitor extends uvm_monitor;
  `uvm_component_utils(stream_ADDR1_monitor);

  stream_ADDR1_agent_config m_cfg;

  uvm_analysis_port #(stream_ADDR1_seq_item) aport;

  function new(string name = "stream_ADDR1_monitor", uvm_component parent = null);
    super.new(name, parent);

    aport = new("aport", this);
  endfunction : new

  function void build_phase(uvm_phase phase);

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    m_cfg.iface.wait_reset();

    forever begin
      stream_ADDR1_seq_item item;
      item = stream_ADDR1_seq_item::type_id::create("item", this);
      m_cfg.iface.do_monitor(item);

      `uvm_info(this.get_full_name, item.convert2string(), UVM_HIGH)
      aport.write(item);
    end
  endtask : run_phase


endclass : stream_ADDR1_monitor

`endif
