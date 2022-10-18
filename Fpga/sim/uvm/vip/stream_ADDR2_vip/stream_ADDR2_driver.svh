`ifndef STREAM_ADDR2_DRIVER_SVH
`define STREAM_ADDR2_DRIVER_SVH

class stream_ADDR2_driver extends uvm_driver #(stream_ADDR2_seq_item);
  `uvm_component_utils(stream_ADDR2_driver);

  stream_ADDR2_agent_config m_cfg;

  function new(string name = "stream_ADDR2_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  task run_phase(uvm_phase phase);
    m_cfg.iface.wait_reset();
    m_cfg.iface.wait_clocks(10);

    forever begin
      stream_ADDR2_seq_item item;

      seq_item_port.get_next_item(item);
      `uvm_info(this.get_full_name, item.convert2string(), UVM_HIGH);

      m_cfg.iface.do_drive(item);

      seq_item_port.item_done();
    end
  endtask : run_phase
endclass : stream_ADDR2_driver

`endif
