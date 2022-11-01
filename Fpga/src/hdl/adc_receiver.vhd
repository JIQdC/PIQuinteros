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

    -- debug_enable_i       : in std_logic;
    -- debug_control_i      : in std_logic_vector((N * 4 - 1) downto 0);
    -- debug_w2w1_i         : in std_logic_vector((28 * N - 1) downto 0);

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

    --input
    data_fifo_input_i    : in std_logic_vector(32 * N - 1 downto 0);
    valid_fifo_input_i   : in std_logic;
    --output
    clk_260_mhz_o        : out std_logic;
    clk_455_mhz_o        : out std_logic;
    data_adc_o           : out std_logic_vector((N * RES_ADC - 1) downto 0);
    valid_adc_o          : out std_logic
  );
end adc_receiver;

architecture arch of adc_receiver is

  --Binary counter declaration
  -- component c_counter_binary
  --   port (
  --     CLK  : in std_logic;
  --     CE   : in std_logic;
  --     SCLR : in std_logic;
  --     Q    : out std_logic_vector(13 downto 0)
  --   );
  -- end component;

  component clk_wiz_preproc
    port (-- Clock in ports
      -- Clock out ports
      clk_out1 : out std_logic;
      -- Status and control signals
      reset    : in std_logic;
      locked   : out std_logic;
      clk_in1  : in std_logic
    );
  end component;

  --FIFO generator declaration
  component fifo_generator
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

  --End preprocessing components
  signal clk_to_bufs, clk_to_iddr, clk_to_logic, clk_260_mhz : std_logic;
  signal data_to_idelays, data_to_iddr : std_logic_vector((N - 1) downto 0);

  signal data_from_IDDR_RE, data_from_IDDR_FE : std_logic_vector((N - 1) downto 0);
  signal data_to_des_RE, data_to_des_FE : std_logic_vector((N - 1) downto 0);
  signal data_from_deser, data_from_debug : std_logic_vector((RES_ADC * N - 1) downto 0);
  signal valid_from_deser, valid_from_debug : std_logic_vector((N - 1) downto 0);

  --End to be removed
  --Band and channel processing signals

  signal data_fifo_input_sync : std_logic_vector(32 * N - 1 downto 0);
  signal valid_fifo_input_sync : std_logic_vector(0 downto 0);

  signal frame_to_idelay, frame_to_iddr : std_logic;
  signal frame_delayed_from_iddr, frame_delayed_to_deser : std_logic;

  -- signal counter_ce_v : std_logic_vector((N - 1) downto 0);
  -- signal debug_counter : std_logic_vector(13 downto 0);
  -- signal debug_counter_ce : std_logic;
  -- signal zerosN : std_logic_vector((N - 1) downto 0) := (others => '0');

  signal valid_from_pulse_sync : std_logic_vector((N - 1) downto 0);

  signal data_from_deser_slow : std_logic_vector(16 * N - 1 downto 0);
  signal valid_from_deser_slow : std_logic_vector((N - 1) downto 0);

  -- synchronize signals from write_side of FIFO
  signal fifo_full : std_logic_vector((N - 1) downto 0);
  signal fifo_wr_rst_bsy : std_logic_vector((N - 1) downto 0);
  signal fifo_prog_full : std_logic_vector((N - 1) downto 0);
  signal fifo_overflow : std_logic_vector((N - 1) downto 0);

  -- synchronize signals from debug control
  -- signal debug_enable_sync : std_logic;
  -- signal debug_control_sync : std_logic_vector((N * 4 - 1) downto 0);
  -- constant debug_control_width : integer := (N * 4);
  -- signal debug_w2w1_sync : std_logic_vector((28 * N - 1) downto 0);
  -- constant debug_w2w1_width : integer := (28 * N);
  signal async_rst_n : std_logic;
  signal valid_fifo_input_as_vector : std_logic_vector(0 downto 0);
begin
  async_rst_n <= not(async_rst_i);
  valid_fifo_input_as_vector(0) <= valid_fifo_input_i;
  -- -- Instantiate synchronizers for debug signals
  -- debug_control_sync_inst : entity work.quasistatic_sync
  --   generic map(
  --     DATA_WIDTH => debug_control_width
  --   )
  --   port map(
  --     src_data_i  => debug_control_i,
  --     sys_clk_i   => clk_260_mhz,
  --     sync_data_o => debug_control_sync
  --   );

  -- debug_w2w1_sync_inst : entity work.quasistatic_sync
  --   generic map(
  --     DATA_WIDTH => debug_w2w1_width
  --   )
  --   port map(
  --     src_data_i  => debug_w2w1_i,
  --     sys_clk_i   => clk_260_mhz,
  --     sync_data_o => debug_w2w1_sync
  --   );

  -- debug_enable_sync_inst : entity work.level_sync
  --   port map(
  --     dest_clk_i => clk_260_mhz,
  --     dest_rst_i => async_rst_i,
  --     level_i    => debug_enable_i,
  --     level_o    => debug_enable_sync
  --   );

  -- ---- BINARY COUNTER
  -- -- instantiate binary counter for debugging purposes
  -- binary_counter : c_counter_binary
  -- port map(
  --   CLK  => clk_260_mhz,
  --   CE   => debug_counter_ce,
  --   SCLR => async_rst_i,
  --   Q    => debug_counter
  -- );
  -- --drive debug_counter_ce
  -- debug_counter_ce <= '1' when (counter_ce_v > zerosN) else
  -- '0';

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
    Q1 => open,                    -- 1-bit output for positive edge of clock
    Q2 => frame_delayed_from_iddr, -- 1-bit output for negative edge of clock
    C  => clk_to_iddr,             -- 1-bit clock input
    CE => '1',                     -- 1-bit clock enable input
    D  => frame_to_iddr,           -- 1-bit DDR data input
    R  => async_rst_i,             -- 1-bit reset
    S  => '0'                      -- 1-bit set
  );

  clk_wiz_preproc_inst : clk_wiz_preproc
  port map(
    -- Clock out ports
    clk_out1 => clk_260_mhz,
    -- Status and control signals
    reset    => async_rst_i,
    locked   => adc_FCOlck_o,
    -- Clock in ports
    clk_in1  => clk_to_logic
  );
  ---- ADC DATA INPUTS

  --process to register data_from_IDDR_FE to data_to_deserializer
  process (clk_to_logic)
  begin
    if rising_edge(clk_to_logic) then
      frame_delayed_to_deser <= frame_delayed_from_iddr;
      data_to_des_RE <= data_from_IDDR_RE;
      data_to_des_FE <= data_from_IDDR_FE;
    end if;
  end process;

  data_fifo_input_sync_inst : entity work.cdc_two_ff_sync(rtl)
    generic map(
      SIZE => 32 * N
    )
    port map(
      clk_i    => clk_260_mhz,
      rst_ni   => async_rst_n,
      data_in  => data_fifo_input_i,
      data_out => data_fifo_input_sync
    );

  valid_fifo_input_sync_inst : entity work.cdc_two_ff_sync(rtl)
    generic map(
      SIZE => 1
    )
    port map(
      clk_i    => clk_260_mhz,
      rst_ni   => async_rst_n,
      data_in  => valid_fifo_input_as_vector,
      data_out => valid_fifo_input_sync
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
      Q1 => data_from_IDDR_RE(i), -- 1-bit output for positive edge of clock
      Q2 => data_from_IDDR_FE(i), -- 1-bit output for negative edge of clock
      C  => clk_to_iddr,          -- 1-bit clock input
      CE => '1',                  -- 1-bit clock enable input
      D  => data_to_iddr(i),      -- 1-bit DDR data input
      R  => async_rst_i,          -- 1-bit reset
      S  => '0'                   -- 1-bit set
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
        frame_i   => frame_delayed_to_deser,
        data_o    => data_from_deser((14 * (i + 1) - 1) downto (14 * i)),
        d_valid_o => valid_from_deser(i)
      );

    --instantiate debug control
    -- deb_control_data : entity work.debug_control(arch)
    --   generic map(
    --     RES_ADC => RES_ADC
    --   )
    --   port map(
    --     clock_i         => clk_260_mhz,
    --     rst_i           => async_rst_i,
    --     enable_i        => debug_enable_sync,
    --     control_i       => debug_control_sync(((4 * (i + 1)) - 1) downto (4 * i)),
    --     usr_w2w1_i      => debug_w2w1_sync(((28 * (i + 1)) - 1) downto (28 * i)),
    --     --data_i     => data_from_deser((14 * (i + 1) - 1) downto (14 * i)),
    --     data_i          => data_from_deser_slow((14 * (i + 1) - 1) downto (14 * i)),
    --     --valid_i    => valid_from_deser(i),
    --     valid_i         => valid_from_deser_slow(i),

    --     counter_count_i => debug_counter,
    --     counter_ce_o    => counter_ce_v(i),

    --     data_o          => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
    --     valid_o         => valid_from_debug(i)
    --   );

    --instantiate FIFO
    fifo_inst : fifo_generator
    port map(
      rst           => fifo_rst_i,
      wr_clk        => clk_260_mhz,
      rd_clk        => fpga_clk_i,
      din           => data_fifo_input_sync((32 * (i + 1) - 1) downto (32 * i)),
      wr_en         => valid_fifo_input_sync(0),
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

  clk_260_mhz_o <= clk_260_mhz;
  clk_455_mhz_o <= clk_to_logic;
  data_adc_o <= data_from_deser;
  valid_adc_o <= valid_from_deser(0);
end arch; -- arch
