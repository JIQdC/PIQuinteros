#ifndef DEVQUEUE_H_
#define DEVQUEUE_H_

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
#include "../lib/error.h"

#define DEV_Q_SIZE_LOG2 4
#define DEV_Q_SIZE (1<<DEV_Q_SIZE_LOG2)
#define DEV_Q_MASK (DEV_Q_SIZE - 1)

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

#endif //DEVQUEUE_H_