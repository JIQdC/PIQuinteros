library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity preprocessing is
  generic (
    RES_ADC      : integer := 14;
    NUM_CHANNELS : integer := 16
  );
  port (
    sys_clk_i               : in std_logic;
    async_rst_i             : in std_logic;
    data_adc_i              : in std_logic_vector(RES_ADC * NUM_CHANNELS - 1 downto 0);
    valid_adc_i             : in std_logic_vector(NUM_CHANNELS - 1 downto 0);

    --preprocessing signals
    data_source_sel_i       : in std_logic_vector(1 downto 0);
    ch_1_freq_i             : in std_logic_vector(31 downto 0);
    ch_1_freq_valid_i       : in std_logic;
    ch_2_freq_i             : in std_logic_vector(31 downto 0);
    ch_2_freq_valid_i       : in std_logic;
    ch_3_freq_i             : in std_logic_vector(31 downto 0);
    ch_3_freq_valid_i       : in std_logic;
    ch_4_freq_i             : in std_logic_vector(31 downto 0);
    ch_4_freq_valid_i       : in std_logic;
    local_osc_freq_i        : in std_logic_vector(31 downto 0);
    local_osc_freq_valid_i  : in std_logic;

    --output signals
    data_ch_filter_o        : out std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    valid_ch_filter_o       : out std_logic_vector(NUM_CHANNELS - 1 downto 0);
    data_mux_data_source_o  : out std_logic_vector(16 * NUM_CHANNELS - 1 downto 0);
    valid_mux_data_source_o : out std_logic_vector(NUM_CHANNELS - 1 downto 0);
    data_band_mixer_o       : out std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    valid_band_mixer_o      : out std_logic_vector(NUM_CHANNELS - 1 downto 0);
    data_band_filter_o      : out std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    valid_band_filter_o     : out std_logic_vector(NUM_CHANNELS - 1 downto 0);
    data_channel_mixer_o    : out std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    valid_channel_mixer_o   : out std_logic_vector(NUM_CHANNELS - 1 downto 0)
  );
end preprocessing;
architecture arch of preprocessing is

begin
  --resize adc input to 16 bits

end architecture arch;
