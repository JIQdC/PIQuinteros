/*
Emulation, acquisition and data processing system for sensor matrices 
José Quinteros del Castillo
Instituto Balseiro
---
AD9249 SPI control interface using AXI Quad SPI in CIAA-ACC

Version: 2020-09-09
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
#include "CIAASistAdq.h"

// AXI SPI addresses
#define SPI_BASE_ADDR 0x81E00000
#define SPI_SRR_ADDR 0X40
#define SPI_CR_ADDR 0X60
#define SPI_SR_ADDR 0X64
#define SPI_DTR_ADDR 0X68
#define SPI_DRR_ADDR 0X6C
#define SPI_SSR_ADDR 0X70

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

// resets SPI module
void spi_reset();

// configures SPI_CR register. params and value are two arrays of specified size
void spi_CR_config(SPI_CR_params_t * params, bool * value, uint8_t size);

// writes an instruction to the ADC, complying with its instruction formats. address is a 13 bit argument, and data is an array of size n_bytes
int spi_write(uint16_t address, const uint32_t * data, uint8_t n_bytes);

// selects active slave
int spi_ssel(SPI_slaves_t slave);

//default configuration for AXI-SPI module
void spi_defaultConfig();

//default configuration for ADC via SPI
void adc_defaultConfig();

#endif //SPI_CONTROL_H_