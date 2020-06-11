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
#include "../fdg/devQueue.h"
#include "client_queues.h"
#include "client_params.h"

struct Client_str;
typedef struct Client_str Client_t;

typedef struct
{
    Client_t * client;
    pthread_t th;
    int running;
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;
    Dev_Queue_t *devQ;  //this should be replaced to a pointer to wherever data comes from in a "real" implementation
} Acq_Thread_t;

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

struct Client_str
{
    Dev_Queue_t * devQ; //this should be replaced to a pointer to wherever data comes from in a "real" implementation
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;

    Acq_Thread_t * acqTh;
    Tx_Thread_t * txTh;

    CaptureMode_t capMode;
    TriggerMode_t trigMode;

    int eventfd_out;

    int timerfd_start;

    int timerfd_stop;
    struct itimerspec timerfd_stop_spec;
    
    int eventfd_samples;
    int n_samples;
};

////ADQUISITION THREAD
// initializes an Acq_Thread_t
Acq_Thread_t * AcqThreadInit(Client_t * client, Rx_Queue_t * rxQ, Tx_Queue_t * txQ, const uint8_t bd_id, const uint8_t ch_id, Dev_Queue_t * devQ);

// destroys an Acq_Thread_t
void AcqThreadDestroy(Acq_Thread_t * acqTh);

// sets an acquisition thread to run
void AcqThreadRun(Acq_Thread_t * acqTh);

// stops an acquisition thread
void AcqThreadStop(Acq_Thread_t * acqTh);

///TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t * TxThreadInit(Tx_Queue_t * txQ, Rx_Queue_t * rxQ, char * server_addr, const int server_portno);

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t * txTh);

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t * txTh);

// stops a transmission thread
void TxThreadStop(Tx_Thread_t * txTh);

//// CLIENT
// initializes a Client_t
Client_t * ClientInit(Dev_Queue_t * devQ, int eventfd_out, ClParams_t * params);

// destroys a Client_t
void ClientDestroy(Client_t * client);

// runs a Client_t
void ClientRun(Client_t * client);

// stops a Client_t
void ClientStop(Client_t * client);

#endif //CLIENT_H_