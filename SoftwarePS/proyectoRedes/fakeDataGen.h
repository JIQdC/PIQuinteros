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
#include "error.h"

#define DEV_Q_SIZE 16

#define SINE_AMPLITUDE 32768
#define SINE_OFFSET 32768

typedef enum
{
    sine4k,
    sine2k,
    randConst,
    noise
} OpMode_t;

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    uint16_t elements[DEV_Q_SIZE];
} Dev_Queue_t;

typedef struct
{
    double update_period;   //in seconds
    OpMode_t mode;
    Dev_Queue_t * pq;
    pthread_t th;
    int running;
} FakeDataGen_t;

////ERROR
void error(const char *msg);

////QUEUES
// initializes a Dev_Queue_t queue
Dev_Queue_t* Dev_QueueInit();

// destroys a Dev_Queue_t queue
void Dev_QueueDestroy(Dev_Queue_t *pQ);

// Adds a new element to a Dev_Queue_t queue
void Dev_QueuePut(Dev_Queue_t *pQ, uint16_t elem);

// Gets and removes an element from a Dev_Queue_t queue
uint16_t Dev_QueueGet(Dev_Queue_t *pQ);

// Gets the number of elements in a Dev_Queue_t queue
int Dev_QueueSize(Dev_Queue_t *pQ);

////FAKE DATA GEN
// initializes a fake data generator
FakeDataGen_t * FakeDataGenInit(time_t update_period, OpMode_t mode);

// destroys a fake data generator
void FakeDataGenDestroy(FakeDataGen_t * fdg);

// function to be run by the fake data generator
void * fdg_threadFunc (void * ctx);

// runs a fake data gen
void FakeDataGenRun(FakeDataGen_t * fdg);

//stops a fake data gen
void FakeDataGenStop(FakeDataGen_t * fdg);