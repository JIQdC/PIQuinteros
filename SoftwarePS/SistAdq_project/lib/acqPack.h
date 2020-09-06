#ifndef ACQPACK_H_
#define ACQPACK_H_

#include <time.h>
#include <stdint.h>

#define PACK_SIZE (1<<13)

typedef struct __attribute__ ((packed))
{
    struct timespec acq_timestamp;
    uint8_t bd_id;
    uint8_t ch_id;
    uint16_t ch_adc;
    uint32_t fifo_flags;
    uint16_t payload_size;
}AcqPack_Header_t;


typedef struct __attribute__ ((packed))
{    
    AcqPack_Header_t header;
    //uint32_t flags[PACK_SIZE];
    uint32_t data[PACK_SIZE];
}AcqPack_t;

#endif //ACQPACK_H_