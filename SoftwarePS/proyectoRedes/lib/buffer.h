#ifndef BUFFER_H_
#define BUFFER_H_

#include <stdint.h>
#include <time.h>

#define BUF_SIZE 32

#define UPDATE_TIME_SEC 0
#define UPDATE_TIME_NSEC 100000

typedef struct __attribute__ ((packed))
{
    //packet_id: with/without header
    //Cl_Params_t?? optional overhead
    uint8_t bd_id;
    uint8_t ch_id;
    struct timespec tp;
    uint16_t data[BUF_SIZE];

#ifdef _DEBUG
    int tx_qstate;
    int rx_qstate;
    int cl_qstate;
#endif
} Buffer_t;

#endif //BUFFER_H_