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
    delay_frame_output_o : out std_logic_vector((5 - 1) downto 0)
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

  -- component frame_clk_wiz_0
  --   port (
  --     clk_in1        : in std_logic;
  --     clk_to_counter : out std_logic;
  --     clk_to_preproc : out std_logic;
  --     clk_to_debug   : out std_logic;
  --     fifo_wr_clk    : out std_logic;
  --     locked         : out std_logic;
  --     reset          : in std_logic
  --   );
  -- end component;

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
  component fifo_generator_0
    port (
      rst           : in std_logic;
      wr_clk        : in std_logic;
      rd_clk        : in std_logic;
      din           : in std_logic_vector(15 downto 0);
      wr_en         : in std_logic;
      rd_en         : in std_logic;
      dout          : out std_logic_vector(31 downto 0);
      full          : out std_logic;
      overflow      : out std_logic;
      empty         : out std_logic;
      rd_data_count : out std_logic_vector(11 downto 0);
      prog_full     : out std_logic;
      wr_rst_busy   : out std_logic;
      rd_rst_busy   : out std_logic
    );
  end component;

  signal clk_to_bufs, clk_to_iddr, clk_to_logic, clk_div,
  clk_to_preproc, clk_to_counter, fifo_wr_clk, clk_to_debug            : std_logic;
  signal data_to_idelays, data_to_iddr, data_to_des_RE, data_to_des_FE : std_logic_vector((N - 1) downto 0);
  signal data_from_deser, data_from_debug                              : std_logic_vector((RES_ADC * N - 1) downto 0);
  signal data_from_dwsamp                                              : std_logic_vector(16 * N - 1 downto 0);
  signal valid_from_deser, valid_from_debug, valid_from_dwsamp         : std_logic_vector((N - 1) downto 0);
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

 clk_to_preproc <= clk_div;
 clk_to_debug <= clk_div;
 clk_to_counter <= clk_div;
 fifo_wr_clk <= clk_div;

  ---- TRESHOLD REGISTER FOR DOWNSAMPLER
  tresh_reg_inst : entity work.downsampler_tresh_reg(arch)
    generic map(
      N_tr_b => N_tr_b
    )
    port map(
      d_clk_i        => clk_to_preproc,
      rst_i          => async_rst_i,
      treshold_i     => treshold_value_i,
      treshold_ld_i  => treshold_ld_i,
      treshold_reg_o => treshold_reg
    );

  ---- ADC DATA INPUTS

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

    --instantiate downsampler
    downsampler_data : entity work.downsampler(arch)
      generic map(
        N_tr_b => N_tr_b
      )
      port map(
        d_clk_i        => clk_to_preproc,
        rst_i          => async_rst_i,
        data_i         => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
        d_valid_i      => valid_from_debug(i),
        treshold_reg_i => treshold_reg,
        treshold_ld_i  => treshold_ld_i,
        data_o         => data_from_dwsamp((16 * (i + 1) - 1) downto (16 * i)),
        d_valid_o      => valid_from_dwsamp(i)
      );

    --instantiate FIFO
    fifo_inst : fifo_generator_0
    port map(
      rst           => fifo_rst_i,
      wr_clk        => fifo_wr_clk,
      rd_clk        => fpga_clk_i,
      din           => data_from_dwsamp((16 * (i + 1) - 1) downto (16 * i)),
      wr_en         => valid_from_dwsamp(i),
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