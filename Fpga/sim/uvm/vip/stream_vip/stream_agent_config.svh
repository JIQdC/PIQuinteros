`ifndef STREAM_AGENT_CONFIG_SVH
`define STREAM_AGENT_CONFIG_SVH

class stream_agent_config extends uvm_object;
  `uvm_object_utils(stream_agent_config)

  string                  interface_name;
  uvm_active_passive_enum active          = UVM_ACTIVE;

  stream_abstract_class   iface;

  function new(string name = "");
    super.new(name);
  endfunction

  function automatic void set_interface(uvm_component parent);
    iface = stream_abstract_class::type_id::create(interface_name, parent);
  endfunction

endclass

`endif
