/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Parameter parsing for data acquisition interface

Version: 2020-11-21
Comments:
*/

#ifndef CLIENT_PARAMS_H_
#define CLIENT_PARAMS_H_

#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#include <sys/timerfd.h>

typedef enum
{
    file,
    UDP
} Tx_Mode_t;

typedef enum
{
    sampleNumber,
    timeInterval,
    continued
} CaptureMode_t;

typedef enum
{
    manual,
    timer,
    noDelay,
    extTrigger
} TriggerMode_t;

typedef struct
{
    uint8_t bd_id;
    char* serv_addr;
    int server_portno;
    Tx_Mode_t txMode;
    CaptureMode_t capMode;
    TriggerMode_t trigMode;
    int n_samples;
    struct tm timerfd_start_br;
    struct itimerspec timerfd_stop_spec;
    uint16_t debug_output;
    uint16_t clk_divider;
    uint16_t downsampler_tresh;
} ClParams_t;

//// PARAMETER PARSING
// parse a file to get parameters for client. checks if all necessary parameters are set
void ClientParseFile(const char* fname, ClParams_t* clPars);

#endif //CLIENT_PARAMS_H_