#ifndef BUFFER_H_
#define BUFFER_H_

#include <stdint.h>

#define BUF_SIZE 2

#define UPDATE_TIME_SEC 1

typedef struct __attribute__ ((packed))
{
    uint8_t bd_id;
    uint8_t ch_id;
    //timestamp
    uint16_t data[BUF_SIZE];
} Buffer_t;

#endif //BUFFER_H_