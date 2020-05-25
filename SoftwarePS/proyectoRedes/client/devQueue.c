#include "devQueue.h"

////QUEUES
// initializes a Dev_Queue_t queue
Dev_Queue_t* Dev_QueueInit()
{
    //memory allocation for queue
    Dev_Queue_t* pQ = malloc(sizeof(Dev_Queue_t));
    //initialize basic elements
    pQ->get = 0;
    pQ->put = 0;
    pQ->q_size = DEV_Q_SIZE;

    //initialize semaphores
    if(sem_init(&(pQ->sem_lock),0,1)<0) error("init of sem lock");
    if(sem_init(&(pQ->sem_get),0,0)<0) error("init of sem get");
    if(sem_init(&(pQ->sem_put),0,DEV_Q_SIZE)<0) error("init of sem put");
    return pQ;
}

// destroys a Dev_Queue_t queue
void Dev_QueueDestroy(Dev_Queue_t *pQ)
{
    //destroy semaphores
    if(sem_destroy(&(pQ->sem_lock))<0) error("destroy of sem lock");
    if(sem_destroy(&(pQ->sem_get))<0) error("destroy of sem get");
    if(sem_destroy(&(pQ->sem_put))<0) error("destroy of sem put");

    //release memory
    free(pQ);
}

// Adds a new element to a Dev_Queue_t queue
void Dev_QueuePut(Dev_Queue_t *pQ, uint16_t elem)
{
     //wait for put semaphore for available space in queue
    if(sem_wait(&(pQ->sem_put))<0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait of sem_lock");

    //write element in queue
    pQ->elements[pQ->put & DEV_Q_MASK] = elem;

    //increase put counter
    pQ->put++;
    
    //post get semaphore
    if(sem_post(&(pQ->sem_get))<0) error("sem_post of sem_get");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post of sem_lock");
}

// Gets and removes an element from a Dev_Queue_t queue
uint16_t Dev_QueueGet(Dev_Queue_t *pQ)
{
    uint16_t result;

    //wait for get semaphore for available space in queue
    if(sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    result = pQ->elements[pQ->get & DEV_Q_MASK];

    //increase get counter
    pQ->get++;

    //post put semaphore
    if(sem_post(&(pQ->sem_put))<0) error("sem_post de sem_put");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");

    return result;
}

// Gets the number of elements in a Dev_Queue_t queue
int Dev_QueueSize(Dev_Queue_t *pQ)
{
    int dif = (pQ->put - pQ->get) & DEV_Q_MASK;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return DEV_Q_SIZE - dif;
    }
}