#ifndef SERVER_H_
#define SERVER_H_

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

#include "../lib/error.h"
#include "../lib/buffer.h"
#include "../lib/intMax.h"

#define MAX_CLIENT_THREADS 16

#define CL_Q_SIZE_LOG2 6
#define CL_Q_SIZE (1<<CL_Q_SIZE_LOG2)
#define CL_Q_MASK (CL_Q_SIZE - 1)

#define TH_Q_SIZE_LOG2 6
#define TH_Q_SIZE (1<<TH_Q_SIZE_LOG2)
#define TH_Q_MASK (TH_Q_SIZE - 1)

#define STDIN_BUF_LENGTH 32

struct Server_str;
typedef struct Server_str Server_t;

struct Cl_Thread_str;
typedef struct Cl_Thread_str Cl_Thread_t;

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    Buffer_t elements[CL_Q_SIZE];
} Cl_Queue_t;

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    Cl_Thread_t * elements[TH_Q_SIZE];
} Th_Queue_t;

struct Cl_Thread_str
{
    uint8_t running;
    pthread_t th;

    int sockfd;
    Cl_Queue_t * pQ;

    Server_t * server;

    Cl_Thread_t * clThList_next;
};

struct Ch_File_Str;
typedef struct Ch_File_Str Ch_File_t;

struct Ch_File_Str
{
    uint8_t ch_id;
    FILE * f;
    Ch_File_t * chList_next;
};

typedef struct
{
    uint8_t running;
    pthread_t th;

    Server_t * server;

    Ch_File_t * chList_head;
} Proc_Thread_t;

struct Server_str
{
    int sockfd;
    socklen_t clilen;
    struct sockaddr_in cli_addr;

    sem_t sem_threads;

    Cl_Thread_t * clThList_head;
    sem_t clThList_sem;

    Th_Queue_t * thQ;

    Proc_Thread_t * prTh;

    int stop_flag;
};

////QUEUE
// initializes a Cl_Queue_t queue
Cl_Queue_t* Cl_QueueInit();

// destroys a Cl_Queue_t queue
void Cl_QueueDestroy(Cl_Queue_t *pQ);

// Adds a new element to a Cl_Queue_t queue
void Cl_QueuePut(Cl_Queue_t *pQ, Buffer_t elem);

// Gets and removes an element from a Cl_Queue_t queue
Buffer_t Cl_QueueGet(Cl_Queue_t *pQ);

// Gets the number of elements in a Cl_Queue_t queue
int Cl_QueueSize(Cl_Queue_t *pQ);

// initializes a Th_Queue_t queue
Th_Queue_t* Th_QueueInit();

// destroys a Th_Queue_t queue
void Th_QueueDestroy(Th_Queue_t *pQ);

// Adds a new element to a Th_Queue_t queue
void Th_QueuePut(Th_Queue_t *pQ, Cl_Thread_t * elem);

// Gets and removes an element from a Th_Queue_t queue
Cl_Thread_t * Th_QueueGet(Th_Queue_t *pQ);

// Gets the number of elements in a Th_Queue_t queue
int Th_QueueSize(Th_Queue_t *pQ);

////CLIENT THREAD
// initializes an Cl_Thread_t
Cl_Thread_t * ClThreadInit(Server_t * server);

// destroys a Cl_Thread_t
void ClThreadDestroy(Cl_Thread_t * clTh);

// reads msg_size bytes from socket and place them into msg. Retries reading until full msg is read. Returns 0 on success, -1 on read error, 1 on connection closed.
int socketRead(int sockfd, void * msg, size_t size_msg);

// close connection on a thread and prepare it to be joined
void closeConnection(Cl_Thread_t * clTh, Server_t * server);

// function to be run by the client thread
void * clTh_threadFunc(void * ctx);

// sets a client thread to run
void ClThreadRun(Cl_Thread_t * clTh, int sockfd);

////PROCESSING THREAD
// initializes a Proc_Thread_t
Proc_Thread_t * ProcThreadInit(Server_t * server);

// destroys a Proc_Thread_t
void ProcThreadDestroy(Proc_Thread_t * prTh);

// opens a channel file with current time_ch_id as filename. writes header for Buffer_t
Ch_File_t * chFileOpen(Proc_Thread_t * prTh, uint8_t ch_id);

// writes a Buffer_t into ch_file
void chFileWriteBuffer(const Buffer_t * buf,Ch_File_t * chF);

// function to be run by the processing thread
void * procTh_threadFunc(void * ctx);

// sets a processing thread to run
void ProcThreadRun(Proc_Thread_t * prTh);

// stops a processing thread
void ProcThreadStop(Proc_Thread_t * prTh);

////SERVER
// initializes a Server_t
Server_t * ServerInit(int server_portno);

// destroys a Server_t
void ServerDestroy(Server_t * server);

// join pending threads from server thread queue
void joinPendingThreads(Server_t * server);

// sets the server to run
void ServerRun(Server_t * server);

#endif //SERVER_H_