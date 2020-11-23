/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Client control functions for CIAA-ACC

Version: 2020-11-21
Comments:
*/

#ifndef SRC_CLIENT_FUNCTIONS_H_
#define SRC_CLIENT_FUNCTIONS_H_

#include <pthread.h>
#include <sys/eventfd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include "AXI_control.h"
#include "SPI_control.h"
#include "client_queues.h"
#include "client_params.h"
#include "preproc_functions.h"

struct Client_str;
typedef struct Client_str Client_t;

typedef struct
{
    Client_t* client;
    pthread_t th;
    int running;

    Multi_MemPtr_t* multiPtr_flags;
    Multi_MemPtr_t* multiPtr_data;
    Multi_MemPtr_t* multiPtr_progfull;
} Acq_Thread_t;

typedef struct
{
    pthread_t th;
    int running;
    Client_t* client;
    struct sockaddr_in serv_addr;
    int sockfd;
    int fout;
} Tx_Thread_t;

struct Client_str
{
    Rx_Queue_t* rxQ;
    Tx_Queue_t* txQ;

    Acq_Thread_t* acqTh;
    Tx_Thread_t* txTh;

    int timerfd_start;

    int timerfd_stop;

    int eventfd;

    ClParams_t* params;
};

////ACQUISITION THREAD

// initializes an Acq_Thread_t
Acq_Thread_t* AcqThreadInit(Client_t* client);

// destroys an Acq_Thread_t
void AcqThreadDestroy(Acq_Thread_t* acqTh);

// sets an acquisition thread to run
void AcqThreadRun(Acq_Thread_t* acqTh);

// stops an acquisition thread
void AcqThreadStop(Acq_Thread_t* acqTh);

//// TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t* TxThreadInit(Client_t* client, char* server_addr, const int server_portno);

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t* txTh);

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t* txTh);

// stops a transmission thread
void TxThreadStop(Tx_Thread_t* txTh);

//// CLIENT
// initializes a Client_t
Client_t* ClientInit(ClParams_t* params);

// destroys a Client_t
void ClientDestroy(Client_t* client);

// stops a Client_t
void ClientStop(Client_t* client);

// runs a Client_t
void ClientRun(Client_t* client);

#endif //SRC_CLIENT_FUNCTIONS_H