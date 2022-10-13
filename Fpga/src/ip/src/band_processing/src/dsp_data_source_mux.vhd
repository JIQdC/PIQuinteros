library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity dsp_data_source_mux is
    port (
        counter_tdata       : in std_logic_vector(15 downto 0);
        counter_tvalid      : in std_logic;
        adc_tdata           : in std_logic_vector(15 downto 0);
        adc_tvalid          : in std_logic;
        dds_compiler_tdata  : in std_logic_vector(15 downto 0);
        dds_compiler_tvalid : in std_logic;
        control_in          : in std_logic_vector(1 downto 0);
        m_axis_tdata        : out std_logic_vector(15 downto 0);
        m_axis_tvalid       : out std_logic
    );
end dsp_data_source_mux;

architecture Behavioral of dsp_data_source_mux is
begin
    with control_in select m_axis_tdata <=
        adc_tdata when "00",
        dds_compiler_tdata when "01",
        counter_tdata when "10",
        (others => '0') when others;

    with control_in select m_axis_tvalid <=
        adc_tvalid when "00",
        dds_compiler_tvalid when "01",
        counter_tvalid when "10",
        '0' when others;
end Behavioral;
