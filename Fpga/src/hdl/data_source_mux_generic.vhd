library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
entity data_source_mux_generic is
    generic (
        DATA_WIDTH : integer := 16;
        VEC_LEN : integer := 4
    );
    port (
        sys_clk_i            : in std_logic;
        sys_rst_ni            : in std_logic;
        control_in          : in std_logic_vector(1 downto 0);
        counter_tdata       : in std_logic_vector(DATA_WIDTH * VEC_LEN - 1 downto 0);
        counter_tvalid      : in std_logic_vector(VEC_LEN - 1 downto 0);
        adc_tdata           : in std_logic_vector(DATA_WIDTH * VEC_LEN - 1 downto 0);
        adc_tvalid          : in std_logic_vector(VEC_LEN - 1 downto 0);
        dds_compiler_tdata  : in std_logic_vector(DATA_WIDTH * VEC_LEN - 1 downto 0);
        dds_compiler_tvalid : in std_logic_vector(VEC_LEN - 1 downto 0);
        m_axis_tdata_o        : out std_logic_vector(DATA_WIDTH * VEC_LEN - 1 downto 0);
        m_axis_tvalid_o       : out std_logic_vector(VEC_LEN - 1 downto 0)
    );
end data_source_mux_generic;

architecture Behavioral of data_source_mux_generic is
begin
process (sys_clk_i, sys_rst_ni)
begin
    if (sys_rst_ni = '0') then
        m_axis_tdata_o <= (others => '0');
        m_axis_tvalid_o <= (others => '0');
    elsif rising_edge(sys_clk_i) then
        m_axis_tvalid_o <= (others => '0');

        case control_in is
            when "00" =>
                m_axis_tdata_o <= adc_tdata;
                m_axis_tvalid_o <= adc_tvalid;
            when "01" =>
                m_axis_tdata_o <= dds_compiler_tdata;
                m_axis_tvalid_o <= dds_compiler_tvalid;
            when "10" =>
                m_axis_tdata_o <= counter_tdata;
                m_axis_tvalid_o <= counter_tvalid;
            when others =>
                m_axis_tvalid_o <= (others => '0');
        end case;
    end if;
end process;
end Behavioral;
