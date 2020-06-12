#ifndef CLIENT_QUEUES_H_
#define CLIENT_QUEUES_H_

#define RX_Q_SIZE_LOG2 6
#define RX_Q_SIZE (1<<RX_Q_SIZE_LOG2)
#define RX_Q_MASK (RX_Q_SIZE - 1)

#define TX_Q_SIZE_LOG2 6
#define TX_Q_SIZE (1<<TX_Q_SIZE_LOG2)
#define TX_Q_MASK (TX_Q_SIZE - 1)

#include <semaphore.h>
#include <stdlib.h>
#include "../lib/error.h"
#include "../lib/acqPack.h"

typedef struct
{
    sem_t sem;

    int acq;
    int rls;
    int q_size;

    AcqPack_t elements[RX_Q_SIZE];
} Rx_Queue_t;

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    AcqPack_t * elements[TX_Q_SIZE];
} Tx_Queue_t;

// initializes an Rx_Queue_t queue
Rx_Queue_t* Rx_QueueInit();

// destroys an Rx_Queue_t queue
void Rx_QueueDestroy(Rx_Queue_t *pQ);

// Gets the number of elements in an Rx_Queue_t queue
int Rx_QueueSize(Rx_Queue_t *pQ);

// Returns a pointer to a free AcqPack_t
AcqPack_t * Rx_Queue_Acquire(Rx_Queue_t *q);

// Releases an AcqPack_t making it ready to be reused
void Rx_Queue_Release(Rx_Queue_t *q, AcqPack_t * rxBuf);

// initializes a Tx_Queue_t queue
Tx_Queue_t* Tx_QueueInit();

// destroys a Tx_Queue_t queue
void Tx_QueueDestroy(Tx_Queue_t *pQ);

// Adds a new element to a Tx_Queue_t queue
void Tx_QueuePut(Tx_Queue_t *pQ, AcqPack_t * elem);

// Gets and removes an element from a Tx_Queue_t queue
AcqPack_t * Tx_QueueGet(Tx_Queue_t *pQ);

// Gets the number of elements in a Tx_Queue_t queue
int Tx_QueueSize(Tx_Queue_t *pQ);

#endif //CLIENT_QUEUES_H_