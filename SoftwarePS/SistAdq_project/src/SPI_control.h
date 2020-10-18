/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
AD9249 SPI control interface using AXI Quad SPI in CIAA-ACC

Version: 2020-10-13
Comments:
*/

#ifndef SPI_CONTROL_H_
#define SPI_CONTROL_H_

#include <memory.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>

#include "AXI_control.h"

// AXI SPI addresses
#define SPI_BASE_ADDR 0x83C00000
#define SPI_SRR_OFF 0X40
#define SPI_CR_OFF 0X60
#define SPI_SR_OFF 0X64
#define SPI_DTR_OFF 0X68
#define SPI_DRR_OFF 0X6C
#define SPI_SSR_OFF 0X70

// SPI_CR control parameters
typedef enum
{
    LSBfirst = (1 << 9),
    MasterTransInhibit = (1 << 8),
    ManualSSelAssertEn = (1 << 7),
    RxFIFOreset = (1 << 6),
    TxFIFOreset = (1 << 5),
    CPHA = (1 << 4),
    CPOL = (1 << 3),
    MasterMode = (1 << 2),
    SPIsystemEn = (1 << 1),
    Loop = (1 << 0)
}SPI_CR_params_t;

// SPI_SR control parameters
typedef struct
{
    bool commandErr;
    bool loopbackErr;
    bool MSBerr;
    bool slaveModeErr;
    bool CPOL_CPHAErr;
    bool slaveModeSel;
    bool MODF;
    bool txFull;
    bool txEmpty;
    bool rxFull;
    bool rxEmpty;
}SPI_SR_t;

// slaves
typedef enum
{
    adc1,
    adc2,
    none
}SPI_slaves_t;

// ADC SPI addresses
#define ADC_CLOCKDIVIDE     0X0B
#define ADC_TESTMODE        0X0D
#define ADC_OUTPUTMODE      0X14
#define ADC_OUTPUTADJUST    0X15
#define ADC_VREF            0X18
#define ADC_W1_LSB          0X19
#define ADC_W1_MSB          0X1A
#define ADC_W2_LSB          0X1B
#define ADC_W2_MSB          0X1C

// masks for MSB/LSB word separation
#define MSB_MASK (((1<<6)-1)<<8)
#define LSB_MASK ((1<<8)-1)

// test pattern codes
typedef enum
{
    off = 0b0000,
    midShort = 0b0001,
    posFullScale = 0b0010,
    negFullScale = 0b0011,
    checkerboard = 0b0100,
    PNseqLong = 0b0101,
    PNseqShort = 0b0110,
    oneZeroWordToggle = 0b0111,
    oneZeroBitToggle = 0b1001,
    oneXsync = 0b1010,
    oneBitHigh = 0b1011,
    mixedFrequency = 0b1100
}adc_testPattern_t;

// resets SPI module
void spi_reset();

// configures SPI_CR register. params and value are two arrays of specified size
void spi_CR_config(SPI_CR_params_t* params, bool* value, uint8_t size);

// writes an instruction to the ADC, complying with its instruction formats. address is a 13 bit argument, and data is an array of size n_bytes
int spi_write(uint16_t address, const uint32_t* data, uint8_t n_bytes);

// selects active slave
int spi_ssel(SPI_slaves_t slave);

//default configuration for AXI-SPI module
void spi_defaultConfig();

//default configuration for ADC via SPI
void adc_defaultConfig();

//set clock divider to value divide
void adc_clkDividerSet(uint8_t divide);

//sets test pattern to specified testPattern
void adc_testPattern(adc_testPattern_t testPattern);

//configures ADC user test pattern to alternate between word1 and word2
void adc_userTestPattern(uint16_t word1, uint16_t word2);

#endif //SPI_CONTROL_H_