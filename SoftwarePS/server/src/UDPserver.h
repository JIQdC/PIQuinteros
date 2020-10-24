/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
UDP server functions

Version: 2020-10-24
Comments:
*/

#ifndef UDPSERVER_H_
#define UDPSERVER_H_

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
#include "../../SistAdq_project/lib/error.h"
#include "../../SistAdq_project/lib/acqPack.h"
#include "../../SistAdq_project/lib/intMax.h"
#include "../../SistAdq_project/lib/dateFormatter.h"

#define STDIN_BUF_LENGTH 32

struct Server_str;
typedef struct Server_str Server_t;

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

    Cl_Queue_t* clQ;

    Proc_Thread_t* prTh;

    int stop_flag;
};

////PROCESSING THREAD
// initializes a Proc_Thread_t
Proc_Thread_t* ProcThreadInit(Server_t* server);

// destroys a Proc_Thread_t
void ProcThreadDestroy(Proc_Thread_t* prTh);

// sets a processing thread to run
void ProcThreadRun(Proc_Thread_t* prTh);

// stops a processing thread
void ProcThreadStop(Proc_Thread_t* prTh);

////SERVER
// initializes a Server_t
Server_t* ServerInit(int server_portno);

// destroys a Server_t
void ServerDestroy(Server_t* server);

// sets the server to run
void ServerRun(Server_t* server);

#endif //SERVER_H_