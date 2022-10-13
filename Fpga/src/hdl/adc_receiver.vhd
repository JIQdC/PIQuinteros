----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
-- 
-- Design Name: 
-- Module Name: 
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: ADC signals reception module
-- 
-- Dependencies: None.
-- 
-- Revision: 2020-11-11
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

use work.fifo_record_pkg.all;

entity adc_receiver is
  generic (
    RES_ADC : integer := 14; --ADC resolution, can take values 14 or 12
    N       : integer := 1;  --number of ADC data channels
    N_tr_b  : integer := 10  --bits for downsampler treshold register        
  );
  port (
    fpga_clk_i  : in std_logic;
    async_rst_i : in std_logic;

    adc_clk_p_i   : in std_logic;
    adc_clk_n_i   : in std_logic;
    adc_frame_p_i : in std_logic;
    adc_frame_n_i : in std_logic;
    adc_data_p_i  : in std_logic_vector((N - 1) downto 0);
    adc_data_n_i  : in std_logic_vector((N - 1) downto 0);
    adc_FCOlck_o  : out std_logic;

    treshold_value_i : in std_logic_vector((N_tr_b - 1) downto 0);
    treshold_ld_i    : in std_logic;

    debug_enable_i  : in std_logic;
    debug_control_i : in std_logic_vector((N * 4 - 1) downto 0);
    debug_w2w1_i    : in std_logic_vector((28 * N - 1) downto 0);

    fifo_rst_i   : in std_logic;
    fifo_rd_en_i : in std_logic_vector((N - 1) downto 0);
    fifo_out_o   : out fifo_out_vector_t((N - 1) downto 0);

    delay_refclk_i       : in std_logic;
    delay_data_ld_i      : in std_logic_vector((N - 1) downto 0);
    delay_data_input_i   : in std_logic_vector((5 * N - 1) downto 0);
    delay_data_output_o  : out std_logic_vector((5 * N - 1) downto 0);
    delay_frame_ld_i     : in std_logic;
    delay_frame_input_i  : in std_logic_vector((5 - 1) downto 0);
    delay_frame_output_o : out std_logic_vector((5 - 1) downto 0);

    --preprocessing signals
    data_source_sel : in std_logic_vector(1 downto 0);
    ch_1_freq   : in std_logic_vector(15 downto 0);
    ch_2_freq   : in std_logic_vector(15 downto 0);
    ch_3_freq   : in std_logic_vector(15 downto 0);
    ch_4_freq   : in std_logic_vector(15 downto 0);
    ch_5_freq   : in std_logic_vector(15 downto 0)
  );
end adc_receiver;

architecture arch of adc_receiver is

  --Binary counter declaration
  component c_counter_binary_0
    port (
      CLK  : in std_logic;
      CE   : in std_logic;
      SCLR : in std_logic;
      Q    : out std_logic_vector(13 downto 0)
    );
  end component;

  component clk_wiz_0_0
    port
     (-- Clock in ports
      -- Clock out ports
      clk_out1_0          : out    std_logic;
      -- Status and control signals
      reset_0             : in     std_logic;
      locked_0          : out    std_logic;
      clk_in1_0           : in     std_logic
     );
    end component;

  --FIFO generator declaration
  COMPONENT fifo_generator_0
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    full : OUT STD_LOGIC;
    overflow : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
    prog_full : OUT STD_LOGIC;
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;

  --Preprocessing components

  COMPONENT preprocessing_setup_0
  PORT (
    adc_clk_0 : IN STD_LOGIC;
    adc_rst_ni_0 : IN STD_LOGIC;
    data_local_osc : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_osc : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    data_sel_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    data_sel_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axis_0_tdata : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_0_tvalid : OUT STD_LOGIC;
    tready_osc_in : OUT STD_LOGIC;
    valid_local_osc : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT band_processing_v2_0
  PORT (
    adc_clk_0 : IN STD_LOGIC;
    adc_rst_ni_0 : IN STD_LOGIC;
    band_osc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    control_in_0 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    data_adc : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    data_counter : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_local_osc : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    valid_adc : IN STD_LOGIC;
    valid_counter : IN STD_LOGIC;
    valid_local_osc : IN STD_LOGIC;
    valid_mux_out : OUT STD_LOGIC;
    valid_out : OUT STD_LOGIC
  );
END COMPONENT;

COMPONENT ch_oscillator_0
  PORT (
    adc_clk_0 : IN STD_LOGIC;
    adc_rst_ni_0 : IN STD_LOGIC;
    m_axis_tdata_0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_config_tdata_0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

COMPONENT ch_mixer
  PORT (
    aclk : IN STD_LOGIC;
    aresetn : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_dout_tvalid : OUT STD_LOGIC;
    m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

COMPONENT ch_filter_0
  PORT (
    adc_clk_0 : IN STD_LOGIC;
    axis_out_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    axis_out_tvalid : OUT STD_LOGIC;
    data_in_0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    valid_in_0 : IN STD_LOGIC
  );
END COMPONENT;

  --End preprocessing components


  signal clk_to_bufs, clk_to_iddr, clk_to_logic, clk_div,
  clk_to_preproc, clk_to_counter, fifo_wr_clk, clk_to_debug            : std_logic;
  signal data_to_idelays, data_to_iddr, data_to_des_RE, data_to_des_FE : std_logic_vector((N - 1) downto 0);
  signal data_from_deser, data_from_debug                              : std_logic_vector((RES_ADC * N - 1) downto 0);
  signal valid_from_deser, valid_from_debug                            : std_logic_vector((N - 1) downto 0);
  
  --To be removed
  signal valid_from_dwsamp                                             : std_logic_vector((N - 1) downto 0);
  signal data_from_dwsamp                                              : std_logic_vector(16 * N - 1 downto 0);
  --End to be removed
  --Band and channel processing signals
  signal data_source_sel_cdc : std_logic_vector(1 downto 0);

  signal data_local_osc : std_logic_vector(15 downto 0);
  signal valid_local_osc : std_logic;
  signal data_preproc_counter : std_logic_vector(15 downto 0);
  signal valid_preproc_counter : std_logic;
  signal tready_for_osc : std_logic;
  signal data_band_osc : std_logic_vector(31 downto 0);
  
  signal ch_oscillator_output : std_logic_vector(31 downto 0);

  signal data_band_preproc                                             : std_logic_vector(32 * N - 1 downto 0);
  signal valid_band_preproc                                           : std_logic_vector((N - 1) downto 0);
  signal data_channel_preproc                                          : std_logic_vector(32 * N - 1 downto 0);
  signal valid_channel_preproc                                        : std_logic_vector((N - 1) downto 0);
  signal data_ch_filter_preproc                                       : std_logic_vector(32 * N - 1 downto 0);
  signal valid_ch_filter_preproc                                      : std_logic_vector((N - 1) downto 0);

  signal frame_to_idelay, frame_to_iddr, frame_delayed                 : std_logic;
  signal treshold_reg                                                  : std_logic_vector((N_tr_b - 1) downto 0);
  signal counter_ce_v                                                  : std_logic_vector((N - 1) downto 0);
  signal debug_counter                                                 : std_logic_vector(13 downto 0);
  signal debug_counter_ce                                              : std_logic;
  signal zerosN                                                        : std_logic_vector((N - 1) downto 0) := (others => '0');

  signal valid_from_pulse_sync                                        : std_logic_vector((N - 1) downto 0);

  signal data_from_deser_slow                                         : std_logic_vector(16 * N - 1 downto 0);
  signal valid_from_deser_slow                                        : std_logic_vector((N - 1) downto 0);

begin
  ---- BINARY COUNTER
  -- instantiate binary counter for debugging purposes
  binary_counter : c_counter_binary_0
  port map(
    CLK  => clk_to_counter,
    CE   => debug_counter_ce,
    SCLR => async_rst_i,
    Q    => debug_counter
  );
  --drive debug_counter_ce
  debug_counter_ce <= '1' when (counter_ce_v > zerosN) else
    '0';

  ---- CLOCK RECEPTION

  -- CLK > BUFIO > BUFG

  -- IDDR is driven by BUFIO
  -- BUFG output is used as clock for user logic

  -- IBUFDS: Differential Input Buffer
  --         Kintex-7
  IBUFDS_inst_clk : IBUFDS
  generic map(
    DIFF_TERM    => FALSE, -- Differential Termination 
    IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD   => "LVDS_25")
  port map(
    O  => clk_to_bufs, -- Buffer output
    I  => adc_clk_p_i, -- Diff_p buffer input (connect directly to top-level port)
    IB => adc_clk_n_i  -- Diff_n buffer input (connect directly to top-level port)
  );

  -- BUFIO: Local Clock Buffer for I/O
  --        Kintex-7
  BUFIO_inst_clk : BUFIO
  port map(
    O => clk_to_iddr, -- 1-bit output: Clock output (connect to I/O clock loads).
    I => clk_to_bufs  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
  );

  -- BUFG: Global Clock Simple Buffer
  --       Kintex-7
  BUFG_inst : BUFG
  port map(
    O => clk_to_logic, -- 1-bit output: Clock output
    I => clk_to_bufs   -- 1-bit input: Clock input
  );

  ---- FRAME

  -- IBUFDS: Differential Input Buffer
  --         Kintex-7
  IBUFDS_inst_frame : IBUFDS
  generic map(
    DIFF_TERM    => FALSE, -- Differential Termination 
    IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD   => "LVDS_25")
  port map(
    O  => frame_to_idelay, -- Buffer output
    I  => adc_frame_p_i,   -- Diff_p buffer input (connect directly to top-level port)
    IB => adc_frame_n_i    -- Diff_n buffer input (connect directly to top-level port)
  );

  -- IDELAY: instantiate idelay_wrapper
  IDELAYE2_inst_frame : entity work.idelay_wrapper(arch)
    port map(
      async_rst_i => async_rst_i,
      data_i      => frame_to_idelay,
      data_o      => frame_to_iddr,
      clk_i       => delay_refclk_i,
      ld_i        => delay_frame_ld_i,
      input_i     => delay_frame_input_i,
      output_o    => delay_frame_output_o
    );

  -- IDDR: Double Data Rate Input Register with Set, Reset
  --       and Clock Enable. 
  --       Kintex-7
  IDDR_inst_frame : IDDR
  generic map(
    DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
    -- or "SAME_EDGE_PIPELINED" 
    INIT_Q1 => '0',     -- Initial value of Q1: '0' or '1'
    INIT_Q2 => '0',     -- Initial value of Q2: '0' or '1'
    SRTYPE  => "ASYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
  port map(
    Q1 => open,          -- 1-bit output for positive edge of clock 
    Q2 => frame_delayed, -- 1-bit output for negative edge of clock
    C  => clk_to_iddr,   -- 1-bit clock input
    CE => '1',           -- 1-bit clock enable input
    D  => frame_to_iddr, -- 1-bit DDR data input
    R  => async_rst_i,   -- 1-bit reset
    S  => '0'            -- 1-bit set
  );

  -- clk_div from frame
  -- clk_div <= not(frame_delayed);


  -- clk wizard instantiation
  -- FCO_clk_wiz : frame_clk_wiz_0
  -- port map(
  --   -- Clock out ports  
  --   clk_to_preproc => clk_to_preproc,
  --   fifo_wr_clk    => fifo_wr_clk,
  --   clk_to_counter => clk_to_counter,
  --   clk_to_debug   => clk_to_debug,
  --   -- Status and control signals                
  --   reset  => async_rst_i,
  --   locked => adc_FCOlck_o,
  --   -- Clock in ports
  --   clk_in1 => clk_div
  -- );
  FCO_clk_wiz : clk_wiz_0_0
   port map ( 
  -- Clock out ports  
   clk_out1_0 => clk_div,
  -- Status and control signals                
   reset_0 => async_rst_i,
   locked_0 => adc_FCOlck_o,
   -- Clock in ports
   clk_in1_0 => clk_to_logic
 );

 --Assign clk_div to 4 legacy clks
 clk_to_preproc <= clk_div;
 clk_to_debug <= clk_div;
 clk_to_counter <= clk_div;
 fifo_wr_clk <= clk_div;

 --Not useful without downsampler
  ---- TRESHOLD REGISTER FOR DOWNSAMPLER
  -- tresh_reg_inst : entity work.downsampler_tresh_reg(arch)
  --   generic map(
  --     N_tr_b => N_tr_b
  --   )
  --   port map(
  --     d_clk_i        => clk_to_preproc,
  --     rst_i          => async_rst_i,
  --     treshold_i     => treshold_value_i,
  --     treshold_ld_i  => treshold_ld_i,
  --     treshold_reg_o => treshold_reg
  --   );

  ---- ADC DATA INPUTS

--Instantitate preprocessing_setup
  preprocessing_setup_inst : preprocessing_setup_0
  PORT MAP (
    adc_clk_0 => clk_to_preproc,
    adc_rst_ni_0 => not(async_rst_i),
    data_local_osc => data_local_osc,
    valid_local_osc => valid_local_osc,
    data_osc => data_band_osc,
    data_sel_in => data_source_sel,
    data_sel_out => data_source_sel_cdc,
    m_axis_0_tdata => data_preproc_counter,
    m_axis_0_tvalid => valid_preproc_counter,
    tready_osc_in => tready_for_osc
  );

  --Instantiate ch_oscillator (for now only one)

  ch_osc_inst : ch_oscillator_0
  PORT MAP (
    adc_clk_0 => clk_to_preproc,
    adc_rst_ni_0 => not(async_rst_i),
    s_axis_config_tdata_0 => ch_1_freq,
    m_axis_tdata_0 => ch_oscillator_output
  );

  -- Generate IBUFDS, IDELAYs, IDDR, deserializer, downsampler for ADC data inputs
  ADC_data : for i in 0 to (N - 1) generate

    -- IBUFDS: Differential Input Buffer
    --         Kintex-7
    IBUFDS_inst_data : IBUFDS
    generic map(
      DIFF_TERM    => FALSE, -- Differential Termination 
      IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map(
      O  => data_to_idelays(i), -- Buffer output
      I  => adc_data_p_i(i),    -- Diff_p buffer input (connect directly to top-level port)
      IB => adc_data_n_i(i)     -- Diff_n buffer input (connect directly to top-level port)
    );

    -- IDELAY: instantiate idelay_wrapper
    IDELAYE2_inst_data : entity work.idelay_wrapper(arch)
      port map(
        async_rst_i => async_rst_i,
        data_i      => data_to_idelays(i),
        data_o      => data_to_iddr(i),
        clk_i       => delay_refclk_i,
        ld_i        => delay_data_ld_i(i),
        input_i     => delay_data_input_i((5 * (i + 1) - 1) downto (5 * i)),
        output_o    => delay_data_output_o((5 * (i + 1) - 1) downto (5 * i))
      );

    -- IDDR: Double Data Rate Input Register with Set, Reset
    --       and Clock Enable. 
    --       Kintex-7
    IDDR_inst_data : IDDR
    generic map(
      DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
      -- or "SAME_EDGE_PIPELINED" 
      INIT_Q1 => '0',     -- Initial value of Q1: '0' or '1'
      INIT_Q2 => '0',     -- Initial value of Q2: '0' or '1'
      SRTYPE  => "ASYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
    port map(
      Q1 => data_to_des_RE(i), -- 1-bit output for positive edge of clock 
      Q2 => data_to_des_FE(i), -- 1-bit output for negative edge of clock
      C  => clk_to_iddr,       -- 1-bit clock input
      CE => '1',               -- 1-bit clock enable input
      D  => data_to_iddr(i),   -- 1-bit DDR data input
      R  => async_rst_i,       -- 1-bit reset
      S  => '0'                -- 1-bit set
    );

    --instantiate deserializer
    deserializer_data : entity work.deserializer(arch)
      generic map(
        RES_ADC => RES_ADC
      )
      port map(
        adc_clk_i => clk_to_logic,
        rst_i     => async_rst_i,
        data_RE_i => data_to_des_RE(i),
        data_FE_i => data_to_des_FE(i),
        frame_i   => frame_delayed,
        data_o    => data_from_deser((14 * (i + 1) - 1) downto (14 * i)),
        d_valid_o => valid_from_deser(i)
      );


    --instantiate pulse_sync
    pulse_sync_data : entity work.pulse_sync(arch)
      port map(
        src_clk => clk_to_logic,
        src_rst_i => async_rst_i,
        dest_clk => clk_to_preproc,
        dest_rst_i => async_rst_i,
        pulse_i => valid_from_deser(i),
        pulse_o => valid_from_pulse_sync(i)
      );

    -- process(valid_from_pulse_sync)
    -- begin
    --   if valid_from_pulse_sync(i) = '1' then
    --     data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i)) <= data_from_deser((14 * (i + 1) - 1) downto (14 * i));
    --   else
    --     data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i)) <= data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i));
    --   end if;
    -- end process;

    --instantiate sampler_with_ce
    sampler_data : entity work.sampler_with_ce(arch)
      generic map(
        N => 14
      )
      port map(
        clk => clk_to_preproc,
        rst_i => async_rst_i,
        ce => valid_from_pulse_sync(i),
        din => data_from_deser((14 * (i + 1) - 1) downto (14 * i)),
        dout => data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i)),
        dout_valid => valid_from_deser_slow(i)
      );
      
    --instantiate debug control
    deb_control_data : entity work.debug_control(arch)
      generic map(
        RES_ADC => RES_ADC
      )
      port map(
        clock_i    => clk_to_debug,
        rst_i      => async_rst_i,
        enable_i   => debug_enable_i,
        control_i  => debug_control_i(((4 * (i + 1)) - 1) downto (4 * i)),
        usr_w2w1_i => debug_w2w1_i(((28 * (i + 1)) - 1) downto (28 * i)),
        --data_i     => data_from_deser((14 * (i + 1) - 1) downto (14 * i)),
        data_i     => data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i)),
        --valid_i    => valid_from_deser(i),
        valid_i    => valid_from_deser_slow(i),

        counter_count_i => debug_counter,
        counter_ce_o    => counter_ce_v(i),

        data_o  => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
        valid_o => valid_from_debug(i)
      );

--------Replace downsampler with preprocessing

    --instantiate downsampler
    -- downsampler_data : entity work.downsampler(arch)
    --   generic map(
    --     N_tr_b => N_tr_b
    --   )
    --   port map(
    --     d_clk_i        => clk_to_preproc,
    --     rst_i          => async_rst_i,
    --     data_i         => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
    --     d_valid_i      => valid_from_debug(i),
    --     treshold_reg_i => treshold_reg,
    --     treshold_ld_i  => treshold_ld_i,
    --     data_o         => data_from_dwsamp((16 * (i + 1) - 1) downto (16 * i)),
    --     d_valid_o      => valid_from_dwsamp(i)
    --   );

    -- Band preprocessing: Multiplies and filters

  band_processing_bd_inst : band_processing_v2_0
  PORT MAP (
    adc_clk_0 => clk_to_preproc,
    adc_rst_ni_0 => not(async_rst_i),
    band_osc_in => data_band_osc,
    control_in_0 => data_source_sel_cdc,
    data_adc => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
    data_counter => data_preproc_counter,
    data_local_osc => data_local_osc,
    data_out => data_band_preproc((32 * (i + 1) - 1) downto (32 * i)),
    valid_adc => valid_from_debug(i),
    valid_counter => valid_preproc_counter,
    valid_local_osc => valid_local_osc,
    valid_mux_out => tready_for_osc,
    valid_out => valid_band_preproc(i)
  );

    -- channel_preprocessing_inst : channel_processing_0
    -- port map (
    --   adc_clk_0 => clk_to_preproc,
    --   adc_rst_ni_0 => not(async_rst_i),
    --   m_axis_dout_tdata => data_channel_preproc((32 * (i + 1) - 1) downto (32 * i)),
    --   m_axis_dout_tvalid => valid_channel_preproc(i),
    --   s_axis_config_tdata_0 => ch_1_freq,
    --   s_axis_tdata_in => data_band_preproc((32 * (i + 1) - 1) downto (32 * i)),
    --   s_axis_tvalid_in => valid_band_preproc(i)
    -- );

  --Aca debe hacerse un for para 5 beams
  ch_mixer_inst : ch_mixer
  PORT MAP (
    aclk => clk_to_preproc,
    aresetn => not(async_rst_i),
    s_axis_a_tvalid => valid_band_preproc(i),
    s_axis_a_tdata => data_band_preproc((32 * (i + 1) - 1) downto (32 * i)),
    s_axis_b_tvalid => valid_band_preproc(i),
    s_axis_b_tdata => ch_oscillator_output,
    m_axis_dout_tvalid => valid_channel_preproc(i),
    m_axis_dout_tdata => data_channel_preproc((32 * (i + 1) - 1) downto (32 * i))
  );

  --Aca falta incorporar el mux para seleccionar el beam

  ch_filter_inst : ch_filter_0
  PORT MAP (
    adc_clk_0 => clk_to_preproc,
    data_in_0 => data_channel_preproc((32 * (i + 1) - 1) downto (32 * i)),
    valid_in_0 => valid_channel_preproc(i),
    axis_out_tdata => data_ch_filter_preproc((32 * (i + 1) - 1) downto (32 * i)),
    axis_out_tvalid => valid_ch_filter_preproc(i)
  );




-------- End of replace downsampler with preprocessing

    --instantiate FIFO
    fifo_inst : fifo_generator_0
    port map(
      rst           => fifo_rst_i,
      wr_clk        => fifo_wr_clk,
      rd_clk        => fpga_clk_i,
      din           => data_ch_filter_preproc((32 * (i + 1) - 1) downto (32 * i)),
      wr_en         => valid_ch_filter_preproc(i),
      rd_en         => fifo_rd_en_i(i),
      dout          => fifo_out_o(i).data_out,
      full          => fifo_out_o(i).full,
      overflow      => fifo_out_o(i).overflow,
      empty         => fifo_out_o(i).empty,
      rd_data_count => fifo_out_o(i).rd_data_cnt,
      prog_full     => fifo_out_o(i).prog_full,
      wr_rst_busy   => fifo_out_o(i).wr_rst_bsy,
      rd_rst_busy   => fifo_out_o(i).rd_rst_bsy
    );

  end generate ADC_data;

end arch; -- arch