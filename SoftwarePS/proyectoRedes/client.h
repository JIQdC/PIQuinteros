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
#include <netdb.h> 
#include "error.h"

#define BUF_SIZE 16
#define RX_Q_SIZE 16
#define TX_Q_SIZE 16

typedef struct __attribute__ ((packed))
{
    sem_t sem_lock;

    uint8_t bd_id;
    uint8_t ch_id;
    //timestamp
    uint16_t data[BUF_SIZE];
    //flag ready?
} Rx_Buffer_t;

typedef struct
{
    // sem_t sem_lock;
    // sem_t sem_put;
    // sem_t sem_get;

    int put;
    int get;
    int q_size;

    Rx_Buffer_t elements[RX_Q_SIZE];
} Rx_Queue_t;

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    Rx_Buffer_t * elements[TX_Q_SIZE];
} Tx_Queue_t;

typedef struct
{
    pthread_t th;
    int running;
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;
} Adq_Thread_t;

typedef struct
{
    pthread_t th;
    int running;
    Tx_Queue_t *txQ;
    char *server_addr;
    int server_portno;
    int sockfd;
} Tx_Thread_t;

////QUEUES
// initializes an Rx_Queue_t queue
Rx_Queue_t* Rx_QueueInit();

// destroys an Rx_Queue_t queue
void Rx_QueueDestroy(Rx_Queue_t *pQ);

// // fills an Rx_Queue_t queue with data
// void Rx_QueueFill(Rx_Queue_t *pQ);

/*
put should start filling of an unused buffer, checking if that buffer's READY flag is not asserted. When it starts, it should timestamp the buffer.
"get" should happen in transmisison thread. Once this thread accesses the memory slot pointed by the pointer gotten from the Tx_Queue, having checked that the READY flag is asserted, and after that slot is transmitted successfully, then READY flag should be deasserted, signaling the put mechanism in the Rx_Queue that the slot is available for rewriting.
*/

// Gets the number of elements in an Rx_Queue_t queue
int Rx_QueueSize(Rx_Queue_t *pQ);

// initializes a Tx_Queue_t queue
Tx_Queue_t* Tx_QueueInit();

// destroys an Rx_Queue_t queue
void Tx_QueueDestroy(Tx_Queue_t *pQ);

// Adds a new element to an Tx_Queue_t queue
void Tx_QueuePut(Tx_Queue_t *pQ, Rx_Buffer_t * elem);

// Gets and removes an element from an Tx_Queue_t queue
Rx_Buffer_t * Tx_QueueGet(Tx_Queue_t *pQ);

// Gets the number of elements in an Rx_Queue_t queue
int Tx_QueueSize(Tx_Queue_t *pQ);

////ADQUISITION THREAD
// initializes an Adq_Thread_t
Adq_Thread_t * AdqThreadInit(Rx_Queue_t * rxQ, Tx_Queue_t * txQ, const uint8_t bd_id, const uint8_t ch_id);

// destroys an Adq_Thread_t
void AdqThreadDestroy(Adq_Thread_t * adqTh);

// function to be run by the adquisition thread
void * adqTh_threadFunc(void * ctx);

// sets an adquisition thread to run
void AdqThreadRun(Adq_Thread_t * adqTh);

// stops an adquisition thread
void AdqThreadStop(Adq_Thread_t * adqTh);

///TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t * TxThreadInit(Tx_Queue_t * txQ, char * server_addr, const int server_portno);

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t * txTh);

// function to be run by a transmission thread
void * txTh_threadFunc(void * ctx);

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t * txTh);

// stops a transmission thread
void TxThreadStop(Tx_Thread_t * txTh);