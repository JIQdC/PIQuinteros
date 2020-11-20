#include "client_queues.h"

// initializes an Rx_Queue_t queue
Rx_Queue_t* Rx_QueueInit()
{
    //memory allocation for queue
    Rx_Queue_t* pQ = malloc(sizeof(Rx_Queue_t));

    //initialize basic elements
    pQ->acq = 0;
    pQ->rls = 0;
    pQ->q_size = RX_Q_SIZE;

    //initialize semaphore
    if(sem_init(&pQ->sem,0,RX_Q_SIZE)<0) error("sem_init in Rx_Queue");
    
    return pQ;
}

// destroys an Rx_Queue_t queue
void Rx_QueueDestroy(Rx_Queue_t *pQ)
{
    free(pQ);
}

// Gets the number of elements in an Rx_Queue_t queue
int Rx_QueueSize(Rx_Queue_t *pQ)
{
    int dif = (pQ->acq - pQ->rls) & RX_Q_MASK;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return RX_Q_SIZE - dif;
    }
}

// Returns a pointer to a free AcqPack_t
AcqPack_t * Rx_Queue_Acquire(Rx_Queue_t *q)
{
    sem_wait(&q->sem);
    AcqPack_t * ret = &(q->elements[q->acq++ & RX_Q_MASK]);
    #ifdef _DEBUG
    ret->rx_qstate = Rx_QueueSize(q);
    #endif
    return ret;
}

// Releases an Buffer_t making it ready to be reused
void Rx_Queue_Release(Rx_Queue_t *q, AcqPack_t * rxBuf)
{
	sem_post(&q->sem);
    q->rls++;
}

// initializes a Tx_Queue_t queue
Tx_Queue_t* Tx_QueueInit()
{
    //memory allocation for queue
    Tx_Queue_t* pQ = malloc(sizeof(Tx_Queue_t));
    //initialize basic elements
    pQ->get = 0;
    pQ->put = 0;
    pQ->q_size = TX_Q_SIZE;

    //initialize semaphores
    if(sem_init(&(pQ->sem_lock),0,1)<0) error("init of sem lock");
    if(sem_init(&(pQ->sem_get),0,0)<0) error("init of sem get");
    if(sem_init(&(pQ->sem_put),0,TX_Q_SIZE)<0) error("init of sem put");

    return pQ;
}

// destroys a Tx_Queue_t queue
void Tx_QueueDestroy(Tx_Queue_t *pQ)
{
    //destroy semaphores
    if(sem_destroy(&(pQ->sem_lock))<0) error("destroy of sem lock");
    if(sem_destroy(&(pQ->sem_get))<0) error("destroy of sem get");
    if(sem_destroy(&(pQ->sem_put))<0) error("destroy of sem put");

    //release memory
    free(pQ);
}

// Adds a new element to a Tx_Queue_t queue
void Tx_QueuePut(Tx_Queue_t *pQ, AcqPack_t * elem)
{
    //wait for put semaphore for available space in queue
    if(sem_wait(&(pQ->sem_put))<0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait of sem_lock");

    #ifdef _DEBUG
    //queue status
    elem->tx_qstate = Tx_QueueSize(pQ);
    #endif

    //write element in queue
    pQ->elements[pQ->put & TX_Q_MASK] = elem;

    //increase put counter
    pQ->put++;
    
    //post get semaphore
    if(sem_post(&(pQ->sem_get))<0) error("sem_post of sem_get");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post of sem_lock");
}

// Gets and removes an element from a Tx_Queue_t queue
AcqPack_t * Tx_QueueGet(Tx_Queue_t *pQ)
{
    AcqPack_t * result;

    //wait for get semaphore for available space in queue
    if(sem_wait(&(pQ->sem_get)) < 0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    result = pQ->elements[pQ->get & TX_Q_MASK];

    //increase get counter
    pQ->get++;

    //post put semaphore
    if(sem_post(&(pQ->sem_put))<0) error("sem_post de sem_put");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");

    return result;
}

// Gets the number of elements in a Tx_Queue_t queue
int Tx_QueueSize(Tx_Queue_t *pQ)
{
    int dif = (pQ->put - pQ->get)& TX_Q_MASK;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return TX_Q_SIZE - dif;
    }
}