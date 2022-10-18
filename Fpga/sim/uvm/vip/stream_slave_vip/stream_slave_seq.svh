`ifndef STREAM_SLAVE_SEQ_SVH
`define STREAM_SLAVE_SEQ_SVH

class stream_slave_seq_base extends uvm_sequence #(stream_slave_seq_item);
  `uvm_object_utils(stream_slave_seq_base);
  `uvm_declare_p_sequencer(stream_slave_sequencer);

  function new(string name = "stream_slave_seq_base");
    super.new(name);
  endfunction : new

  task body();

  endtask
endclass : stream_slave_seq_base

class stream_slave_seq_random_delay extends stream_slave_seq_base;
  `uvm_object_utils(stream_slave_seq_random_delay);

  max_data_t data;

  function new(string name = "stream_slave_seq_random_delay");
    super.new(name);
  endfunction

  task body;
    stream_slave_seq_item item;

    item = stream_slave_seq_item::type_id::create("item");
    start_item(item);

    if (!item.randomize()) begin
      `uvm_error("STREAMRND", "Failed to randomize seq!");
    end

    finish_item(item);

    data = item.data;
  endtask
endclass : stream_slave_seq_random_delay

class stream_slave_seq_random_delay_forever extends stream_slave_seq_base;
  `uvm_object_utils(stream_slave_seq_random_delay_forever);

  function new(string name = "stream_slave_seq_random_delay_forever");
    super.new(name);
  endfunction

  task body;
    stream_slave_seq_item item;

    forever begin
      item = stream_slave_seq_item::type_id::create("item");
      start_item(item);

      if (!item.randomize()) begin
        `uvm_error("STREAMRND", "Failed to randomize seq!");
      end

      finish_item(item);
    end
  endtask

endclass : stream_slave_seq_random_delay_forever

class stream_slave_seq_constant_delay extends stream_slave_seq_base;
  `uvm_object_utils(stream_slave_seq_constant_delay);

  int delay_cycles = 0;
  max_data_t data;

  function new(string name = "stream_slave_seq_constant_delay");
    super.new(name);
  endfunction

  task body;
    stream_slave_seq_item item;

    item = stream_slave_seq_item::type_id::create("item");
    start_item(item);

    if (!item.randomize() with {delay_cycles == local::delay_cycles;}) begin
      `uvm_error("STREAMRND", "Failed to randomize seq!");
    end

    finish_item(item);

    data = item.data;
  endtask
endclass : stream_slave_seq_constant_delay

class stream_slave_seq_constant_delay_forever extends stream_slave_seq_base;
  `uvm_object_utils(stream_slave_seq_constant_delay_forever);

  int delay_cycles = 0;

  function new(string name = "stream_slave_seq_constant_delay_forever");
    super.new(name);
  endfunction

  task body;
    stream_slave_seq_item item;

    forever begin
      item = stream_slave_seq_item::type_id::create("item");
      start_item(item);

      if (!item.randomize() with {delay_cycles == local::delay_cycles;}) begin
        `uvm_error("STREAMRND", "Failed to randomize seq!");
      end

      finish_item(item);
    end
  endtask

endclass : stream_slave_seq_constant_delay_forever

`endif
