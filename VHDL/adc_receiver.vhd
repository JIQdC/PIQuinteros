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
        RES_ADC:    integer := 14;  --ADC resolution, can take values 14 or 12
        N:          integer := 1;   --number of ADC data channels
        N_tr_b:     integer := 10   --bits for downsampler treshold register        
    );
    port(
        async_rst_i:        in std_logic;

        adc_clk_p_i:        in std_logic;
        adc_clk_n_i:        in std_logic;
        adc_frame_p_i:      in std_logic;
        adc_frame_n_i:      in std_logic;
        adc_data_p_i:       in std_logic_vector((N-1) downto 0);
        adc_data_n_i:       in std_logic_vector((N-1) downto 0);
        adc_clk_div_o:      out std_logic;

        treshold_value_i:   in std_logic_vector((N_tr_b - 1) downto 0);
        treshold_ld_i:      in std_logic;

        debug_control_i:    in std_logic_vector((N*4-1) downto 0);
        debug_w1_i:         in std_logic_vector((14-1) downto 0);
        debug_w2_i:         in std_logic_vector((14-1) downto 0);
        debug_counter_i:    in std_logic_vector((14-1) downto 0);
        debug_counter_ce_o: out std_logic;

        data_o:             out std_logic_vector((14*N-1) downto 0);
        data_valid_o:       out std_logic_vector((N-1) downto 0);

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

    signal clk_to_bufs, clk_to_iddr, clk_to_logic, clk_to_idelayctrl, clk_div: std_logic;
    signal data_to_idelays, data_to_iddr, data_to_des_RE, data_to_des_FE: std_logic_vector((N-1) downto 0);
    signal data_from_deser, data_from_debug, data_from_dwsamp: std_logic_vector((RES_ADC*N-1) downto 0);
    signal valid_from_deser, valid_from_debug, valid_from_dwsamp: std_logic_vector((N-1) downto 0);
    signal frame_to_idelay, frame_to_iddr, frame_delayed: std_logic;
    signal treshold_reg: std_logic_vector((N_tr_b-1) downto 0);
    signal counter_ce: std_logic_vector((N-1) downto 0);
    signal zerosN: std_logic_vector((N-1) downto 0) := (others => '0');

    --Xilinx attributes
    ATTRIBUTE X_INTERFACE_INFO : STRING;
    ATTRIBUTE X_INTERFACE_INFO of adc_clk_p_i: SIGNAL is "xilinx.com:interface:diff_clock:1.0 adc_clk_i CLK_P";
    ATTRIBUTE X_INTERFACE_INFO of adc_clk_n_i: SIGNAL is "xilinx.com:interface:diff_clock:1.0 adc_clk_i CLK_N";
    ATTRIBUTE X_INTERFACE_INFO of adc_clk_div_o: SIGNAL is "xilinx.com:signal:clock:1.0 adc_clk_div_o CLK";
    ATTRIBUTE X_INTERFACE_INFO of delay_clk_i: SIGNAL is "xilinx.com:signal:clock:1.0 delay_clk_i CLK";
    ATTRIBUTE X_INTERFACE_INFO of async_rst_i: SIGNAL is "xilinx.com:signal:reset:1.0 async_rst_i RST";
    ATTRIBUTE X_INTERFACE_INFO of debug_counter_ce_o: SIGNAL is "xilinx.com:signal:clockenable:1.0 debug_counter_ce_o CE";
    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
    ATTRIBUTE X_INTERFACE_PARAMETER of async_rst_i: SIGNAL is "POLARITY ACTIVE_HIGH";
    ATTRIBUTE X_INTERFACE_PARAMETER of adc_clk_div_o: SIGNAL is "FREQ_HZ 65000000";
    ATTRIBUTE X_INTERFACE_PARAMETER of debug_counter_ce_o: SIGNAL is "POLARITY ACTIVE_HIGH";
   
    
    --label must be the same as label in idelay_wrapper.vhd
    attribute IODELAY_GROUP : STRING;
    attribute IODELAY_GROUP of IDELAYCTRL_inst: label is "Reception_Delays";
    
    begin

        ---- DELAY CONTROL
        -- instantiate global buffer for ref clk, and IDELAYCTRL

        -- BUFG: Global Clock Simple Buffer
        --       Kintex-7
        BUFG_inst_IDELAYCTRL : BUFG
        port map (
            O => clk_to_idelayctrl, -- 1-bit output: Clock output
            I => delay_clk_i        -- 1-bit input: Clock input
        );

        -- IDELAYCTRL: IDELAYE2/ODELAYE2 Tap Delay Value Control
        --             Kintex-7
        IDELAYCTRL_inst : IDELAYCTRL
        port map (
            RDY => delay_locked_o,          -- 1-bit output: Ready output
            REFCLK => clk_to_idelayctrl,    -- 1-bit input: Reference clock input
            RST => async_rst_i              -- 1-bit input: Active high reset input
        );

        ---- CLOCK RECEPTION
        
        -- CLK > BUFIO > BUFG

        -- IDDR is driven by BUFIO
        -- BUFG output is used as clock for user logic

        -- IBUFDS: Differential Input Buffer
        --         Kintex-7
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

        -- BUFIO: Local Clock Buffer for I/O
        --        Kintex-7
        BUFIO_inst_clk : BUFIO
        port map (
            O   => clk_to_iddr, -- 1-bit output: Clock output (connect to I/O clock loads).
            I   => clk_to_bufs  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
        );

        -- BUFG: Global Clock Simple Buffer
        --       Kintex-7
        BUFG_inst : BUFG
        port map (
            O => clk_to_logic, -- 1-bit output: Clock output
            I => clk_to_bufs  -- 1-bit input: Clock input
        );

        ---- FRAME

        -- IBUFDS: Differential Input Buffer
        --         Kintex-7
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
        IDDR_inst_frame : IDDR 
        generic map (
            DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                            -- or "SAME_EDGE_PIPELINED" 
            INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
            INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
            SRTYPE => "ASYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
        port map (
            Q1  => open,                -- 1-bit output for positive edge of clock 
            Q2  => frame_delayed,       -- 1-bit output for negative edge of clock
            C   => clk_to_iddr,         -- 1-bit clock input
            CE  => '1',                 -- 1-bit clock enable input
            D   => frame_to_iddr,       -- 1-bit DDR data input
            R   => async_rst_i,         -- 1-bit reset
            S   => '0'                  -- 1-bit set
            );
        
        -- clk_div from frame
        clk_div <= not(frame_delayed);

        ---- TRESHOLD REGISTER FOR DOWNSAMPLER
        tresh_reg_inst: entity work.downsampler_tresh_reg(arch)
        generic map(
            N_tr_b => N_tr_b
        )
        port map(
            d_clk_i         => clk_div,
            rst_i           => async_rst_i,
            treshold_i      => treshold_value_i,
            treshold_ld_i   => treshold_ld_i,
            treshold_reg_o  => treshold_reg
        );

        ---- ADC DATA INPUTS

        -- Generate IBUFDS, IDELAYs, IDDR, deserializer, downsampler for ADC data inputs
        ADC_data: for i in 0 to (N-1) generate

            -- IBUFDS: Differential Input Buffer
            --         Kintex-7
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
            IDDR_inst_data : IDDR 
            generic map (
                DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                                -- or "SAME_EDGE_PIPELINED" 
                INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
                INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
                SRTYPE => "ASYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
            port map (
                Q1  => data_to_des_RE(i),   -- 1-bit output for positive edge of clock 
                Q2  => data_to_des_FE(i),   -- 1-bit output for negative edge of clock
                C   => clk_to_iddr,         -- 1-bit clock input
                CE  => '1',                 -- 1-bit clock enable input
                D   => data_to_iddr(i),     -- 1-bit DDR data input
                R   => async_rst_i,         -- 1-bit reset
                S   => '0'                  -- 1-bit set
                );

            --instantiate deserializer
            deserializer_data: entity work.deserializer(arch)
            generic map(
                RES_ADC => RES_ADC
            )
            port map(
                adc_clk_i   => clk_to_logic,
                rst_i       => async_rst_i,
                data_RE_i   => data_to_des_RE(i),
                data_FE_i   => data_to_des_FE(i),
                frame_i     => frame_delayed,
                data_o      => data_from_deser((14*(i+1)-1) downto (14*i)),
                d_valid_o   => valid_from_deser(i)
            );

            --instantiate debug control
            deb_control_data: entity work.debug_control(arch)
            generic map(
                RES_ADC     => RES_ADC
            )
            port map(
                control_i       => debug_control_i(((4*(i+1))-1) downto (4*i)),
                usr_w1_i        => debug_w1_i,
                usr_w2_i        => debug_w2_i,
                data_i          => data_from_deser((14*(i+1)-1) downto (14*i)),
                valid_i         => valid_from_deser(i),
        
                counter_count_i => debug_counter_i,
                counter_ce_o    => counter_ce(i),
        
                data_o          => data_from_debug((14*(i+1)-1) downto (14*i)),
                valid_o         => valid_from_debug(i)
            );

            --instantiate downsampler
            downsampler_data: entity work.downsampler(arch)
            generic map(
                N_tr_b          => N_tr_b
            )
            port map(
                d_clk_i         => clk_div,
                rst_i           => async_rst_i,
                data_i          => data_from_debug((14*(i+1)-1) downto (14*i)),
                d_valid_i       => valid_from_debug(i),
                treshold_reg_i  => treshold_reg,
                treshold_ld_i   => treshold_ld_i,
                data_o          => data_from_dwsamp((14*(i+1)-1) downto (14*i)),
                d_valid_o       => valid_from_dwsamp(i)
            );

        end generate ADC_data;

        --drive outputs from downsampler
        data_o          <= data_from_dwsamp;
        data_valid_o    <= valid_from_dwsamp;   

        --drive debug_counter_ce_o
        debug_counter_ce_o <=   '1' when (counter_ce > zerosN) else
                                '0';

        --drive adc_clk_div_o
        adc_clk_div_o <= clk_div;
   
end arch; -- arch