/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
TCP server functions

Version: 2020-10-24
Comments: Needs checking for 16 channel implementation
*/

#ifndef TCPSERVER_H_
#define TCPSERVER_H_

#define _GNU_SOURCE

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
#include <sys/stat.h>
#include <fcntl.h>

#include "server_queues.h"
#include "../../SistAdq_project//lib/error.h"
#include "../../SistAdq_project//lib/acqPack.h"
#include "../../SistAdq_project//lib/intMax.h"

#define MAX_CLIENT_THREADS 16

#define STDIN_BUF_LENGTH 32

struct Server_str;
typedef struct Server_str Server_t;

struct Cl_Thread_str;
typedef struct Cl_Thread_str Cl_Thread_t;

struct Cl_Thread_str
{
    uint8_t running;
    pthread_t th;

    int sockfd;
    Cl_Queue_t* pQ;

    Server_t* server;

    Cl_Thread_t* clThList_next;
};

struct Ch_File_Str;
typedef struct Ch_File_Str Ch_File_t;

typedef struct
{
    uint8_t running;
    pthread_t th;

    Server_t* server;

    Ch_File_t* chList_head;
} Proc_Thread_t;

struct Server_str
{
    int sockfd;
    socklen_t clilen;
    struct sockaddr_in cli_addr;

    sem_t sem_threads;

    Cl_Thread_t* clThList_head;
    sem_t clThList_sem;

    Th_Queue_t* thQ;

    Proc_Thread_t* prTh;

    int stop_flag;
};

////CLIENT THREAD
// initializes an Cl_Thread_t
Cl_Thread_t* ClThreadInit(Server_t* server);

// destroys a Cl_Thread_t
void ClThreadDestroy(Cl_Thread_t* clTh);

// sets a client thread to run
void ClThreadRun(Cl_Thread_t* clTh, int sockfd);

////PROCESSING THREAD
// initializes a Proc_Thread_t
Proc_Thread_t* ProcThreadInit(Server_t* server);

// destroys a Proc_Thread_t
void TCPProcThreadDestroy(Proc_Thread_t* prTh);

// sets a processing thread to run
void TCPProcThreadRun(Proc_Thread_t* prTh);

// stops a processing thread
void TCPProcThreadStop(Proc_Thread_t* prTh);

////SERVER
// initializes a Server_t
Server_t* TCPServerInit(int server_portno);

// destroys a Server_t
void TCPServerDestroy(Server_t* server);

// sets the server to run
void TCPServerRun(Server_t* server);

#endif //SERVER_H_