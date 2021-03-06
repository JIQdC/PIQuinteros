/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Data packaging format

Version: 2020-11-22
Comments:
*/

#ifndef ACQPACK_H_
#define ACQPACK_H_

#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <time.h>

//PACK SIZE MUST BE EQUAL TO PROG_FULL LEVEL/2 IN FIFO
#define CHDATA_SIZE 1000

//masks to read FIFO flags register
#define RDDATACOUNT_MASK ((1 << 12) - 1)
#define RDRSTBUSY_MASK  (1 << 12)
#define WRRSTBUSY_MASK  (1 << 13)
#define OVERFLOW_MASK   (1 << 14)
#define EMPTY_MASK      (1 << 15)
#define FULL_MASK       (1 << 16)
#define PROGFULL_MASK   (1 << 17)
#define PROGFULL_ASSERT ((1 << 16) - 1)

static const char g_ch_names[16][5] = { "A1", "A2", "B1", "B2", "C1", "C2", "D1",
            "D2", "E1", "E2", "F1", "F2", "G1", "G2", "H1", "H2" };

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

typedef struct __attribute__((packed))
{
    uint64_t acq_timestamp_sec;
    uint64_t acq_timestamp_nsec;
    uint8_t bd_id;
    uint8_t ch_id;
    uint16_t ch_adc;
    uint8_t clk_divider;
    uint32_t fifo_flags[16];
    uint16_t payload_size;
}AcqPack_Header_t;

typedef union
{
    uint32_t data;
    uint16_t data16[2];
}fifo_data_t;

typedef struct __attribute__((packed))
{
    AcqPack_Header_t header;
    fifo_data_t data[16][CHDATA_SIZE];
}AcqPack_t;

// human readable print of FIFO flags structure
void print_fifo_flags(fifo_flags_t* flags);

// converts FIFO flag register to FIFO flags structure
void fifoflags_reg_to_struct(fifo_flags_t* flags, uint32_t* flag_reg);

#endif //ACQPACK_H_