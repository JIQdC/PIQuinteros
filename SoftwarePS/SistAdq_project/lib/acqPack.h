#ifndef ACQPACK_H_
#define ACQPACK_H_

#include <time.h>
#include <stdint.h>

#define PACK_SIZE (1<<8)

typedef struct __attribute__ ((packed))
{
    //fill with header data
    struct timespec acq_timestamp;
}AcqPack_Header_t;


typedef struct
{    
    AcqPack_Header_t header;
    uint8_t flags[PACK_SIZE];
    uint32_t data[PACK_SIZE];
}AcqPack_t;

#endif //ACQPACK_H_