/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Server queues functions

Version: 2020-09-05
Comments:
*/

#ifndef SERVER_QUEUES_H_
#define SERVER_QUEUES_H_

#include <stdlib.h>
#include <semaphore.h>
#include "../../SistAdq_project/lib/error.h"
#include "../../SistAdq_project/lib/acqPack.h"

#define CL_Q_SIZE_LOG2 6
#define CL_Q_SIZE (1<<CL_Q_SIZE_LOG2)
#define CL_Q_MASK (CL_Q_SIZE - 1)

#define TH_Q_SIZE_LOG2 6
#define TH_Q_SIZE (1<<TH_Q_SIZE_LOG2)
#define TH_Q_MASK (TH_Q_SIZE - 1)

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    AcqPack_t elements[CL_Q_SIZE];
} Cl_Queue_t;

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

    Cl_Thread_t* elements[TH_Q_SIZE];
} Th_Queue_t;

////QUEUE
// initializes a Cl_Queue_t queue
Cl_Queue_t* Cl_QueueInit();

// destroys a Cl_Queue_t queue
void Cl_QueueDestroy(Cl_Queue_t* pQ);

// Adds a new element to a Cl_Queue_t queue
void Cl_QueuePut(Cl_Queue_t* pQ, const AcqPack_t* elem);

// Gets and removes an element from a Cl_Queue_t queue
void Cl_QueueGet(Cl_Queue_t* pQ, AcqPack_t* result);

// Gets the number of elements in a Cl_Queue_t queue
int Cl_QueueSize(Cl_Queue_t* pQ);

// initializes a Th_Queue_t queue
Th_Queue_t* Th_QueueInit();

// destroys a Th_Queue_t queue
void Th_QueueDestroy(Th_Queue_t* pQ);

// Adds a new element to a Th_Queue_t queue
void Th_QueuePut(Th_Queue_t* pQ, Cl_Thread_t* elem);

// Gets and removes an element from a Th_Queue_t queue
Cl_Thread_t* Th_QueueGet(Th_Queue_t* pQ);

// Gets the number of elements in a Th_Queue_t queue
int Th_QueueSize(Th_Queue_t* pQ);

#endif //SERVER_QUEUES_H_