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
    fpga_clk_i           : in std_logic;
    async_rst_i          : in std_logic;

    adc_clk_p_i          : in std_logic;
    adc_clk_n_i          : in std_logic;
    adc_frame_p_i        : in std_logic;
    adc_frame_n_i        : in std_logic;
    adc_data_p_i         : in std_logic_vector((N - 1) downto 0);
    adc_data_n_i         : in std_logic_vector((N - 1) downto 0);
    adc_FCOlck_o         : out std_logic;

    treshold_value_i     : in std_logic_vector((N_tr_b - 1) downto 0);
    treshold_ld_i        : in std_logic;

    debug_enable_i       : in std_logic;
    debug_control_i      : in std_logic_vector((N * 4 - 1) downto 0);
    debug_w2w1_i         : in std_logic_vector((28 * N - 1) downto 0);

    fifo_rst_i           : in std_logic;
    fifo_rd_en_i         : in std_logic_vector((N - 1) downto 0);
    fifo_out_o           : out fifo_out_vector_t((N - 1) downto 0);

    delay_refclk_i       : in std_logic;
    delay_data_ld_i      : in std_logic_vector((N - 1) downto 0);
    delay_data_input_i   : in std_logic_vector((5 * N - 1) downto 0);
    delay_data_output_o  : out std_logic_vector((5 * N - 1) downto 0);
    delay_frame_ld_i     : in std_logic;
    delay_frame_input_i  : in std_logic_vector((5 - 1) downto 0);
    delay_frame_output_o : out std_logic_vector((5 - 1) downto 0);

    --preprocessing signals
    fifo_input_mux_sel_i : in std_logic_vector(2 downto 0);
    data_source_sel_i    : in std_logic_vector(1 downto 0);
    ch_1_freq_i          : in std_logic_vector(15 downto 0);
    ch_1_freq_valid_i    : in std_logic;
    ch_2_freq_i          : in std_logic_vector(15 downto 0);
    ch_2_freq_valid_i    : in std_logic;
    ch_3_freq_i          : in std_logic_vector(15 downto 0);
    ch_3_freq_valid_i    : in std_logic;
    ch_4_freq_i          : in std_logic_vector(15 downto 0);
    ch_4_freq_valid_i    : in std_logic;
    ch_5_freq_i          : in std_logic_vector(15 downto 0);
    ch_5_freq_valid_i    : in std_logic
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
    port (-- Clock in ports
      -- Clock out ports
      clk_out1_0 : out std_logic;
      -- Status and control signals
      reset_0    : in std_logic;
      locked_0   : out std_logic;
      clk_in1_0  : in std_logic
    );
  end component;

  --FIFO generator declaration
  component fifo_generator_0
    port (
      rst           : in std_logic;
      wr_clk        : in std_logic;
      rd_clk        : in std_logic;
      din           : in std_logic_vector(31 downto 0);
      wr_en         : in std_logic;
      rd_en         : in std_logic;
      dout          : out std_logic_vector(31 downto 0);
      full          : out std_logic;
      overflow      : out std_logic;
      empty         : out std_logic;
      rd_data_count : out std_logic_vector(10 downto 0);
      prog_full     : out std_logic;
      wr_rst_busy   : out std_logic;
      rd_rst_busy   : out std_logic
    );
  end component;

  --Preprocessing components

  component preprocessing_setup_bd_0
    port (
      adc_clk_0       : in std_logic;
      adc_rst_ni_0    : in std_logic;
      data_local_osc  : out std_logic_vector(15 downto 0);
      data_osc        : out std_logic_vector(31 downto 0);
      data_sel_in     : in std_logic_vector(1 downto 0);
      data_sel_out    : out std_logic_vector(1 downto 0);
      m_axis_0_tdata  : out std_logic_vector(15 downto 0);
      m_axis_0_tvalid : out std_logic;
      tready_osc_in   : in std_logic;
      valid_local_osc : out std_logic
    );
  end component;

  component band_processing_v2_0
    port (
      adc_clk_0       : in std_logic;
      adc_rst_ni_0    : in std_logic;
      band_mixer_data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      band_mixer_valid_o : OUT STD_LOGIC;
      band_osc_in     : in std_logic_vector(31 downto 0);
      control_in_0    : in std_logic_vector(1 downto 0);
      data_adc        : in std_logic_vector(13 downto 0);
      data_counter    : in std_logic_vector(15 downto 0);
      data_local_osc  : in std_logic_vector(15 downto 0);
      data_out        : out std_logic_vector(31 downto 0);
      valid_adc       : in std_logic;
      valid_counter   : in std_logic;
      valid_local_osc : in std_logic;
      valid_mux_out   : out std_logic;
      valid_out       : out std_logic
    );
  end component;

  component ch_oscillator_0
    port (
      adc_clk_0              : in std_logic;
      adc_rst_ni_0           : in std_logic;
      m_axis_tdata_0         : out std_logic_vector(31 downto 0);
      s_axis_config_tdata_0  : in std_logic_vector(15 downto 0);
      s_axis_config_tvalid_0 : in std_logic
    );
  end component;

  component ch_mixer
    port (
      aclk               : in std_logic;
      aresetn            : in std_logic;
      s_axis_a_tvalid    : in std_logic;
      s_axis_a_tdata     : in std_logic_vector(31 downto 0);
      s_axis_b_tvalid    : in std_logic;
      s_axis_b_tdata     : in std_logic_vector(31 downto 0);
      m_axis_dout_tvalid : out std_logic;
      m_axis_dout_tdata  : out std_logic_vector(31 downto 0)
    );
  end component;

  component ch_filter_0
    port (
      adc_clk_0       : in std_logic;
      axis_out_tdata  : out std_logic_vector(31 downto 0);
      axis_out_tvalid : out std_logic;
      data_in_0       : in std_logic_vector(31 downto 0);
      valid_in_0      : in std_logic
    );
  end component;

  component counter_32_bits
    port (
      CLK  : in std_logic;
      CE   : in std_logic;
      SCLR : in std_logic;
      Q    : out std_logic_vector(31 downto 0)
    );
  end component;

  --End preprocessing components
  signal clk_to_bufs, clk_to_iddr, clk_to_logic, clk_260_mhz : std_logic;
  signal data_to_idelays, data_to_iddr, data_to_des_RE, data_to_des_FE : std_logic_vector((N - 1) downto 0);
  signal data_from_deser, data_from_debug : std_logic_vector((RES_ADC * N - 1) downto 0);
  signal valid_from_deser, valid_from_debug : std_logic_vector((N - 1) downto 0);

  --To be removed
  signal valid_from_dwsamp : std_logic_vector((N - 1) downto 0);
  signal data_from_dwsamp : std_logic_vector(16 * N - 1 downto 0);
  --End to be removed
  --Band and channel processing signals
  signal data_local_osc : std_logic_vector(15 downto 0);
  signal valid_local_osc : std_logic;
  signal data_preproc_counter : std_logic_vector(15 downto 0);
  signal valid_preproc_counter : std_logic;
  signal tready_for_osc : std_logic_vector((N - 1) downto 0);
  signal data_band_osc : std_logic_vector(31 downto 0);

  signal ch_oscillator_output : std_logic_vector(31 downto 0);

  signal data_band_mixer_debug : std_logic_vector(32 * N - 1 downto 0);
  signal valid_band_mixer_debug : std_logic_vector((N - 1) downto 0);
  
  signal data_band_preproc : std_logic_vector(32 * N - 1 downto 0);
  signal valid_band_preproc : std_logic_vector((N - 1) downto 0);
  signal data_channel_preproc : std_logic_vector(32 * N - 1 downto 0);
  signal valid_channel_preproc : std_logic_vector((N - 1) downto 0);
  signal data_ch_filter_preproc : std_logic_vector(32 * N - 1 downto 0);
  signal valid_ch_filter_preproc : std_logic_vector((N - 1) downto 0);

  signal data_counter_post_preprocessing : std_logic_vector(31 downto 0);
  signal valid_counter_post_preprocessing : std_logic;

  signal data_fifo_input : std_logic_vector(32 * N - 1 downto 0);
  signal valid_fifo_input : std_logic_vector((N - 1) downto 0);

  signal frame_to_idelay, frame_to_iddr, frame_delayed : std_logic;
  signal treshold_reg : std_logic_vector((N_tr_b - 1) downto 0);
  signal counter_ce_v : std_logic_vector((N - 1) downto 0);
  signal debug_counter : std_logic_vector(13 downto 0);
  signal debug_counter_ce : std_logic;
  signal zerosN : std_logic_vector((N - 1) downto 0) := (others => '0');

  signal valid_from_pulse_sync : std_logic_vector((N - 1) downto 0);

  signal data_from_deser_slow : std_logic_vector(16 * N - 1 downto 0);
  signal valid_from_deser_slow : std_logic_vector((N - 1) downto 0);

  signal async_rst_n : std_logic;

  -- synchronize signals from preproc
  signal fifo_input_mux_sel_sync : std_logic_vector(2 downto 0);
  signal data_source_sel_sync : std_logic_vector(1 downto 0);
  signal ch_1_freq_sync : std_logic_vector(15 downto 0);
  signal ch_1_freq_valid_sync : std_logic;
  signal ch_2_freq_sync : std_logic_vector(15 downto 0);
  signal ch_2_freq_valid_sync : std_logic;
  signal ch_3_freq_sync : std_logic_vector(15 downto 0);
  signal ch_3_freq_valid_sync : std_logic;
  signal ch_4_freq_sync : std_logic_vector(15 downto 0);
  signal ch_4_freq_valid_sync : std_logic;
  signal ch_5_freq_sync : std_logic_vector(15 downto 0);
  signal ch_5_freq_valid_sync : std_logic;

  -- synchronize signals from write_side of FIFO
  signal fifo_full : std_logic_vector((N - 1) downto 0);
  signal fifo_wr_rst_bsy : std_logic_vector((N - 1) downto 0);
  signal fifo_prog_full : std_logic_vector((N - 1) downto 0);
  signal fifo_overflow : std_logic_vector((N - 1) downto 0);

  -- synchronize signals from debug control
  signal debug_enable_sync : std_logic;
  signal debug_control_sync : std_logic_vector((N * 4 - 1) downto 0);
  constant debug_control_width : integer := (N * 4);
  signal debug_w2w1_sync : std_logic_vector((28 * N - 1) downto 0);
  constant debug_w2w1_width : integer := (28 * N);

  --Debug signals
  -- attribute MARK_DEBUG : string;
  -- attribute MARK_DEBUG of data_from_debug : signal is "true";
  -- attribute MARK_DEBUG of valid_from_debug : signal is "true";
  -- attribute MARK_DEBUG of data_from_deser : signal is "true";
  -- attribute MARK_DEBUG of valid_from_deser : signal is "true";
  -- attribute MARK_DEBUG of data_from_deser_slow : signal is "true";
  -- attribute MARK_DEBUG of valid_from_deser_slow : signal is "true";
  -- attribute MARK_DEBUG of data_fifo_input : signal is "true";
  -- attribute MARK_DEBUG of valid_fifo_input : signal is "true";
  -- attribute MARK_DEBUG of fifo_input_mux_sel_i : signal is "true";
  -- attribute MARK_DEBUG of fifo_input_mux_sel_sync : signal is "true";
  -- attribute MARK_DEBUG of data_to_iddr : signal is "true";
  -- attribute MARK_DEBUG of data_to_des_RE : signal is "true";
  -- attribute MARK_DEBUG of data_to_des_FE : signal is "true";
  -- attribute MARK_DEBUG of frame_to_iddr : signal is "true";
  
begin

  ---- Instantiate synchronizers for preproc signals
  fifo_input_mux_sel_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => 3
    )
    port map(
      src_data_i  => fifo_input_mux_sel_i,
      sys_clk_i   => clk_260_mhz,
      sync_data_o => fifo_input_mux_sel_sync
    );
  data_source_sel_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => 2
    )
    port map(
      src_data_i  => data_source_sel_i,
      sys_clk_i   => clk_260_mhz,
      sync_data_o => data_source_sel_sync
    );

  ch_1_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 16
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_1_freq_i,
      src_valid_i => ch_1_freq_valid_i,
      dst_clk_i   => clk_260_mhz,
      dst_data_o  => ch_1_freq_sync,
      dst_valid_o => ch_1_freq_valid_sync
    );
  ch_2_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 16
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_2_freq_i,
      src_valid_i => ch_2_freq_valid_i,
      dst_clk_i   => clk_260_mhz,
      dst_data_o  => ch_2_freq_sync,
      dst_valid_o => ch_2_freq_valid_sync
    );
  ch_3_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 16
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_3_freq_i,
      src_valid_i => ch_3_freq_valid_i,
      dst_clk_i   => clk_260_mhz,
      dst_data_o  => ch_3_freq_sync,
      dst_valid_o => ch_3_freq_valid_sync
    );
  ch_4_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 16
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_4_freq_i,
      src_valid_i => ch_4_freq_valid_i,
      dst_clk_i   => clk_260_mhz,
      dst_data_o  => ch_4_freq_sync,
      dst_valid_o => ch_4_freq_valid_sync
    );
  ch_5_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 16
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_5_freq_i,
      src_valid_i => ch_5_freq_valid_i,
      dst_clk_i   => clk_260_mhz,
      dst_data_o  => ch_5_freq_sync,
      dst_valid_o => ch_5_freq_valid_sync
    );

  -- Instantiate synchronizers for debug signals
  debug_control_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => debug_control_width
    )
    port map(
      src_data_i  => debug_control_i,
      sys_clk_i   => clk_260_mhz,
      sync_data_o => debug_control_sync
    );

  debug_w2w1_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => debug_w2w1_width
    )
    port map(
      src_data_i  => debug_w2w1_i,
      sys_clk_i   => clk_260_mhz,
      sync_data_o => debug_w2w1_sync
    );

  debug_enable_sync_inst : entity work.level_sync
    port map(
      dest_clk_i => clk_260_mhz,
      dest_rst_i => async_rst_i,
      level_i    => debug_enable_i,
      level_o    => debug_enable_sync
    );
  ---- Invert reset
  async_rst_n <= not(async_rst_i);

  ---- BINARY COUNTER
  -- instantiate binary counter for debugging purposes
  binary_counter : c_counter_binary_0
  port map(
    CLK  => clk_260_mhz,
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
    INIT_Q1      => '0',                   -- Initial value of Q1: '0' or '1'
    INIT_Q2      => '0',                   -- Initial value of Q2: '0' or '1'
    SRTYPE       => "ASYNC")               -- Set/Reset type: "SYNC" or "ASYNC"
  port map(
    Q1 => open,          -- 1-bit output for positive edge of clock
    Q2 => frame_delayed, -- 1-bit output for negative edge of clock
    C  => clk_to_iddr,   -- 1-bit clock input
    CE => '1',           -- 1-bit clock enable input
    D  => frame_to_iddr, -- 1-bit DDR data input
    R  => async_rst_i,   -- 1-bit reset
    S  => '0'            -- 1-bit set
  );

  FCO_clk_wiz : clk_wiz_0_0
  port map(
    -- Clock out ports
    clk_out1_0 => clk_260_mhz,
    -- Status and control signals
    reset_0    => async_rst_i,
    locked_0   => adc_FCOlck_o,
    -- Clock in ports
    clk_in1_0  => clk_to_logic
  );

  ---- ADC DATA INPUTS

  --Instantitate preprocessing_setup
  preprocessing_setup_inst : preprocessing_setup_bd_0
  port map(
    adc_clk_0       => clk_260_mhz,
    adc_rst_ni_0    => async_rst_n,
    data_local_osc  => data_local_osc,
    valid_local_osc => valid_local_osc,
    data_osc        => data_band_osc,
    data_sel_in => (others => '0'),
    data_sel_out    => open,
    m_axis_0_tdata  => data_preproc_counter,
    m_axis_0_tvalid => valid_preproc_counter,
    tready_osc_in   => tready_for_osc(0)
  );

  --Instantiate ch_oscillator (for now only one)

  ch_osc_inst : ch_oscillator_0
  port map(
    adc_clk_0              => clk_260_mhz,
    adc_rst_ni_0           => async_rst_n,
    s_axis_config_tdata_0  => ch_1_freq_sync,
    s_axis_config_tvalid_0 => ch_1_freq_valid_sync,
    m_axis_tdata_0         => ch_oscillator_output
  );
  --Instantiate debug counter
  -- debug_counter_inst : entity work.basic_counter(rtl)
  --   generic map(
  --     COUNTER_WIDTH      => 32,
  --     DIVIDE_CLK_FREQ_BY => 1600)
  --   port map(
  --     clk_i => clk_260_mhz,
  --     rst_ni => async_rst_n,
  --     m_axis_tdata => data_counter_post_preprocessing,
  --     m_axis_tvalid => valid_counter_post_preprocessing
  --   );
  debug_counter_inst : counter_32_bits
  port map(
    CLK  => clk_260_mhz,
    CE   => valid_fifo_input(0),
    SCLR => async_rst_i,
    Q    => data_counter_post_preprocessing
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
      INIT_Q1      => '0',                   -- Initial value of Q1: '0' or '1'
      INIT_Q2      => '0',                   -- Initial value of Q2: '0' or '1'
      SRTYPE       => "ASYNC")               -- Set/Reset type: "SYNC" or "ASYNC"
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
        src_clk_i  => clk_to_logic,
        src_rst_i  => async_rst_i,
        dest_clk_i => clk_260_mhz,
        dest_rst_i => async_rst_i,
        pulse_i    => valid_from_deser(i),
        pulse_o    => valid_from_pulse_sync(i)
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
        clk        => clk_260_mhz,
        rst_i      => async_rst_i,
        ce         => valid_from_pulse_sync(i),
        din        => data_from_deser((14 * (i + 1) - 1) downto (14 * i)),
        dout       => data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i)),
        dout_valid => valid_from_deser_slow(i)
      );

    --instantiate debug control
    deb_control_data : entity work.debug_control(arch)
      generic map(
        RES_ADC => RES_ADC
      )
      port map(
        clock_i         => clk_260_mhz,
        rst_i           => async_rst_i,
        enable_i        => debug_enable_sync,
        control_i       => debug_control_sync(((4 * (i + 1)) - 1) downto (4 * i)),
        usr_w2w1_i      => debug_w2w1_sync(((28 * (i + 1)) - 1) downto (28 * i)),
        --data_i     => data_from_deser((14 * (i + 1) - 1) downto (14 * i)),
        data_i          => data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i)),
        --valid_i    => valid_from_deser(i),
        valid_i         => valid_from_deser_slow(i),

        counter_count_i => debug_counter,
        counter_ce_o    => counter_ce_v(i),

        data_o          => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
        valid_o         => valid_from_debug(i)
      );

    --------Replace downsampler with preprocessing

    --instantiate downsampler
    -- downsampler_data : entity work.downsampler(arch)
    --   generic map(
    --     N_tr_b => N_tr_b
    --   )
    --   port map(
    --     d_clk_i        => clk_260_mhz,
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
    port map(
      adc_clk_0       => clk_260_mhz,
      adc_rst_ni_0    => async_rst_n,
      band_osc_in     => data_band_osc,
      control_in_0    => data_source_sel_sync,
      data_adc        => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
      data_counter    => data_preproc_counter,
      data_local_osc  => data_local_osc,
      data_out        => data_band_preproc((32 * (i + 1) - 1) downto (32 * i)),
      valid_adc       => valid_from_debug(i),
      valid_counter   => valid_preproc_counter,
      valid_local_osc => valid_local_osc,
      band_mixer_data_o => data_band_mixer_debug((32 * (i + 1) - 1) downto (32 * i)),
      band_mixer_valid_o => valid_band_mixer_debug(i),
      valid_mux_out   => tready_for_osc(i),
      valid_out       => valid_band_preproc(i)
    );

    -- channel_preprocessing_inst : channel_processing_0
    -- port map (
    --   adc_clk_0 => clk_260_mhz,
    --   adc_rst_ni_0 => async_rst_n,
    --   m_axis_dout_tdata => data_channel_preproc((32 * (i + 1) - 1) downto (32 * i)),
    --   m_axis_dout_tvalid => valid_channel_preproc(i),
    --   s_axis_config_tdata_0 => ch_1_freq_i,
    --   s_axis_tdata_in => data_band_preproc((32 * (i + 1) - 1) downto (32 * i)),
    --   s_axis_tvalid_in => valid_band_preproc(i)
    -- );

    --Aca debe hacerse un for para 5 beams
    ch_mixer_inst : ch_mixer
    port map(
      aclk               => clk_260_mhz,
      aresetn            => async_rst_n,
      s_axis_a_tvalid    => valid_band_preproc(i),
      s_axis_a_tdata     => data_band_preproc((32 * (i + 1) - 1) downto (32 * i)),
      s_axis_b_tvalid    => valid_band_preproc(i),
      s_axis_b_tdata     => ch_oscillator_output,
      m_axis_dout_tvalid => valid_channel_preproc(i),
      m_axis_dout_tdata  => data_channel_preproc((32 * (i + 1) - 1) downto (32 * i))
    );

    --Aca falta incorporar el mux para seleccionar el beam

    ch_filter_inst : ch_filter_0
    port map(
      adc_clk_0       => clk_260_mhz,
      data_in_0       => data_channel_preproc((32 * (i + 1) - 1) downto (32 * i)),
      valid_in_0      => valid_channel_preproc(i),
      axis_out_tdata  => data_ch_filter_preproc((32 * (i + 1) - 1) downto (32 * i)),
      axis_out_tvalid => valid_ch_filter_preproc(i)
    );

    -- Select FIFO input
    fifo_input_mux_inst : entity work.fifo_input_data_mux
      port map(
        sys_clk_i            => clk_260_mhz,
        sys_rst_i            => async_rst_i,
        -- Mux control
        data_mux_sel_i       => fifo_input_mux_sel_sync,
        -- Data from preprocessing logic
        data_preproc_i       => data_ch_filter_preproc((32 * (i + 1) - 1) downto (32 * i)),
        data_preproc_valid_i => valid_ch_filter_preproc(i),
        -- Data from debug counter
        data_counter_i       => data_counter_post_preprocessing,
        data_counter_valid_i => valid_ch_filter_preproc(0),
        -- Raw data from deserializer
        data_raw_i           => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
        data_raw_valid_i     => valid_from_debug(i),
        -- Band mixer
        data_band_mixer_i         => data_band_mixer_debug((32 * (i + 1) - 1) downto (32 * i)),
        data_band_mixer_valid_i   => valid_band_mixer_debug(i),
        -- Channel mixer    
        data_channel_mixer_i => data_channel_preproc((32 * (i + 1) - 1) downto (32 * i)),
        data_channel_mixer_valid_i => valid_channel_preproc(i),
        -- Preprocessing counter for debug
      data_preproc_counter_i   => data_preproc_counter,
      data_preproc_counter_valid_i => valid_preproc_counter,
        -- Output data
        data_o               => data_fifo_input((32 * (i + 1) - 1) downto (32 * i)),
        data_valid_o         => valid_fifo_input(i)
      );

    -------- End of replace downsampler with preprocessing

    --instantiate FIFO
    fifo_inst : fifo_generator_0
    port map(
      rst           => fifo_rst_i,
      wr_clk        => clk_260_mhz,
      rd_clk        => fpga_clk_i,
      din           => data_fifo_input((32 * (i + 1) - 1) downto (32 * i)),
      wr_en         => valid_fifo_input(i),
      rd_en         => fifo_rd_en_i(i),
      dout          => fifo_out_o(i).data_out,
      full          => fifo_full(i),
      overflow      => fifo_overflow(i),
      empty         => fifo_out_o(i).empty,
      rd_data_count => fifo_out_o(i).rd_data_cnt,
      prog_full     => fifo_prog_full(i),
      wr_rst_busy   => fifo_wr_rst_bsy(i),
      rd_rst_busy   => fifo_out_o(i).rd_rst_bsy
    );

    fifo_full_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_full(i),
        level_o    => fifo_out_o(i).full
      );
    fifo_wr_rst_busy_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_wr_rst_bsy(i),
        level_o    => fifo_out_o(i).wr_rst_bsy
      );
    fifo_prog_full_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_prog_full(i),
        level_o    => fifo_out_o(i).prog_full
      );
    fifo_overflow_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_overflow(i),
        level_o    => fifo_out_o(i).overflow
      );

  end generate ADC_data;

end arch; -- arch
