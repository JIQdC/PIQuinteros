/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Data packaging format

Version: 2020-10-18
Comments:
*/

#ifndef ACQPACK_H_
#define ACQPACK_H_

#include <time.h>
#include <stdint.h>

//PACK SIZE MUST BE EQUAL TO PROG_FULL LEVEL/2 IN FIFO
#define CHDATA_SIZE 1000

#define WORD0_MASK ((1 << 14)-1)
#define WORD1_MASK (WORD0_MASK << 14)

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

#endif //ACQPACK_H_