#ifndef CLIENT_PARAMS_H_
#define CLIENT_PARAMS_H_

#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <sys/timerfd.h>

typedef enum
{
    sampleNumber,
    timeInterval
} CaptureMode_t;

typedef enum
{
    manual,
    timer,
    noDelay
} TriggerMode_t;

typedef struct
{
    uint8_t bd_id;
    uint8_t ch_id;
    char * serv_addr;
    int server_portno;
    CaptureMode_t capMode;
    TriggerMode_t trigMode;
    int n_samples;
    struct tm timerfd_start_br;
    struct itimerspec timerfd_stop_spec;
} ClParams_t;

//// PARAMETER PARSING
// parse a file to get parameters for client. checks if all necessary parameters are set
void ClientParseFile(const char *fname, ClParams_t *clPars);

#endif //CLIENT_PARAMS_H_