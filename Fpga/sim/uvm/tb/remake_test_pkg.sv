//Package of the test class
package remake_test_pkg;

  // Package imports.
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import remake_defn_pkg::*;
  import remake_env_pkg::*;
  import remake_vseq_pkg::*;

  // Agent package imports.
  import stream_agent_pkg::*;

  import stream_ADDR1_agent_pkg::*;
  import stream_ADDR2_agent_pkg::*;
  import stream_slave_agent_pkg::*;

  //------------------------------------------------------------------------------
  // Class: remake_test_base
  //------------------------------------------------------------------------------
  // Verification test base for remake design.
  //------------------------------------------------------------------------------
  class remake_test_base extends uvm_test;
    // UVM Factory Registration Macro
    `uvm_component_utils(remake_test_base)

    // Environment class instantiation.
    remake_env m_env;
    // Environment configuration object instantiation.
    remake_env_config env_config;

    // Constructor.
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    // Test's build phase.
    function void build_phase(uvm_phase phase);
      // Must always call parent method's build phase.
      super.build_phase(phase);

      // Create environment and its configuration object.
      m_env = remake_env::type_id::create("m_env", this);
      env_config = remake_env_config::type_id::create("env_config");


      // Configure Stream eth_in Agent.
      env_config.m_stream_agent_config =
          stream_agent_config::type_id::create("m_stream_agent_config");
      env_config.m_stream_agent_config.active = UVM_ACTIVE;
      env_config.m_stream_agent_config.interface_name = "stream_if";


          // Configure Stream Agent.
      env_config.m_araddr_agent_config =
          stream_ADDR2_agent_config::type_id::create("m_araddr_agent_config");
      env_config.m_araddr_agent_config.active = UVM_ACTIVE;
      env_config.m_araddr_agent_config.interface_name = "araddr_if";


      // Configure Stream Slave Agent.
      env_config.m_rresp_agent_config =
          stream_slave_agent_config::type_id::create("m_rresp_agent_config");
      env_config.m_rresp_agent_config.active = UVM_ACTIVE;
      env_config.m_rresp_agent_config.interface_name = "rresp_if";


      // Configure Stream Agent.
      env_config.m_awaddr_agent_config =
          stream_ADDR1_agent_config::type_id::create("m_awaddr_agent_config");
      env_config.m_awaddr_agent_config.active = UVM_ACTIVE;
      env_config.m_awaddr_agent_config.interface_name = "awaddr_if";


      // Configure Stream Agent.
      env_config.m_wdata_agent_config =
          stream_agent_config::type_id::create("m_wdata_agent_config");
      env_config.m_wdata_agent_config.active = UVM_ACTIVE;
      env_config.m_wdata_agent_config.interface_name = "wdata_if";


      // Configure Stream Slave Agent.
      env_config.m_bresp_agent_config =
          stream_slave_agent_config::type_id::create("m_bresp_agent_config");
      env_config.m_bresp_agent_config.active = UVM_ACTIVE;
      env_config.m_bresp_agent_config.interface_name = "bresp_if";


      // Environment post configuration
      configure_env(env_config);

      // Post configure and set configuration object to database
      uvm_config_db#(remake_env_config)::set(this, "*", "remake_env_config", env_config);
    endfunction : build_phase

    // Convenience method used by test sub-classes to modify the environment.
    virtual function void configure_env(remake_env_config env_config);
      // Environment post config here (if needed).
    endfunction : configure_env

    function void init_adc_vseq(remake_vseq_base vseq);
      if (env_config.has_stream_agent) begin
        vseq.stream_sqr = m_env.m_stream_agent.m_sequencer;
      end
    endfunction : init_adc_vseq


    function void init_axi_vseq(remake_vseq_base vseq);
      if (env_config.has_araddr_stream_if) begin
        seq.araddr_sqr = m_env.m_araddr_stream.m_sequencer;
      end

      if (env_config.has_rresp_if_stream_slave_if) begin
        seq.rresp_sqr = m_env.m_rresp_stream_slave.m_sequencer;
      end


      if(env_config.has_awaddr_stream_if) begin
        seq.awaddr_sqr = m_env.m_awaddr_stream.m_sequencer;
      end
      
      if(env_config.has_wdata_stream_if) begin
        seq.wdata_sqr = m_env.m_wdata_stream.m_sequencer;
      end

      if(env_config.has_bresp_if_stream_slave_if) begin
        seq.bresp_sqr = m_env.m_bresp_stream_slave.m_sequencer;
      end
      
    endfunction : init_axi_vseq


  endclass : remake_test_base


  //------------------------------------------------------------------------------
  // Class: remake_calibration_test
  //------------------------------------------------------------------------------

  class remake_calibration_test extends remake_test_base;
    // UVM Factory Registration Macro
    `uvm_component_utils(remake_calibration_test)

    // Constructor.
    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    // Test's build phase.
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
    endfunction : build_phase

    // Environment configuration for current test.
    function void configure_env(remake_env_config env_config);
      env_config.has_stream_agent = 1'b1;
      //env_config.has_eth_stream_layering = 1'b1;

      env_config.has_araddr_stream_if = 1'b1;
      env_config.has_rresp_if_stream_slave_if = 1'b1;
      env_config.has_awaddr_stream_if = 1'b1;
      env_config.has_wdata_stream_if = 1'b1;
      env_config.has_bresp_if_stream_slave_if = 1'b1;

    endfunction : configure_env

    // // Main task executed by the test.
    task run_phase(uvm_phase phase);
      /*
      * 1. Async reset - write
      * 2. FIFO reset - write
      * 3. Enable raw data - write 
      * 4. debug_output(DESERIALIZER_CTRL, adc_ch) - write
      * 5. Enable enable debug - write
      * 6. Write pattern - write
      * 7. Read pattern - read
      * 8. Disable debug - write
      * 9. Disable raw data - write
      */
      remake_vseq_stream_trasm eth_trasm_vseq;
      eth_trasm_vseq = remake_vseq_stream_trasm::type_id::create("eth_trasm_vseq");

      remake_seq_read  read_FIFO;
      remake_seq_write write_seq;
      remake_seq_write write_seq2;
      remake_seq_write write_seq3;
      remake_seq_write write_seq4;
      
      read_FIFO  = remake_seq_read::type_id::create("read_FIFO");
      write_seq = remake_seq_write::type_id::create("write_seq");
      write_seq2 = remake_seq_write::type_id::create("write_seq2");
      write_seq3 = remake_seq_write::type_id::create("write_seq3");
      write_seq4 = remake_seq_write::type_id::create("write_seq4");


       init_axi_vseq(read_FIFO);
       init_axi_vseq(write_seq);
       init_axi_vseq(write_seq2);
       init_axi_vseq(write_seq3);
       init_axi_vseq(write_seq4);

      init_adc_vseq(eth_trasm_vseq);


      uvm_test_done.raise_objection(this);

      fork
        begin
          eth_trasm_vseq.start(null);
        end

        begin
 #(300ns);
          $display("Leyendo CORE ID");
          if (!read_FIFO.randomize() with {
                addr == CORE_ID_ADDR + OFFSET_ADDR;
              }) begin
            `uvm_error(get_full_name(), "Failed to randomize sequence!");
          end
          read_FIFO.start(null);

          #(300ns);
          $display("Escribiendo fifo enable");

          if (!write_seq.randomize() with {
                addr == FIFO_EN_ADDR + OFFSET_ADDR;
                data == 1;
              }) begin
            `uvm_error(get_full_name(), "Failed to randomize sequence!");
          end
          write_seq.start(null);

          #(40us);
          $display("Escribiendo fir mux reg");

          if (!write_seq4.randomize() with {
                addr == SEL_FIR_ADDR + OFFSET_ADDR;
                data == 2;
              }) begin
            `uvm_error(get_full_name(), "Failed to randomize sequence!");
          end
          write_seq4.start(null);

          #(10us);
          $display("Escribiendo data mux reg");

          if (!write_seq2.randomize() with {
                addr == SEL_SOURCE_ADDR + OFFSET_ADDR;
                data == 1;
              }) begin
            `uvm_error(get_full_name(), "Failed to randomize sequence!");
          end
          write_seq2.start(null);

          #(10us);
          $display("Escribiendo fir mux reg");

          if (!write_seq3.randomize() with {
                addr == SEL_FIR_ADDR + OFFSET_ADDR;
                data == 0;
              }) begin
            `uvm_error(get_full_name(), "Failed to randomize sequence!");
          end
          write_seq3.start(null);
         end

      join

      #(1ms);
      uvm_test_done.drop_objection(this);

    endtask : run_phase


  endclass : remake_calibration_test
  

endpackage : remake_test_pkg
