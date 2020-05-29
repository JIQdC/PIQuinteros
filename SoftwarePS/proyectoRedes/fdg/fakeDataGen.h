#ifndef FAKEDATAGEN_H_
#define FAKEDATAGEN_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>
#include <semaphore.h>
#include <sys/time.h>
#include <sys/select.h>
#include <strings.h>
#include <errno.h>
#include <sys/eventfd.h>
#include <signal.h>
#include <math.h>
#include <sys/timerfd.h>

#include "../lib/error.h"
#include "devQueue.h"
#include "fdg_params.h"

#define SINE_AMPLITUDE 32767
#define SINE_OFFSET 32768

typedef struct
{
    struct timespec update_period;   //in seconds and nanoseconds
    int timefd;

    OpMode_t mode;
    uint16_t mode_param;

    Dev_Queue_t * pq;

    pthread_t th;
    int running;

    int eventfd_out;
} FakeDataGen_t;

////FAKE DATA GEN
// initializes a fake data generator
FakeDataGen_t * FakeDataGenInit(const FdgParams_t * params, int eventfd_out);

// destroys a fake data generator
void FakeDataGenDestroy(FakeDataGen_t * fdg);

// runs a fake data gen
void FakeDataGenRun(FakeDataGen_t * fdg);

//stops a fake data gen
void FakeDataGenStop(FakeDataGen_t * fdg);

#endif //FAKEDATAGEN_H_