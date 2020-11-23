proc getPresetInfo {} {
  return [dict create name {ZYNQ_minimum_config_CIAA} description {ZYNQ_minimum_config_CIAA}  vlnv xilinx.com:ip:processing_system7:5.5 display_name {ZYNQ_minimum_config_CIAA} ]
}

proc validate_preset {IPINST} { return true }


proc apply_preset {IPINST} {
  return [dict create \
    CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000}  \
    CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF}  \
    CONFIG.PCW_UART0_BASEADDR {0xE0000000}  \
    CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF}  \
    CONFIG.PCW_UART1_BASEADDR {0xE0001000}  \
    CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF}  \
    CONFIG.PCW_I2C0_BASEADDR {0xE0004000}  \
    CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF}  \
    CONFIG.PCW_I2C1_BASEADDR {0xE0005000}  \
    CONFIG.PCW_I2C1_HIGHADDR {0xE0005FFF}  \
    CONFIG.PCW_SPI0_BASEADDR {0xE0006000}  \
    CONFIG.PCW_SPI0_HIGHADDR {0xE0006FFF}  \
    CONFIG.PCW_SPI1_BASEADDR {0xE0007000}  \
    CONFIG.PCW_SPI1_HIGHADDR {0xE0007FFF}  \
    CONFIG.PCW_CAN0_BASEADDR {0xE0008000}  \
    CONFIG.PCW_CAN0_HIGHADDR {0xE0008FFF}  \
    CONFIG.PCW_CAN1_BASEADDR {0xE0009000}  \
    CONFIG.PCW_CAN1_HIGHADDR {0xE0009FFF}  \
    CONFIG.PCW_GPIO_BASEADDR {0xE000A000}  \
    CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF}  \
    CONFIG.PCW_ENET0_BASEADDR {0xE000B000}  \
    CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF}  \
    CONFIG.PCW_ENET1_BASEADDR {0xE000C000}  \
    CONFIG.PCW_ENET1_HIGHADDR {0xE000CFFF}  \
    CONFIG.PCW_SDIO0_BASEADDR {0xE0100000}  \
    CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF}  \
    CONFIG.PCW_SDIO1_BASEADDR {0xE0101000}  \
    CONFIG.PCW_SDIO1_HIGHADDR {0xE0101FFF}  \
    CONFIG.PCW_USB0_BASEADDR {0xE0102000}  \
    CONFIG.PCW_USB0_HIGHADDR {0xE0102fff}  \
    CONFIG.PCW_USB1_BASEADDR {0xE0103000}  \
    CONFIG.PCW_USB1_HIGHADDR {0xE0103fff}  \
    CONFIG.PCW_TTC0_BASEADDR {0xE0104000}  \
    CONFIG.PCW_TTC0_HIGHADDR {0xE0104fff}  \
    CONFIG.PCW_TTC1_BASEADDR {0xE0105000}  \
    CONFIG.PCW_TTC1_HIGHADDR {0xE0105fff}  \
    CONFIG.PCW_FCLK_CLK0_BUF {TRUE}  \
    CONFIG.PCW_FCLK_CLK1_BUF {FALSE}  \
    CONFIG.PCW_FCLK_CLK2_BUF {FALSE}  \
    CONFIG.PCW_FCLK_CLK3_BUF {FALSE}  \
    CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333}  \
    CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3}  \
    CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15}  \
    CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10}  \
    CONFIG.PCW_UIPARAM_DDR_CL {8}  \
    CONFIG.PCW_UIPARAM_DDR_CWL {5.000000}  \
    CONFIG.PCW_UIPARAM_DDR_T_RCD {8}  \
    CONFIG.PCW_UIPARAM_DDR_T_RP {8}  \
    CONFIG.PCW_UIPARAM_DDR_T_RC {48.75}  \
    CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0}  \
    CONFIG.PCW_UIPARAM_DDR_T_FAW {40}  \
    CONFIG.PCW_UIPARAM_DDR_AL {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.2323}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.2664}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.2464}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.2353}  \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.240}  \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.207}  \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.227}  \
    CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.238}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {97.8785}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {86.7455}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {102.1345}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {111.4085}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {99.127}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {91.501}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {100.241}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {110.0845}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {102.799}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {102.799}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {102.799}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {102.799}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160}  \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {0.005}  \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {0.016}  \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {0.001}  \
    CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.009}  \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.101}  \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.097}  \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.102}  \
    CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.106}  \
    CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {800}  \
    CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333}  \
    CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {800}  \
    CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159}  \
    CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {150}  \
    CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100}  \
    CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60}  \
    CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60}  \
    CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {50}  \
    CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100}  \
    CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666}  \
    CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100}  \
    CONFIG.PCW_CAN0_PERIPHERAL_FREQMHZ {-1}  \
    CONFIG.PCW_CAN1_PERIPHERAL_FREQMHZ {-1}  \
    CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {133.333328}  \
    CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333}  \
    CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50}  \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333}  \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333}  \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333}  \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333}  \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333}  \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333}  \
    CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200}  \
    CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200}  \
    CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {250}  \
    CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {250}  \
    CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {100}  \
    CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {50}  \
    CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {800.000000}  \
    CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374}  \
    CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730}  \
    CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {142.857132}  \
    CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000}  \
    CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60}  \
    CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60}  \
    CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {50.000000}  \
    CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_CAN0_PERIPHERAL_FREQMHZ {23.8095}  \
    CONFIG.PCW_ACT_CAN1_PERIPHERAL_FREQMHZ {23.8095}  \
    CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50}  \
    CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {133.333344}  \
    CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50}  \
    CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000}  \
    CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000}  \
    CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {250.000000}  \
    CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000}  \
    CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333344}  \
    CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333344}  \
    CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333344}  \
    CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333344}  \
    CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333344}  \
    CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333344}  \
    CONFIG.PCW_CLK0_FREQ {250000000}  \
    CONFIG.PCW_CLK1_FREQ {10000000}  \
    CONFIG.PCW_CLK2_FREQ {10000000}  \
    CONFIG.PCW_CLK3_FREQ {10000000}  \
    CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0}  \
    CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2}  \
    CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2}  \
    CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {7}  \
    CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {20}  \
    CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1}  \
    CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {2}  \
    CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2}  \
    CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1}  \
    CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1}  \
    CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1}  \
    CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8}  \
    CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1}  \
    CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1}  \
    CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15}  \
    CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7}  \
    CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5}  \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1}  \
    CONFIG.PCW_ARMPLL_CTRL_FBDIV {48}  \
    CONFIG.PCW_IOPLL_CTRL_FBDIV {30}  \
    CONFIG.PCW_DDRPLL_CTRL_FBDIV {32}  \
    CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1600.000}  \
    CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000}  \
    CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667}  \
    CONFIG.PCW_SMC_PERIPHERAL_VALID {0}  \
    CONFIG.PCW_SDIO_PERIPHERAL_VALID {1}  \
    CONFIG.PCW_SPI_PERIPHERAL_VALID {0}  \
    CONFIG.PCW_CAN_PERIPHERAL_VALID {0}  \
    CONFIG.PCW_UART_PERIPHERAL_VALID {0}  \
    CONFIG.PCW_EN_EMIO_CAN0 {0}  \
    CONFIG.PCW_EN_EMIO_CAN1 {0}  \
    CONFIG.PCW_EN_EMIO_ENET0 {0}  \
    CONFIG.PCW_EN_EMIO_ENET1 {0}  \
    CONFIG.PCW_EN_PTP_ENET0 {0}  \
    CONFIG.PCW_EN_PTP_ENET1 {0}  \
    CONFIG.PCW_EN_EMIO_GPIO {0}  \
    CONFIG.PCW_EN_EMIO_I2C0 {0}  \
    CONFIG.PCW_EN_EMIO_I2C1 {0}  \
    CONFIG.PCW_EN_EMIO_PJTAG {0}  \
    CONFIG.PCW_EN_EMIO_SDIO0 {0}  \
    CONFIG.PCW_EN_EMIO_CD_SDIO0 {0}  \
    CONFIG.PCW_EN_EMIO_WP_SDIO0 {0}  \
    CONFIG.PCW_EN_EMIO_SDIO1 {0}  \
    CONFIG.PCW_EN_EMIO_CD_SDIO1 {0}  \
    CONFIG.PCW_EN_EMIO_WP_SDIO1 {0}  \
    CONFIG.PCW_EN_EMIO_SPI0 {0}  \
    CONFIG.PCW_EN_EMIO_SPI1 {0}  \
    CONFIG.PCW_EN_EMIO_UART0 {0}  \
    CONFIG.PCW_EN_EMIO_UART1 {0}  \
    CONFIG.PCW_EN_EMIO_MODEM_UART0 {0}  \
    CONFIG.PCW_EN_EMIO_MODEM_UART1 {0}  \
    CONFIG.PCW_EN_EMIO_TTC0 {0}  \
    CONFIG.PCW_EN_EMIO_TTC1 {0}  \
    CONFIG.PCW_EN_EMIO_WDT {0}  \
    CONFIG.PCW_EN_EMIO_TRACE {0}  \
    CONFIG.PCW_USE_AXI_NONSECURE {0}  \
    CONFIG.PCW_USE_M_AXI_GP0 {1}  \
    CONFIG.PCW_USE_M_AXI_GP1 {0}  \
    CONFIG.PCW_USE_S_AXI_GP0 {0}  \
    CONFIG.PCW_USE_S_AXI_GP1 {0}  \
    CONFIG.PCW_USE_S_AXI_ACP {0}  \
    CONFIG.PCW_USE_S_AXI_HP0 {0}  \
    CONFIG.PCW_USE_S_AXI_HP1 {0}  \
    CONFIG.PCW_USE_S_AXI_HP2 {0}  \
    CONFIG.PCW_USE_S_AXI_HP3 {0}  \
    CONFIG.PCW_USE_DMA0 {0}  \
    CONFIG.PCW_USE_DMA1 {0}  \
    CONFIG.PCW_USE_DMA2 {0}  \
    CONFIG.PCW_USE_DMA3 {0}  \
    CONFIG.PCW_USE_TRACE {0}  \
    CONFIG.PCW_TRACE_PIPELINE_WIDTH {8}  \
    CONFIG.PCW_INCLUDE_TRACE_BUFFER {0}  \
    CONFIG.PCW_TRACE_BUFFER_FIFO_SIZE {128}  \
    CONFIG.PCW_USE_TRACE_DATA_EDGE_DETECTOR {0}  \
    CONFIG.PCW_TRACE_BUFFER_CLOCK_DELAY {12}  \
    CONFIG.PCW_USE_CROSS_TRIGGER {0}  \
    CONFIG.PCW_FTM_CTI_IN0 {<Select>}  \
    CONFIG.PCW_FTM_CTI_IN1 {<Select>}  \
    CONFIG.PCW_FTM_CTI_IN2 {<Select>}  \
    CONFIG.PCW_FTM_CTI_IN3 {<Select>}  \
    CONFIG.PCW_FTM_CTI_OUT0 {<Select>}  \
    CONFIG.PCW_FTM_CTI_OUT1 {<Select>}  \
    CONFIG.PCW_FTM_CTI_OUT2 {<Select>}  \
    CONFIG.PCW_FTM_CTI_OUT3 {<Select>}  \
    CONFIG.PCW_USE_DEBUG {0}  \
    CONFIG.PCW_USE_CR_FABRIC {1}  \
    CONFIG.PCW_USE_AXI_FABRIC_IDLE {0}  \
    CONFIG.PCW_USE_DDR_BYPASS {0}  \
    CONFIG.PCW_USE_FABRIC_INTERRUPT {0}  \
    CONFIG.PCW_USE_PROC_EVENT_BUS {0}  \
    CONFIG.PCW_USE_EXPANDED_IOP {0}  \
    CONFIG.PCW_USE_HIGH_OCM {0}  \
    CONFIG.PCW_USE_PS_SLCR_REGISTERS {0}  \
    CONFIG.PCW_USE_EXPANDED_PS_SLCR_REGISTERS {0}  \
    CONFIG.PCW_USE_CORESIGHT {0}  \
    CONFIG.PCW_EN_EMIO_SRAM_INT {0}  \
    CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64}  \
    CONFIG.PCW_GP0_NUM_WRITE_THREADS {4}  \
    CONFIG.PCW_GP0_NUM_READ_THREADS {4}  \
    CONFIG.PCW_GP1_NUM_WRITE_THREADS {4}  \
    CONFIG.PCW_GP1_NUM_READ_THREADS {4}  \
    CONFIG.PCW_UART0_BAUD_RATE {115200}  \
    CONFIG.PCW_UART1_BAUD_RATE {115200}  \
    CONFIG.PCW_EN_4K_TIMER {0}  \
    CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12}  \
    CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0}  \
    CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0}  \
    CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12}  \
    CONFIG.PCW_M_AXI_GP1_ID_WIDTH {12}  \
    CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {0}  \
    CONFIG.PCW_M_AXI_GP1_SUPPORT_NARROW_BURST {0}  \
    CONFIG.PCW_M_AXI_GP1_THREAD_ID_WIDTH {12}  \
    CONFIG.PCW_S_AXI_GP0_ID_WIDTH {6}  \
    CONFIG.PCW_S_AXI_GP1_ID_WIDTH {6}  \
    CONFIG.PCW_S_AXI_ACP_ID_WIDTH {3}  \
    CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0}  \
    CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {0}  \
    CONFIG.PCW_S_AXI_ACP_ARUSER_VAL {31}  \
    CONFIG.PCW_S_AXI_ACP_AWUSER_VAL {31}  \
    CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6}  \
    CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64}  \
    CONFIG.PCW_S_AXI_HP1_ID_WIDTH {6}  \
    CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64}  \
    CONFIG.PCW_S_AXI_HP2_ID_WIDTH {6}  \
    CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64}  \
    CONFIG.PCW_S_AXI_HP3_ID_WIDTH {6}  \
    CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64}  \
    CONFIG.PCW_EN_DDR {0}  \
    CONFIG.PCW_EN_SMC {0}  \
    CONFIG.PCW_EN_QSPI {1}  \
    CONFIG.PCW_EN_CAN0 {0}  \
    CONFIG.PCW_EN_CAN1 {0}  \
    CONFIG.PCW_EN_ENET0 {1}  \
    CONFIG.PCW_EN_ENET1 {0}  \
    CONFIG.PCW_EN_GPIO {0}  \
    CONFIG.PCW_EN_I2C0 {1}  \
    CONFIG.PCW_EN_I2C1 {1}  \
    CONFIG.PCW_EN_PJTAG {0}  \
    CONFIG.PCW_EN_SDIO0 {1}  \
    CONFIG.PCW_EN_SDIO1 {0}  \
    CONFIG.PCW_EN_SPI0 {0}  \
    CONFIG.PCW_EN_SPI1 {0}  \
    CONFIG.PCW_EN_UART0 {0}  \
    CONFIG.PCW_EN_UART1 {0}  \
    CONFIG.PCW_EN_MODEM_UART0 {0}  \
    CONFIG.PCW_EN_MODEM_UART1 {0}  \
    CONFIG.PCW_EN_TTC0 {0}  \
    CONFIG.PCW_EN_TTC1 {0}  \
    CONFIG.PCW_EN_WDT {0}  \
    CONFIG.PCW_EN_TRACE {0}  \
    CONFIG.PCW_EN_USB0 {0}  \
    CONFIG.PCW_EN_USB1 {0}  \
    CONFIG.PCW_DQ_WIDTH {32}  \
    CONFIG.PCW_DQS_WIDTH {4}  \
    CONFIG.PCW_DM_WIDTH {4}  \
    CONFIG.PCW_MIO_PRIMITIVE {54}  \
    CONFIG.PCW_EN_CLK0_PORT {1}  \
    CONFIG.PCW_EN_CLK1_PORT {0}  \
    CONFIG.PCW_EN_CLK2_PORT {0}  \
    CONFIG.PCW_EN_CLK3_PORT {0}  \
    CONFIG.PCW_EN_RST0_PORT {1}  \
    CONFIG.PCW_EN_RST1_PORT {0}  \
    CONFIG.PCW_EN_RST2_PORT {0}  \
    CONFIG.PCW_EN_RST3_PORT {0}  \
    CONFIG.PCW_EN_CLKTRIG0_PORT {0}  \
    CONFIG.PCW_EN_CLKTRIG1_PORT {0}  \
    CONFIG.PCW_EN_CLKTRIG2_PORT {0}  \
    CONFIG.PCW_EN_CLKTRIG3_PORT {0}  \
    CONFIG.PCW_P2F_DMAC_ABORT_INTR {0}  \
    CONFIG.PCW_P2F_DMAC0_INTR {0}  \
    CONFIG.PCW_P2F_DMAC1_INTR {0}  \
    CONFIG.PCW_P2F_DMAC2_INTR {0}  \
    CONFIG.PCW_P2F_DMAC3_INTR {0}  \
    CONFIG.PCW_P2F_DMAC4_INTR {0}  \
    CONFIG.PCW_P2F_DMAC5_INTR {0}  \
    CONFIG.PCW_P2F_DMAC6_INTR {0}  \
    CONFIG.PCW_P2F_DMAC7_INTR {0}  \
    CONFIG.PCW_P2F_SMC_INTR {0}  \
    CONFIG.PCW_P2F_QSPI_INTR {0}  \
    CONFIG.PCW_P2F_CTI_INTR {0}  \
    CONFIG.PCW_P2F_GPIO_INTR {0}  \
    CONFIG.PCW_P2F_USB0_INTR {0}  \
    CONFIG.PCW_P2F_ENET0_INTR {0}  \
    CONFIG.PCW_P2F_SDIO0_INTR {0}  \
    CONFIG.PCW_P2F_I2C0_INTR {0}  \
    CONFIG.PCW_P2F_SPI0_INTR {0}  \
    CONFIG.PCW_P2F_UART0_INTR {0}  \
    CONFIG.PCW_P2F_CAN0_INTR {0}  \
    CONFIG.PCW_P2F_USB1_INTR {0}  \
    CONFIG.PCW_P2F_ENET1_INTR {0}  \
    CONFIG.PCW_P2F_SDIO1_INTR {0}  \
    CONFIG.PCW_P2F_I2C1_INTR {0}  \
    CONFIG.PCW_P2F_SPI1_INTR {0}  \
    CONFIG.PCW_P2F_UART1_INTR {0}  \
    CONFIG.PCW_P2F_CAN1_INTR {0}  \
    CONFIG.PCW_IRQ_F2P_INTR {0}  \
    CONFIG.PCW_IRQ_F2P_MODE {DIRECT}  \
    CONFIG.PCW_CORE0_FIQ_INTR {0}  \
    CONFIG.PCW_CORE0_IRQ_INTR {0}  \
    CONFIG.PCW_CORE1_FIQ_INTR {0}  \
    CONFIG.PCW_CORE1_IRQ_INTR {0}  \
    CONFIG.PCW_VALUE_SILVERSION {3}  \
    CONFIG.PCW_GP0_EN_MODIFIABLE_TXN {1}  \
    CONFIG.PCW_GP1_EN_MODIFIABLE_TXN {1}  \
    CONFIG.PCW_IMPORT_BOARD_PRESET {None}  \
    CONFIG.PCW_PERIPHERAL_BOARD_PRESET {part0}  \
    CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V}  \
    CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V}  \
    CONFIG.PCW_UIPARAM_DDR_ENABLE {0}  \
    CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0}  \
    CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_ECC {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_BL {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_PARTNO {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {<Select>}  \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {0}  \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {0}  \
    CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {0}  \
    CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0}  \
    CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0}  \
    CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0}  \
    CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0}  \
    CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0}  \
    CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0}  \
    CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)}  \
    CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2}  \
    CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15}  \
    CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2}  \
    CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_NAND_GRP_D8_ENABLE {0}  \
    CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_NOR_GRP_A25_ENABLE {0}  \
    CONFIG.PCW_NOR_GRP_CS0_ENABLE {0}  \
    CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0}  \
    CONFIG.PCW_NOR_GRP_CS1_ENABLE {0}  \
    CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0}  \
    CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0}  \
    CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1}  \
    CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6}  \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1}  \
    CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6}  \
    CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0}  \
    CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4}  \
    CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0}  \
    CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {0}  \
    CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF}  \
    CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1}  \
    CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27}  \
    CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1}  \
    CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53}  \
    CONFIG.PCW_ENET_RESET_ENABLE {0}  \
    CONFIG.PCW_ENET_RESET_SELECT {<Select>}  \
    CONFIG.PCW_ENET0_RESET_ENABLE {0}  \
    CONFIG.PCW_ENET0_RESET_IO {<Select>}  \
    CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0}  \
    CONFIG.PCW_ENET1_RESET_ENABLE {0}  \
    CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1}  \
    CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45}  \
    CONFIG.PCW_SD0_GRP_CD_ENABLE {0}  \
    CONFIG.PCW_SD0_GRP_WP_ENABLE {0}  \
    CONFIG.PCW_SD0_GRP_POW_ENABLE {0}  \
    CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_SD1_GRP_CD_ENABLE {0}  \
    CONFIG.PCW_SD1_GRP_WP_ENABLE {0}  \
    CONFIG.PCW_SD1_GRP_POW_ENABLE {0}  \
    CONFIG.PCW_UART0_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_UART0_UART0_IO {<Select>}  \
    CONFIG.PCW_UART0_GRP_FULL_ENABLE {0}  \
    CONFIG.PCW_UART1_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_UART1_UART1_IO {<Select>}  \
    CONFIG.PCW_UART1_GRP_FULL_ENABLE {0}  \
    CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_SPI0_SPI0_IO {<Select>}  \
    CONFIG.PCW_SPI0_GRP_SS0_ENABLE {0}  \
    CONFIG.PCW_SPI0_GRP_SS0_IO {<Select>}  \
    CONFIG.PCW_SPI0_GRP_SS1_ENABLE {0}  \
    CONFIG.PCW_SPI0_GRP_SS1_IO {<Select>}  \
    CONFIG.PCW_SPI0_GRP_SS2_ENABLE {0}  \
    CONFIG.PCW_SPI0_GRP_SS2_IO {<Select>}  \
    CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_SPI1_SPI1_IO {<Select>}  \
    CONFIG.PCW_SPI1_GRP_SS0_ENABLE {0}  \
    CONFIG.PCW_SPI1_GRP_SS0_IO {<Select>}  \
    CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0}  \
    CONFIG.PCW_SPI1_GRP_SS1_IO {<Select>}  \
    CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0}  \
    CONFIG.PCW_SPI1_GRP_SS2_IO {<Select>}  \
    CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_CAN0_CAN0_IO {<Select>}  \
    CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0}  \
    CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0}  \
    CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0}  \
    CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0}  \
    CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0}  \
    CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0}  \
    CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0}  \
    CONFIG.PCW_TRACE_INTERNAL_WIDTH {2}  \
    CONFIG.PCW_WDT_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_PJTAG_PJTAG_IO {<Select>}  \
    CONFIG.PCW_USB0_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_USB0_USB0_IO {<Select>}  \
    CONFIG.PCW_USB_RESET_ENABLE {0}  \
    CONFIG.PCW_USB_RESET_SELECT {<Select>}  \
    CONFIG.PCW_USB0_RESET_ENABLE {0}  \
    CONFIG.PCW_USB0_RESET_IO {<Select>}  \
    CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_USB1_RESET_ENABLE {0}  \
    CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {1}  \
    CONFIG.PCW_I2C0_I2C0_IO {MIO 14 .. 15}  \
    CONFIG.PCW_I2C0_GRP_INT_ENABLE {0}  \
    CONFIG.PCW_I2C0_RESET_ENABLE {0}  \
    CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1}  \
    CONFIG.PCW_I2C1_I2C1_IO {MIO 12 .. 13}  \
    CONFIG.PCW_I2C1_GRP_INT_ENABLE {0}  \
    CONFIG.PCW_I2C_RESET_ENABLE {0}  \
    CONFIG.PCW_I2C_RESET_SELECT {<Select>}  \
    CONFIG.PCW_I2C1_RESET_ENABLE {0}  \
    CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0}  \
    CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {0}  \
    CONFIG.PCW_GPIO_MIO_GPIO_IO {<Select>}  \
    CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {0}  \
    CONFIG.PCW_GPIO_EMIO_GPIO_IO {<Select>}  \
    CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1}  \
    CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps}  \
    CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps}  \
    CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL}  \
    CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL}  \
    CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {DDR PLL}  \
    CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External}  \
    CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External}  \
    CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External}  \
    CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X}  \
    CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X}  \
    CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X}  \
    CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X}  \
    CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X}  \
    CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X}  \
    CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X}  \
    CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL}  \
    CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL}  \
    CONFIG.PCW_USB_RESET_POLARITY {Active Low}  \
    CONFIG.PCW_ENET_RESET_POLARITY {Active Low}  \
    CONFIG.PCW_I2C_RESET_POLARITY {Active Low}  \
    CONFIG.PCW_MIO_0_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_0_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_0_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_0_SLEW {<Select>}  \
    CONFIG.PCW_MIO_1_PULLUP {enabled}  \
    CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_1_DIRECTION {out}  \
    CONFIG.PCW_MIO_1_SLEW {slow}  \
    CONFIG.PCW_MIO_2_PULLUP {disabled}  \
    CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_2_DIRECTION {inout}  \
    CONFIG.PCW_MIO_2_SLEW {slow}  \
    CONFIG.PCW_MIO_3_PULLUP {disabled}  \
    CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_3_DIRECTION {inout}  \
    CONFIG.PCW_MIO_3_SLEW {slow}  \
    CONFIG.PCW_MIO_4_PULLUP {disabled}  \
    CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_4_DIRECTION {inout}  \
    CONFIG.PCW_MIO_4_SLEW {slow}  \
    CONFIG.PCW_MIO_5_PULLUP {disabled}  \
    CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_5_DIRECTION {inout}  \
    CONFIG.PCW_MIO_5_SLEW {slow}  \
    CONFIG.PCW_MIO_6_PULLUP {disabled}  \
    CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_6_DIRECTION {out}  \
    CONFIG.PCW_MIO_6_SLEW {slow}  \
    CONFIG.PCW_MIO_7_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_7_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_7_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_7_SLEW {<Select>}  \
    CONFIG.PCW_MIO_8_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_8_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_8_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_8_SLEW {<Select>}  \
    CONFIG.PCW_MIO_9_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_9_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_9_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_9_SLEW {<Select>}  \
    CONFIG.PCW_MIO_10_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_10_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_10_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_10_SLEW {<Select>}  \
    CONFIG.PCW_MIO_11_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_11_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_11_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_11_SLEW {<Select>}  \
    CONFIG.PCW_MIO_12_PULLUP {enabled}  \
    CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_12_DIRECTION {inout}  \
    CONFIG.PCW_MIO_12_SLEW {slow}  \
    CONFIG.PCW_MIO_13_PULLUP {enabled}  \
    CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_13_DIRECTION {inout}  \
    CONFIG.PCW_MIO_13_SLEW {slow}  \
    CONFIG.PCW_MIO_14_PULLUP {enabled}  \
    CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_14_DIRECTION {inout}  \
    CONFIG.PCW_MIO_14_SLEW {slow}  \
    CONFIG.PCW_MIO_15_PULLUP {enabled}  \
    CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V}  \
    CONFIG.PCW_MIO_15_DIRECTION {inout}  \
    CONFIG.PCW_MIO_15_SLEW {slow}  \
    CONFIG.PCW_MIO_16_PULLUP {enabled}  \
    CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_16_DIRECTION {out}  \
    CONFIG.PCW_MIO_16_SLEW {slow}  \
    CONFIG.PCW_MIO_17_PULLUP {enabled}  \
    CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_17_DIRECTION {out}  \
    CONFIG.PCW_MIO_17_SLEW {slow}  \
    CONFIG.PCW_MIO_18_PULLUP {enabled}  \
    CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_18_DIRECTION {out}  \
    CONFIG.PCW_MIO_18_SLEW {slow}  \
    CONFIG.PCW_MIO_19_PULLUP {enabled}  \
    CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_19_DIRECTION {out}  \
    CONFIG.PCW_MIO_19_SLEW {slow}  \
    CONFIG.PCW_MIO_20_PULLUP {enabled}  \
    CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_20_DIRECTION {out}  \
    CONFIG.PCW_MIO_20_SLEW {slow}  \
    CONFIG.PCW_MIO_21_PULLUP {enabled}  \
    CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_21_DIRECTION {out}  \
    CONFIG.PCW_MIO_21_SLEW {slow}  \
    CONFIG.PCW_MIO_22_PULLUP {enabled}  \
    CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_22_DIRECTION {in}  \
    CONFIG.PCW_MIO_22_SLEW {slow}  \
    CONFIG.PCW_MIO_23_PULLUP {enabled}  \
    CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_23_DIRECTION {in}  \
    CONFIG.PCW_MIO_23_SLEW {slow}  \
    CONFIG.PCW_MIO_24_PULLUP {enabled}  \
    CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_24_DIRECTION {in}  \
    CONFIG.PCW_MIO_24_SLEW {slow}  \
    CONFIG.PCW_MIO_25_PULLUP {enabled}  \
    CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_25_DIRECTION {in}  \
    CONFIG.PCW_MIO_25_SLEW {slow}  \
    CONFIG.PCW_MIO_26_PULLUP {enabled}  \
    CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_26_DIRECTION {in}  \
    CONFIG.PCW_MIO_26_SLEW {slow}  \
    CONFIG.PCW_MIO_27_PULLUP {enabled}  \
    CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_27_DIRECTION {in}  \
    CONFIG.PCW_MIO_27_SLEW {slow}  \
    CONFIG.PCW_MIO_28_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_28_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_28_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_28_SLEW {<Select>}  \
    CONFIG.PCW_MIO_29_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_29_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_29_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_29_SLEW {<Select>}  \
    CONFIG.PCW_MIO_30_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_30_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_30_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_30_SLEW {<Select>}  \
    CONFIG.PCW_MIO_31_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_31_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_31_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_31_SLEW {<Select>}  \
    CONFIG.PCW_MIO_32_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_32_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_32_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_32_SLEW {<Select>}  \
    CONFIG.PCW_MIO_33_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_33_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_33_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_33_SLEW {<Select>}  \
    CONFIG.PCW_MIO_34_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_34_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_34_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_34_SLEW {<Select>}  \
    CONFIG.PCW_MIO_35_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_35_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_35_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_35_SLEW {<Select>}  \
    CONFIG.PCW_MIO_36_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_36_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_36_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_36_SLEW {<Select>}  \
    CONFIG.PCW_MIO_37_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_37_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_37_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_37_SLEW {<Select>}  \
    CONFIG.PCW_MIO_38_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_38_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_38_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_38_SLEW {<Select>}  \
    CONFIG.PCW_MIO_39_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_39_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_39_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_39_SLEW {<Select>}  \
    CONFIG.PCW_MIO_40_PULLUP {disabled}  \
    CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_40_DIRECTION {inout}  \
    CONFIG.PCW_MIO_40_SLEW {fast}  \
    CONFIG.PCW_MIO_41_PULLUP {disabled}  \
    CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_41_DIRECTION {inout}  \
    CONFIG.PCW_MIO_41_SLEW {fast}  \
    CONFIG.PCW_MIO_42_PULLUP {disabled}  \
    CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_42_DIRECTION {inout}  \
    CONFIG.PCW_MIO_42_SLEW {fast}  \
    CONFIG.PCW_MIO_43_PULLUP {disabled}  \
    CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_43_DIRECTION {inout}  \
    CONFIG.PCW_MIO_43_SLEW {fast}  \
    CONFIG.PCW_MIO_44_PULLUP {disabled}  \
    CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_44_DIRECTION {inout}  \
    CONFIG.PCW_MIO_44_SLEW {fast}  \
    CONFIG.PCW_MIO_45_PULLUP {disabled}  \
    CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_45_DIRECTION {inout}  \
    CONFIG.PCW_MIO_45_SLEW {fast}  \
    CONFIG.PCW_MIO_46_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_46_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_46_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_46_SLEW {<Select>}  \
    CONFIG.PCW_MIO_47_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_47_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_47_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_47_SLEW {<Select>}  \
    CONFIG.PCW_MIO_48_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_48_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_48_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_48_SLEW {<Select>}  \
    CONFIG.PCW_MIO_49_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_49_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_49_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_49_SLEW {<Select>}  \
    CONFIG.PCW_MIO_50_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_50_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_50_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_50_SLEW {<Select>}  \
    CONFIG.PCW_MIO_51_PULLUP {<Select>}  \
    CONFIG.PCW_MIO_51_IOTYPE {<Select>}  \
    CONFIG.PCW_MIO_51_DIRECTION {<Select>}  \
    CONFIG.PCW_MIO_51_SLEW {<Select>}  \
    CONFIG.PCW_MIO_52_PULLUP {enabled}  \
    CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_52_DIRECTION {out}  \
    CONFIG.PCW_MIO_52_SLEW {slow}  \
    CONFIG.PCW_MIO_53_PULLUP {enabled}  \
    CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V}  \
    CONFIG.PCW_MIO_53_DIRECTION {inout}  \
    CONFIG.PCW_MIO_53_SLEW {slow}  \
    CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA}  \
    CONFIG.PCW_MIO_TREE_PERIPHERALS {unassigned#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#unassigned#unassigned#unassigned#unassigned#unassigned#I2C 1#I2C 1#I2C 0#I2C 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#Enet 0#Enet 0}  \
    CONFIG.PCW_MIO_TREE_SIGNALS {unassigned#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#unassigned#unassigned#unassigned#unassigned#unassigned#scl#sda#scl#sda#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#clk#cmd#data[0]#data[1]#data[2]#data[3]#unassigned#unassigned#unassigned#unassigned#unassigned#unassigned#mdc#mdio}  \
    CONFIG.PCW_PS7_SI_REV {PRODUCTION}  \
    CONFIG.PCW_FPGA_FCLK0_ENABLE {1}  \
    CONFIG.PCW_FPGA_FCLK1_ENABLE {0}  \
    CONFIG.PCW_FPGA_FCLK2_ENABLE {0}  \
    CONFIG.PCW_FPGA_FCLK3_ENABLE {0}  \
    CONFIG.PCW_NOR_SRAM_CS0_T_TR {1}  \
    CONFIG.PCW_NOR_SRAM_CS0_T_PC {1}  \
    CONFIG.PCW_NOR_SRAM_CS0_T_WP {1}  \
    CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1}  \
    CONFIG.PCW_NOR_SRAM_CS0_T_WC {11}  \
    CONFIG.PCW_NOR_SRAM_CS0_T_RC {11}  \
    CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0}  \
    CONFIG.PCW_NOR_SRAM_CS1_T_TR {1}  \
    CONFIG.PCW_NOR_SRAM_CS1_T_PC {1}  \
    CONFIG.PCW_NOR_SRAM_CS1_T_WP {1}  \
    CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1}  \
    CONFIG.PCW_NOR_SRAM_CS1_T_WC {11}  \
    CONFIG.PCW_NOR_SRAM_CS1_T_RC {11}  \
    CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0}  \
    CONFIG.PCW_NOR_CS0_T_TR {1}  \
    CONFIG.PCW_NOR_CS0_T_PC {1}  \
    CONFIG.PCW_NOR_CS0_T_WP {1}  \
    CONFIG.PCW_NOR_CS0_T_CEOE {1}  \
    CONFIG.PCW_NOR_CS0_T_WC {11}  \
    CONFIG.PCW_NOR_CS0_T_RC {11}  \
    CONFIG.PCW_NOR_CS0_WE_TIME {0}  \
    CONFIG.PCW_NOR_CS1_T_TR {1}  \
    CONFIG.PCW_NOR_CS1_T_PC {1}  \
    CONFIG.PCW_NOR_CS1_T_WP {1}  \
    CONFIG.PCW_NOR_CS1_T_CEOE {1}  \
    CONFIG.PCW_NOR_CS1_T_WC {11}  \
    CONFIG.PCW_NOR_CS1_T_RC {11}  \
    CONFIG.PCW_NOR_CS1_WE_TIME {0}  \
    CONFIG.PCW_NAND_CYCLES_T_RR {1}  \
    CONFIG.PCW_NAND_CYCLES_T_AR {1}  \
    CONFIG.PCW_NAND_CYCLES_T_CLR {1}  \
    CONFIG.PCW_NAND_CYCLES_T_WP {1}  \
    CONFIG.PCW_NAND_CYCLES_T_REA {1}  \
    CONFIG.PCW_NAND_CYCLES_T_WC {11}  \
    CONFIG.PCW_NAND_CYCLES_T_RC {11}  \
    CONFIG.PCW_SMC_CYCLE_T0 {NA}  \
    CONFIG.PCW_SMC_CYCLE_T1 {NA}  \
    CONFIG.PCW_SMC_CYCLE_T2 {NA}  \
    CONFIG.PCW_SMC_CYCLE_T3 {NA}  \
    CONFIG.PCW_SMC_CYCLE_T4 {NA}  \
    CONFIG.PCW_SMC_CYCLE_T5 {NA}  \
    CONFIG.PCW_SMC_CYCLE_T6 {NA}  \
    CONFIG.PCW_PACKAGE_NAME {fbg676}  \
    CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0}  \
  ]
}


