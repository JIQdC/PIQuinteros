#ifndef CLIENT_H_
#define CLIENT_H_

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
#include <sys/timerfd.h>

#include "../lib/error.h"
#include "../lib/buffer.h"
#include "devQueue.h"

#define RX_Q_SIZE_LOG2 6
#define RX_Q_SIZE (1<<RX_Q_SIZE_LOG2)
#define RX_Q_MASK (RX_Q_SIZE - 1)

#define TX_Q_SIZE_LOG2 6
#define TX_Q_SIZE (1<<TX_Q_SIZE_LOG2)
#define TX_Q_MASK (TX_Q_SIZE - 1)

struct Client_str;
typedef struct Client_str Client_t;

typedef struct
{
    sem_t sem;

    int acq;
    int rls;
    int q_size;

    Buffer_t elements[RX_Q_SIZE];
} Rx_Queue_t;

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    Buffer_t * elements[TX_Q_SIZE];
} Tx_Queue_t;

typedef struct
{
    Client_t * client;
    pthread_t th;
    int running;
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;
    Dev_Queue_t *devQ;  //this should be replaced to a pointer to wherever data comes from in a "real" implementation
} Adq_Thread_t;

typedef struct
{
    pthread_t th;
    int running;
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;
    char *server_addr;
    int server_portno;
    int sockfd;
} Tx_Thread_t;

typedef enum
{
    sampleNumber,
    timeInterval
} CaptureMode_t;

typedef enum
{
    manual,
    timer
} TriggerMode_t;

struct Client_str
{
    Dev_Queue_t * devQ; //this should be replaced to a pointer to wherever data comes from in a "real" implementation
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;

    Adq_Thread_t * adqTh;
    Tx_Thread_t * txTh;

    char * serv_addr;
    int server_portno;

    int eventfd_out;

    CaptureMode_t capMode;
    TriggerMode_t trigMode;

    int timerfd_start;
    int timerfd_stop;
    struct itimerspec timerfd_stop_spec;
    int eventfd_samples;
    int n_samples;
};

////QUEUES
// initializes an Rx_Queue_t queue
Rx_Queue_t* Rx_QueueInit();

// destroys an Rx_Queue_t queue
void Rx_QueueDestroy(Rx_Queue_t *pQ);

// Gets the number of elements in an Rx_Queue_t queue
int Rx_QueueSize(Rx_Queue_t *pQ);

// Returns a pointer to a free Buffer_t
Buffer_t * Rx_Queue_Acquire(Rx_Queue_t *q);

// Releases an Buffer_t making it ready to be reused
void Rx_Queue_Release(Rx_Queue_t *q, Buffer_t * rxBuf);

// initializes a Tx_Queue_t queue
Tx_Queue_t* Tx_QueueInit();

// destroys a Tx_Queue_t queue
void Tx_QueueDestroy(Tx_Queue_t *pQ);

// Adds a new element to a Tx_Queue_t queue
void Tx_QueuePut(Tx_Queue_t *pQ, Buffer_t * elem);

// Gets and removes an element from a Tx_Queue_t queue
Buffer_t * Tx_QueueGet(Tx_Queue_t *pQ);

// Gets the number of elements in a Tx_Queue_t queue
int Tx_QueueSize(Tx_Queue_t *pQ);

////ADQUISITION THREAD
// initializes an Adq_Thread_t
Adq_Thread_t * AdqThreadInit(Client_t * client, Rx_Queue_t * rxQ, Tx_Queue_t * txQ, const uint8_t bd_id, const uint8_t ch_id, Dev_Queue_t * devQ);

// destroys an Adq_Thread_t
void AdqThreadDestroy(Adq_Thread_t * adqTh);

// acquires a buffer, fills it with data, and passes it to Tx_Queue
void acquireFillPass(Adq_Thread_t * adqTh);

// function to be run by the adquisition thread
void * adqTh_threadFunc(void * ctx);

// sets an adquisition thread to run
void AdqThreadRun(Adq_Thread_t * adqTh);

// stops an adquisition thread
void AdqThreadStop(Adq_Thread_t * adqTh);

///TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t * TxThreadInit(Tx_Queue_t * txQ, Rx_Queue_t * rxQ, char * server_addr, const int server_portno);

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t * txTh);

// writes a msg into sockfd. Retries writing until full msg is sent. Returns 0 on success, -1 on write error, 1 on connection closed
int socketWrite(int sockfd, void * msg, size_t size_msg);

// function to be run by a transmission thread
void * txTh_threadFunc(void * ctx);

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t * txTh);

// stops a transmission thread
void TxThreadStop(Tx_Thread_t * txTh);

//// CLIENT
// initializes a Client_t
Client_t * ClientInit(Dev_Queue_t * devQ, uint8_t bd_id, uint8_t ch_id, char * server_addr, int server_portno, int eventfd_out, CaptureMode_t capMode, TriggerMode_t trigMode);

// destroys a Client_t
void ClientDestroy(Client_t * client);

// runs a Client_t
void ClientRun(Client_t * client);

// stops a Client_t
void ClientStop(Client_t * client);

#endif //CLIENT_H_