`ifndef STREAM_ADDR1_AGENT_SVH
`define STREAM_ADDR1_AGENT_SVH

class stream_ADDR1_agent extends uvm_agent;
  `uvm_component_utils(stream_ADDR1_agent)

  uvm_analysis_port #(stream_ADDR1_seq_item) aport;

  stream_ADDR1_agent_config                  m_config;
  stream_ADDR1_sequencer                     m_sequencer;
  stream_ADDR1_driver                        m_driver;
  stream_ADDR1_monitor                       m_monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (m_config == null) begin
      if (!uvm_config_db#(stream_ADDR1_agent_config)::get(this, "", "m_config", m_config)) begin
        `uvm_fatal(this.get_full_name, "No stream_ADDR1_agent config specified!")
      end
    end

    m_config.set_interface(this);

    if (m_config.active == UVM_ACTIVE) begin
      m_sequencer = stream_ADDR1_sequencer::type_id::create("m_sequencer", this);
      m_driver = stream_ADDR1_driver::type_id::create("m_driver", this);
      m_driver.m_cfg = m_config;
    end

    m_monitor = stream_ADDR1_monitor::type_id::create("m_monitor", this);
    m_monitor.m_cfg = m_config;

    aport = new("aport", this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (m_config.active == UVM_ACTIVE) begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end

    m_monitor.aport.connect(aport);
  endfunction

endclass : stream_ADDR1_agent

`endif
