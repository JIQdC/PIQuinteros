/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
AXI control functions for CIAA-ACC

Version: 2020-10-17
Comments:
*/

#ifndef SRC_AXI_CONTROL_H_
#define SRC_AXI_CONTROL_H_

#define _GNU_SOURCE

#include <memory.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include <time.h>

#include "../lib/error.h"
#include "../lib/acqPack.h"

#define PAGE_SIZE getpagesize()

// Data interface register addresses
#define DATA_BASE_ADDR  0x43C00000
#define COREID_OFF      (0x00<<2)
#define ASYNCRST_OFF    (0x01<<2)
#define FIFORST_OFF     (0x02<<2)
#define PROGFULL_OFF    (0x03<<2)
#define ENABLE_OFF      (0x04<<2)

#define CONTROL_OFF     (0x20<<2)
#define USRW2W1_OFF     (0x40<<2)
#define FIFOFLAGS_OFF   (0x60<<2)
#define FIFODATA_OFF    (0x80<<2)

#define USRAUX_OFF      (0xFF<<2)

//delay control module register addresses
#define DELAY_BASE_ADDR     0x43C10000

#define LOCKED12_OFF        (0x0<<2)
#define LOCKED13_OFF        (0x1<<2)

#define FRAME_LD_12_OFF     (0x2<<2)
#define FRAME_LD_13_OFF     (0x3<<2)
#define FRAME_IN_12_OFF     (0x4<<2)
#define FRAME_IN_13_OFF     (0x5<<2)
#define FRAME_OUT_12_OFF    (0x6<<2)
#define FRAME_OUT_13_OFF    (0x7<<2)

#define DATA_LD_OFF         (0x20<<2)
#define DATA_IN_OFF         (0x40<<2)
#define DATA_OUT_OFF        (0x60<<2)

//downsampling control module register addresses
#define DOWNSMPL_BASE_ADDR  0x43c20000
#define TRESH_LD_OFF        (0x00<<2)
#define TRESH_VAL_OFF       (0x01<<2)

//pin control module register addresses`
#define CONTROL_BASE_ADDR   0x83C10000
#define REG_OFF             (0x0<<2)
#define FMCPRESENT_OFF      (0x1<<2)
#define FCO1LOCK_OFF        (0x2<<2)
#define FCO2LOCK_OFF        (0x3<<2)

//potentiometer value for required VADJ voltage
#define POT_VALUE 29

//memwrite and memread do not require memory increase
#define MEM_INCR 0

//masks to read FIFO flags register
#define RDDATACOUNT_MASK ((1 << 12) - 1)
#define RDRSTBUSY_MASK  (1 << 12)
#define WRRSTBUSY_MASK  (1 << 13)
#define OVERFLOW_MASK   (1 << 14)
#define EMPTY_MASK      (1 << 15)
#define FULL_MASK       (1 << 16)
#define PROGFULL_MASK   (1 << 17)
#define PROGFULL_ASSERT ((1 << 16) - 1)

//debug control sequences
#define DISABLED_CTRL           0x0
#define MIDSCALE_SH_CTRL        0x1
#define PLUS_FULLSCALE_SH_CTRL  0x2
#define MINUS_FULLSCALE_SH_CTRL 0x3
#define USR_W1_CTRL             0x8
#define USR_W2_CTRL             0x9
#define ONEX_BITSYNC_CTRL       0xA
#define ONEBIT_HIGH_CTRL        0xB
#define MIXED_FREQ_CTRL         0xC
#define DESERIALIZER_CTRL       0xD
#define CONT_NBITS_CTRL         0xF

typedef struct
{
    bool full;
    bool empty;
    bool wr_rst_busy;
    bool rd_rst_busy;
    bool overflow;
    bool prog_full;
    uint32_t rd_data_count;
}fifo_flags_t;

//a Multi_MemPtr_t contains several mapped memory spaces for easy read/write operations
typedef struct
{
    uint32_t* addr;
    uint8_t** ptr;
    off_t* align_offset;
    uint8_t mem_num;
}Multi_MemPtr_t;

// ADC PIN POSITIONS

//position of each ADC data pin in FPGA banks. 0 for BANK12, 1 for BANK13
static const bool g_adcPinPositions[16] = { 0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1 };

// GENERAL PURPOSE FUNCTIONS

// writes data to a memory register
int memwrite(uint32_t addr, const uint32_t* data, size_t count);

// reads data from a memory register
int memread(uint32_t addr, uint32_t* data, size_t count);

// checks if FMC connector is present in CIAA-ACC
bool fmc_present();

// checks if FCO1 is locked
bool locked_FCO1();

// checks if FCO2 is locked
bool locked_FCO2();

// human readable print of FIFO flags structure
void print_fifo_flags(fifo_flags_t* flags);

// converts FIFO flag register to FIFO flags structure
void fifoflags_reg_to_struct(fifo_flags_t* flags, uint32_t* flag_reg);

// resets FIFO
void fifo_reset();

// triggers async reset for duration in usec
void async_reset(unsigned int duration);

//enables bank 12 and 13 regulator, setting the potentiometer to specified value via I2C
void regulator_enable();

//disables bank 12 and 13 regulator
void regulator_disable();

// sets debug output of ADC channel adc_ch to desired value
void debug_output(uint8_t value, uint8_t adc_ch);

// enables FIFO input for all ADC channels
void debug_enable();

// disables FIFO input for all ADC channels
void debug_disable();

// initializes a Multi_MemPtr_t, mapping the memory addresses passed as argument
Multi_MemPtr_t* multi_minit(uint32_t* addr, uint8_t mem_num);

// destroys a Multi_MemPtr_t, unmapping its memory spaces
void multi_mdestroy(Multi_MemPtr_t* multiPtr);

// fills an AcqPack_t with external data from Acquisition System
void acquire_data(AcqPack_t* acqPack, Multi_MemPtr_t* multiPtr_flags, Multi_MemPtr_t* multiPtr_data, Multi_MemPtr_t* multiPtr_progFull);

////INPUT DELAY CONTROL
// changes the input delay of frame pin i (0 for BANK12, 1 for BANK13) to value taps.
int inputDelaySet_frame(uint8_t i, uint8_t taps);

// changes the input delay of data pin i to value taps
int inputDelaySet_data(uint8_t i, uint8_t taps);

#endif /* SRC_AXI_CONTROL_H_ */
