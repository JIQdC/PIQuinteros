library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_handler is
  generic (
    RES_ADC : integer := 14; --ADC resolution, can take values 14 or 12
    N1      : integer := 1;  --number of first instance data channels
    N2      : integer := 1   --number of second instance data channels
  );
  port (
    sys_clk_i              : in std_logic;
    async_rst_i            : in std_logic;
    fpga_clk_i             : in std_logic;

    --data input
    data_adc_1_i           : in std_logic_vector(RES_ADC * N1 - 1 downto 0);
    valid_adc_1_i          : in std_logic_vector(N1 - 1 downto 0);
    data_adc_2_i           : in std_logic_vector(RES_ADC * N2 - 1 downto 0);
    valid_adc_2_i          : in std_logic_vector(N2 - 1 downto 0);
    --preprocessing signals
    fifo_input_mux_sel_i   : in std_logic_vector(2 downto 0);
    data_source_sel_i      : in std_logic_vector(1 downto 0);
    ch_1_freq_i            : in std_logic_vector(31 downto 0);
    ch_1_freq_valid_i      : in std_logic;
    ch_2_freq_i            : in std_logic_vector(31 downto 0);
    ch_2_freq_valid_i      : in std_logic;
    ch_3_freq_i            : in std_logic_vector(31 downto 0);
    ch_3_freq_valid_i      : in std_logic;
    ch_4_freq_i            : in std_logic_vector(31 downto 0);
    ch_4_freq_valid_i      : in std_logic;
    local_osc_freq_i       : in std_logic_vector(31 downto 0);
    local_osc_freq_valid_i : in std_logic;
    --output
    data_1_o               : out std_logic_vector(32 * N1 - 1 downto 0);
    valid_1_o              : out std_logic_vector(N1 - 1 downto 0);
    data_2_o               : out std_logic_vector(32 * N2 - 1 downto 0);
    valid_2_o              : out std_logic_vector(N2 - 1 downto 0)
  );
end data_handler;

architecture arch of data_handler is

  --component declarations

  --signals
  signal data_both_adc : std_logic_vector(RES_ADC * (N1 + N2) - 1 downto 0);
  signal valid_both_adc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_joined_output : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_joined_output : std_logic_vector(N1 + N2 - 1 downto 0);

  --sync signals
  signal fifo_input_mux_sel_sync : std_logic_vector(2 downto 0);
  signal data_source_sel_sync : std_logic_vector(1 downto 0);
  signal ch_1_freq_sync : std_logic_vector(31 downto 0);
  signal ch_1_freq_valid_sync : std_logic;
  signal ch_2_freq_sync : std_logic_vector(31 downto 0);
  signal ch_2_freq_valid_sync : std_logic;
  signal ch_3_freq_sync : std_logic_vector(31 downto 0);
  signal ch_3_freq_valid_sync : std_logic;
  signal ch_4_freq_sync : std_logic_vector(31 downto 0);
  signal ch_4_freq_valid_sync : std_logic;
  signal local_osc_freq_sync : std_logic_vector(31 downto 0);
  signal local_osc_freq_valid_sync : std_logic;

  --signals from preproc
  signal data_ch_filter_from_preproc : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_ch_filter_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_mux_data_source_from_preproc : std_logic_vector(16 * (N1 + N2) - 1 downto 0);
  signal valid_mux_data_source_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_band_mixer_from_preproc : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_band_mixer_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_band_filter_from_preproc : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_band_filter_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_channel_mixer_from_preproc : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_channel_mixer_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
begin
  --compoenent instantiations
  --Concatenate and split data
  adc_data_concatenator_inst : entity work.concatenator(Behavioral)
    generic map(
      DATA_WIDTH_1 => RES_ADC * N1,
      DATA_WIDTH_2 => RES_ADC * N2
    )
    port map(
      sys_clk_i => sys_clk_i,
      sys_rst_i => async_rst_i,
      data_1_i  => data_adc_1_i,
      data_2_i  => data_adc_2_i,
      data_o    => data_both_adc
    );

  adc_valid_concatenator_inst : entity work.concatenator(Behavioral)
    generic map(
      DATA_WIDTH_1 => N1,
      DATA_WIDTH_2 => N2
    )
    port map(
      sys_clk_i => sys_clk_i,
      sys_rst_i => async_rst_i,
      data_1_i  => valid_adc_1_i,
      data_2_i  => valid_adc_2_i,
      data_o    => valid_both_adc
    );
  --End concatenate and split data

  --Begin signals sync

  fifo_input_mux_sel_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => 3
    )
    port map(
      src_data_i  => fifo_input_mux_sel_i,
      sys_clk_i   => sys_clk_i,
      sync_data_o => fifo_input_mux_sel_sync
    );

  data_source_sel_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => 2
    )
    port map(
      src_data_i  => data_source_sel_i,
      sys_clk_i   => sys_clk_i,
      sync_data_o => data_source_sel_sync
    );

  ch_1_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
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
      DATA_WIDTH => 32
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
      DATA_WIDTH => 32
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
      DATA_WIDTH => 32
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
  local_osc_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => local_osc_freq_i,
      src_valid_i => local_osc_freq_valid_i,
      dst_clk_i   => clk_260_mhz,
      dst_data_o  => local_osc_freq_sync,
      dst_valid_o => local_osc_freq_valid_sync
    );
  --End sgnals sync

  preprocessing_inst : entity work.preprocessing(arch)
    generic map(
      RES_ADC      => RES_ADC,
      NUM_CHANNELS => N1 + N2
    )
    port map(
      sys_clk_i               => sys_clk_i,
      async_rst_i             => async_rst_i,
      data_adc_i              => data_both_adc,
      valid_adc_i             => valid_both_adc,
      data_source_sel_i       => data_source_sel_sync,
      ch_1_freq_i             => ch_1_freq_sync,
      ch_1_freq_valid_i       => ch_1_freq_valid_sync,
      ch_2_freq_i             => ch_2_freq_sync,
      ch_2_freq_valid_i       => ch_2_freq_valid_sync,
      ch_3_freq_i             => ch_3_freq_sync,
      ch_3_freq_valid_i       => ch_3_freq_valid_sync,
      ch_4_freq_i             => ch_4_freq_sync,
      ch_4_freq_valid_i       => ch_4_freq_valid_sync,
      local_osc_freq_i        => local_osc_freq_sync,
      local_osc_freq_valid_i  => local_osc_freq_valid_sync,
      data_ch_filter_o        => data_ch_filter_from_preproc,
      valid_ch_filter_o       => valid_ch_filter_from_preproc,
      data_mux_data_source_o  => data_mux_data_source_from_preproc,
      valid_mux_data_source_o => valid_mux_data_source_from_preproc,
      data_band_mixer_o       => data_band_mixer_from_preproc,
      valid_band_mixer_o      => valid_band_mixer_from_preproc,
      data_band_filter_o      => data_band_filter_from_preproc,
      valid_band_filter_o     => valid_band_filter_from_preproc,
      data_channel_mixer_o    => data_channel_mixer_from_preproc,
      valid_channel_mixer_o   => valid_channel_mixer_from_preproc
    );
  --Change Mux to take the whole vector and remove debug counter postproc
  fifo_input_mux_inst : entity work.fifo_input_data_mux
    generic map(
      NUM_CHANNELS => N1 + N2,
      RES_ADC      => RES_ADC
    )
    port map(
      sys_clk_i                    => sys_clk_i,
      sys_rst_i                    => async_rst_i,
      -- Mux control
      data_mux_sel_i               => fifo_input_mux_sel_sync,
      -- Data from preprocessing logic
      data_preproc_i               => data_ch_filter_from_preproc,
      data_preproc_valid_i         => valid_ch_filter_from_preproc,
      -- Raw data from deserializer
      data_raw_i                   => data_both_adc,
      data_raw_valid_i             => valid_both_adc,
      -- Data source mux
      data_mux_data_source_i       => data_mux_data_source_from_preproc,
      data_mux_data_source_valid_i => valid_mux_data_source_from_preproc,
      -- Band mixer
      data_band_mixer_i            => data_band_mixer_from_preproc,
      data_band_mixer_valid_i      => valid_band_mixer_from_preproc,
      -- Band filter
      data_band_filter_i           => data_band_filter_from_preproc,
      data_band_filter_valid_i     => valid_band_filter_from_preproc,
      -- Channel mixer
      data_channel_mixer_i         => data_channel_mixer_from_preproc,
      data_channel_mixer_valid_i   => valid_channel_mixer_from_preproc,
      -- Output data
      data_o                       => data_joined_output,
      data_valid_o                 => valid_joined_output
    );

  data_output_splitter_inst : entity work.splitter(Behavioral)
    generic map(
      DATA_WIDTH_1 => 32 * N1,
      DATA_WIDTH_2 => 32 * N2
    )
    port map(
      sys_clk_i => sys_clk_i,
      sys_rst_i => async_rst_i,
      data_i    => data_joined_output,
      data_1_o  => data_1_o,
      data_2_o  => data_2_o
    );

  valid_output_splitter_inst : entity work.splitter(Behavioral)
    generic map(
      DATA_WIDTH_1 => N1,
      DATA_WIDTH_2 => N2
    )
    port map(
      sys_clk_i => sys_clk_i,
      sys_rst_i => async_rst_i,
      data_i    => valid_joined_output,
      data_1_o  => valid_1_o,
      data_2_o  => valid_2_o
    );
end arch;
