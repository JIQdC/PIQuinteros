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
-- Revision: 2020-09-29
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity adc_receiver is
    generic(
        RES_ADC:    integer := 14;          --ADC resolution, can take values 14 or 12
        N:          integer := 1            --number of ADC data channels
    );
    port(
        async_rst_i:        in std_logic;

        adc_clk_p_i:        in std_logic;
        adc_clk_n_i:        in std_logic;
        adc_frame_p_i:      in std_logic;
        adc_frame_n_i:      in std_logic;
        adc_data_p_i:       in std_logic_vector((N-1) downto 0);
        adc_data_n_i:       in std_logic_vector((N-1) downto 0);

        adc_clk_o:          out std_logic;
        adc_frame_o:        out std_logic;
        adc_data_REb_o:     out std_logic_vector((N-1) downto 0);
        adc_data_FEb_o:     out std_logic_vector((N-1) downto 0);

        delay_clk_i:            in std_logic;
        delay_locked_o:         out std_logic;
        delay_data_ld_i:        in std_logic_vector((N-1) downto 0);
        delay_data_input_i:     in std_logic_vector((5*N-1) downto 0);
        delay_data_output_o:    out std_logic_vector((5*N-1) downto 0);
        delay_frame_ld_i:       in std_logic;
        delay_frame_input_i:    in std_logic_vector((5-1) downto 0);
        delay_frame_output_o:   out std_logic_vector((5-1) downto 0)

    );
end adc_receiver;

architecture arch of adc_receiver is

    signal clk_to_bufs, clk_to_iddr, clk_to_idelayctrl: std_logic;
    signal data_to_idelays, data_to_iddr: std_logic_vector((N-1) downto 0);
    signal frame_to_idelay, frame_to_iddr: std_logic;

    --Xilinx attributes
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of adc_clk_p_i: SIGNAL is "xilinx.com:interface:diff_clock:1.0 adc_clk_i CLK_P";
    ATTRIBUTE X_INTERFACE_INFO of adc_clk_n_i: SIGNAL is "xilinx.com:interface:diff_clock:1.0 adc_clk_i CLK_N";
    ATTRIBUTE X_INTERFACE_INFO of adc_clk_o: SIGNAL is "xilinx.com:signal:clock:1.0 adc_clk_o CLK";
    ATTRIBUTE X_INTERFACE_INFO of delay_clk_i: SIGNAL is "xilinx.com:signal:clock:1.0 delay_clk_i CLK";
    ATTRIBUTE X_INTERFACE_INFO of async_rst_i: SIGNAL is "xilinx.com:signal:reset:1.0 async_rst_i RST";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of async_rst_i: SIGNAL is "POLARITY ACTIVE_HIGH";
    ATTRIBUTE X_INTERFACE_PARAMETER of adc_clk_o: SIGNAL is "FREQ_HZ 455000000";
  
    --label must be the same as label in idelay_wrapper.vhd
    attribute IODELAY_GROUP : STRING;
    attribute IODELAY_GROUP of IDELAYE2_inst_frame: label is "Reception_Delays";
    attribute IODELAY_GROUP of IDELAYCTRL_inst: label is "Reception_Delays";
    
    begin
        -- ADC DATA INPUTS

        -- Generate IBUFDS, IDELAYs and IDDR for ADC data inputs
        ADC_data: for i in 0 to (N-1) generate

            -- IBUFDS: Differential Input Buffer
            --         Kintex-7
            -- Xilinx HDL Language Template, version 2019.1

            IBUFDS_inst_data : IBUFDS
            generic map (
                DIFF_TERM => FALSE, -- Differential Termination 
                IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
                IOSTANDARD => "LVDS_25")
            port map (
                O   => data_to_idelays(i),  -- Buffer output
                I   => adc_data_p_i(i),     -- Diff_p buffer input (connect directly to top-level port)
                IB  => adc_data_n_i(i)      -- Diff_n buffer input (connect directly to top-level port)
            );

            -- End of IBUFDS_inst instantiation

            -- IDELAY: instantiate idelay_wrapper
            IDELAYE2_inst_data: entity work.idelay_wrapper(arch)
            port map(
                async_rst_i => async_rst_i,
                data_i      => data_to_idelays(i),
                data_o      => data_to_iddr(i),
                clk_i       => delay_clk_i,
                ld_i        => delay_data_ld_i(i),
                input_i     => delay_data_input_i((i+(5-1)) downto i),
                output_o    => delay_data_output_o((i+(5-1)) downto i)
            );

            -- IDDR: Double Data Rate Input Register with Set, Reset
            --       and Clock Enable. 
            --       Kintex-7
            -- Xilinx HDL Language Template, version 2019.1

            IDDR_inst_data : IDDR 
            generic map (
                DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                                -- or "SAME_EDGE_PIPELINED" 
                INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
                INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
                SRTYPE => "ASYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
            port map (
                Q1  => adc_data_REb_o(i),   -- 1-bit output for positive edge of clock 
                Q2  => adc_data_FEb_o(i),   -- 1-bit output for negative edge of clock
                C   => clk_to_iddr,         -- 1-bit clock input
                CE  => '1',                 -- 1-bit clock enable input
                D   => data_to_iddr(i),     -- 1-bit DDR data input
                R   => async_rst_i,         -- 1-bit reset
                S   => '0'                  -- 1-bit set
                );

            -- End of IDDR_inst instantiation

        end generate ADC_data;

        -- BUFG: Global Clock Simple Buffer
        --       Kintex-7
        -- Xilinx HDL Language Template, version 2019.1

        BUFG_inst_IDELAYCTRL : BUFG
        port map (
            O => clk_to_idelayctrl, -- 1-bit output: Clock output
            I => delay_clk_i        -- 1-bit input: Clock input
        );

        -- End of BUFG_inst instantiation

        -- IDELAYCTRL: IDELAYE2/ODELAYE2 Tap Delay Value Control
        --             Kintex-7
        -- Xilinx HDL Language Template, version 2019.1

        IDELAYCTRL_inst : IDELAYCTRL
        port map (
            RDY => delay_locked_o,          -- 1-bit output: Ready output
            REFCLK => clk_to_idelayctrl,    -- 1-bit input: Reference clock input
            RST => async_rst_i              -- 1-bit input: Active high reset input
        );

        -- End of IDELAYCTRL_inst instantiation

        -- CLOCK RECEPTION
        
        -- CLK > BUFIO > BUFR
        -- IDDR is driven by BUFIO
        -- BUFR output is used as clock for user logic

        -- IBUFDS: Differential Input Buffer
        --         Kintex-7
        -- Xilinx HDL Language Template, version 2019.1

        IBUFDS_inst_clk : IBUFDS
        generic map (
            DIFF_TERM => FALSE, -- Differential Termination 
            IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD => "LVDS_25")
        port map (
            O   => clk_to_bufs,     -- Buffer output
            I   => adc_clk_p_i,     -- Diff_p buffer input (connect directly to top-level port)
            IB  => adc_clk_n_i      -- Diff_n buffer input (connect directly to top-level port)
        );

        -- End of IBUFDS_inst instantiation

        -- BUFIO: Local Clock Buffer for I/O
        --        Kintex-7
        -- Xilinx HDL Language Template, version 2019.1

        BUFIO_inst_clk : BUFIO
        port map (
            O   => clk_to_iddr, -- 1-bit output: Clock output (connect to I/O clock loads).
            I   => clk_to_bufs  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
        );

        -- End of BUFIO_inst instantiation

        -- -- BUFR: Regional Clock Buffer for I/O and Logic Resources within a Clock Region
        -- --       Kintex-7
        -- -- Xilinx HDL Language Template, version 2019.1

        -- BUFR_inst_clk : BUFR
        -- generic map (
        --     BUFR_DIVIDE => "BYPASS",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
        --     SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
        -- )
        -- port map (
        --     O   => adc_clk_o,   -- 1-bit output: Clock output port
        --     CE  => '1',         -- 1-bit input: Active high, clock enable (Divided modes only)
        --     CLR => '0',         -- 1-bit input: Active high, asynchronous clear (Divided modes only)
        --     I   => clk_to_bufs  -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
        -- );

        -- -- End of BUFR_inst instantiation

        -- BUFG: Global Clock Simple Buffer
        --       Kintex-7
        -- Xilinx HDL Language Template, version 2019.1

        BUFG_inst : BUFG
        port map (
            O => adc_clk_o, -- 1-bit output: Clock output
            I => clk_to_bufs  -- 1-bit input: Clock input
        );

        -- End of BUFG_inst instantiation


        -- FRAME
        -- IBUFDS: Differential Input Buffer
        --         Kintex-7
        -- Xilinx HDL Language Template, version 2019.1

        IBUFDS_inst_frame : IBUFDS
        generic map (
            DIFF_TERM => FALSE, -- Differential Termination 
            IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD => "LVDS_25")
        port map (
            O   => frame_to_idelay,   -- Buffer output
            I   => adc_frame_p_i,     -- Diff_p buffer input (connect directly to top-level port)
            IB  => adc_frame_n_i      -- Diff_n buffer input (connect directly to top-level port)
        );

        -- End of IBUFDS_inst instantiation

        -- IDELAY: instantiate idelay_wrapper
        IDELAYE2_inst_frame: entity work.idelay_wrapper(arch)
        port map(
            async_rst_i => async_rst_i,
            data_i      => frame_to_idelay,
            data_o      => frame_to_iddr,
            clk_i       => delay_clk_i,
            ld_i        => delay_frame_ld_i,
            input_i     => delay_frame_input_i,
            output_o    => delay_frame_output_o
        );

        -- IDDR: Double Data Rate Input Register with Set, Reset
        --       and Clock Enable. 
        --       Kintex-7
        -- Xilinx HDL Language Template, version 2019.1

        IDDR_inst_frame : IDDR 
        generic map (
            DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                            -- or "SAME_EDGE_PIPELINED" 
            INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
            INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
            SRTYPE => "ASYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
        port map (
            Q1  => open,                -- 1-bit output for positive edge of clock 
            Q2  => adc_frame_o,         -- 1-bit output for negative edge of clock
            C   => clk_to_iddr,         -- 1-bit clock input
            CE  => '1',                 -- 1-bit clock enable input
            D   => frame_to_iddr,       -- 1-bit DDR data input
            R   => async_rst_i,         -- 1-bit reset
            S   => '0'                  -- 1-bit set
            );

        -- End of IDDR_inst instantiation        

        
   
end arch; -- arch