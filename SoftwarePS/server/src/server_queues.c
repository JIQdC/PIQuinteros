/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Server queues functions

Version: 2020-09-05
Comments:
*/

#include "server_queues.h"

////QUEUE
// initializes a Cl_Queue_t queue
Cl_Queue_t* Cl_QueueInit()
{
    //memory allocation for queue
    Cl_Queue_t* pQ = malloc(sizeof(Cl_Queue_t));
    //initialize basic elements
    pQ->get = 0;
    pQ->put = 0;
    pQ->q_size = CL_Q_SIZE;

    //initialize semaphores
    if (sem_init(&(pQ->sem_lock), 0, 1)<0) error("init of sem lock");
    if (sem_init(&(pQ->sem_get), 0, 0)<0) error("init of sem get");
    if (sem_init(&(pQ->sem_put), 0, CL_Q_SIZE)<0) error("init of sem put");

    return pQ;
}

// destroys a Cl_Queue_t queue
void Cl_QueueDestroy(Cl_Queue_t* pQ)
{
    //destroy semaphores
    if (sem_destroy(&(pQ->sem_lock))<0) error("destroy of sem lock");
    if (sem_destroy(&(pQ->sem_get))<0) error("destroy of sem get");
    if (sem_destroy(&(pQ->sem_put))<0) error("destroy of sem put");

    //release memory
    free(pQ);
}

// Adds a new element to a Cl_Queue_t queue
void Cl_QueuePut(Cl_Queue_t* pQ, const AcqPack_t* elem)
{
    //wait for put semaphore for available space in queue
    if (sem_wait(&(pQ->sem_put))<0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if (sem_wait(&(pQ->sem_lock))<0) error("sem_wait of sem_lock");

#ifdef _DEBUG
    //queue state
    elem->cl_qstate = Cl_QueueSize(pQ);
#endif

    //write element in queue
    pQ->elements[pQ->put & CL_Q_MASK] = *elem;

    //increase put counter
    pQ->put++;

    //post get semaphore
    if (sem_post(&(pQ->sem_get))<0) error("sem_post of sem_get");
    //post lock semaphore
    if (sem_post(&(pQ->sem_lock))<0) error("sem_post of sem_lock");
}

// Gets and removes an element from a Cl_Queue_t queue
void Cl_QueueGet(Cl_Queue_t* pQ, AcqPack_t* result)
{
    //wait for get semaphore for available space in queue
    if (sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
    //wait for queue lock semaphore
    if (sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    *result = pQ->elements[pQ->get & CL_Q_MASK];

    //increase get counter
    pQ->get++;

    //post put semaphore
    if (sem_post(&(pQ->sem_put))<0) error("sem_post de sem_put");
    //post lock semaphore
    if (sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");
}

// Gets the number of elements in a Cl_Queue_t queue
int Cl_QueueSize(Cl_Queue_t* pQ)
{
    if (pQ == NULL) return 0;
    int dif = (pQ->put - pQ->get)& CL_Q_MASK;
    if (dif>=0)
    {
        return dif;
    }
    else
    {
        return CL_Q_SIZE - dif;
    }
}

// initializes a Th_Queue_t queue
Th_Queue_t* Th_QueueInit()
{
    //memory allocation for queue
    Th_Queue_t* pQ = malloc(sizeof(Cl_Queue_t));
    //initialize basic elements
    pQ->get = 0;
    pQ->put = 0;
    pQ->q_size = TH_Q_SIZE;

    //initialize semaphores
    if (sem_init(&(pQ->sem_lock), 0, 1)<0) error("init of sem lock");
    if (sem_init(&(pQ->sem_get), 0, 0)<0) error("init of sem get");
    if (sem_init(&(pQ->sem_put), 0, CL_Q_SIZE)<0) error("init of sem put");

    return pQ;
}

// destroys a Th_Queue_t queue
void Th_QueueDestroy(Th_Queue_t* pQ)
{
    //destroy semaphores
    if (sem_destroy(&(pQ->sem_lock))<0) error("destroy of sem lock");
    if (sem_destroy(&(pQ->sem_get))<0) error("destroy of sem get");
    if (sem_destroy(&(pQ->sem_put))<0) error("destroy of sem put");

    //release memory
    free(pQ);
}

// Adds a new element to a Th_Queue_t queue
void Th_QueuePut(Th_Queue_t* pQ, Cl_Thread_t* elem)
{
    //wait for put semaphore for available space in queue
    if (sem_wait(&(pQ->sem_put))<0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if (sem_wait(&(pQ->sem_lock))<0) error("sem_wait of sem_lock");

    //write element in queue
    pQ->elements[pQ->put & TH_Q_MASK] = elem;

    //increase put counter
    pQ->put++;

    //post get semaphore
    if (sem_post(&(pQ->sem_get))<0) error("sem_post of sem_get");
    //post lock semaphore
    if (sem_post(&(pQ->sem_lock))<0) error("sem_post of sem_lock");
}

// Gets and removes an element from a Th_Queue_t queue
Cl_Thread_t* Th_QueueGet(Th_Queue_t* pQ)
{
    Cl_Thread_t* result;

    //wait for get semaphore for available space in queue
    if (sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
    //wait for queue lock semaphore
    if (sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    result = pQ->elements[pQ->get & TH_Q_MASK];

    //increase get counter
    pQ->get++;

    //post put semaphore
    if (sem_post(&(pQ->sem_put))<0) error("sem_post de sem_put");
    //post lock semaphore
    if (sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");

    return result;
}

// Gets the number of elements in a Th_Queue_t queue
int Th_QueueSize(Th_Queue_t* pQ)
{
    int dif = (pQ->put - pQ->get)& TH_Q_MASK;
    if (dif>=0)
    {
        return dif;
    }
    else
    {
        return TH_Q_SIZE - dif;
    }
}