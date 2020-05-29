#ifndef FDG_PARAMS_H_
#define FDG_PARAMS_H_

#include <stdlib.h>
#include <sys/timerfd.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "../lib/error.h"

typedef enum
{
    sine,
    randConst,
    noise,
    countOffset
} OpMode_t;

typedef struct
{
    struct timespec update_period;
    OpMode_t mode;
    uint16_t mode_param;
} FdgParams_t;

// parse a file to get parameters for FDG. checks if all necessary parameters are set
void FdgParseFile(const char *fname, FdgParams_t *fdgPars);

#endif //FDG_PARAMS_H_