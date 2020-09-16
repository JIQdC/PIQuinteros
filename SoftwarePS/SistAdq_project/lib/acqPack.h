#ifndef ACQPACK_H_
#define ACQPACK_H_

#include <time.h>
#include <stdint.h>

//PACK SIZE MUST BE EQUAL TO PROG_FULL LEVEL/2 IN FIFO
#define PACK_SIZE 5000

typedef struct __attribute__ ((packed))
{
    uint64_t acq_timestamp_sec;
    uint64_t acq_timestamp_nsec;
    uint8_t bd_id;
    uint8_t ch_id;
    uint16_t ch_adc;
    uint8_t clk_divider;
    uint32_t fifo_flags;
    uint16_t payload_size;
}AcqPack_Header_t;


// typedef struct __attribute__ ((packed))
typedef struct __attribute__ ((packed))
{
    AcqPack_Header_t header;
    uint32_t data[PACK_SIZE];
}AcqPack_t;

#endif //ACQPACK_H_