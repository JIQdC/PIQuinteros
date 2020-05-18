#include "client.h"

////QUEUES
// initializes an Rx_Queue_t queue
Rx_Queue_t* Rx_QueueInit()
{
    //memory allocation for queue
    Rx_Queue_t* pQ = malloc(sizeof(Rx_Queue_t));
    //initialize basic elements
    pQ->get = 0;
    pQ->put = 0;
    pQ->q_size = RX_Q_SIZE;

    //initialize semaphores for each buffer
    int i;
    for(i=0;i<RX_Q_SIZE;i++)
    {
        //semaphores start with 0 so that "get" mechanism locks on that. only the "put" mechanism can post to the semaphore, signaling to "get" that this slot can be obtained
        if(sem_init(&(pQ->elements[i].sem_lock),0,0)<0) error("init of sem_lock");
    }

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
    int dif = (pQ->put - pQ->get)%RX_Q_SIZE;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return RX_Q_SIZE - dif;
    }
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
void Tx_QueuePut(Tx_Queue_t *pQ, Rx_Buffer_t * elem)
{
    //wait for put semaphore for available space in queue
    if(sem_wait(&(pQ->sem_put))<0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait of sem_lock");

    //write element in queue
    pQ->elements[pQ->put % TX_Q_SIZE] = elem;

    //increase put counter
    pQ->put++;
    
    //post get semaphore
    if(sem_post(&(pQ->sem_get))<0) error("sem_post of sem_get");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post of sem_lock");
}

// Gets and removes an element from a Tx_Queue_t queue
Rx_Buffer_t * Tx_QueueGet(Tx_Queue_t *pQ)
{
    Rx_Buffer_t * result;

    //wait for get semaphore for available space in queue
    if(sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    result = pQ->elements[pQ->get % RX_Q_SIZE];

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
    int dif = (pQ->put - pQ->get)%TX_Q_SIZE;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return TX_Q_SIZE - dif;
    }
}

////ADQUISITION THREAD

// initializes an Adq_Thread_t
Adq_Thread_t * AdqThreadInit(Rx_Queue_t * rxQ, Tx_Queue_t * txQ, const uint8_t bd_id, const uint8_t ch_id)
{
    Adq_Thread_t * adqTh = malloc(sizeof(Adq_Thread_t));

    adqTh->rxQ = rxQ;
    adqTh->txQ = txQ;

    adqTh->running = 0;

    //stamp all buffers in rxQ with bd_id and ch_id
    int i;
    for(i=0;i<RX_Q_SIZE;i++)
    {
        rxQ->elements[i].bd_id = bd_id;
        rxQ->elements[i].ch_id = ch_id;
    }
    return adqTh;
}

// destroys an Adq_Thread_t
void AdqThreadDestroy(Adq_Thread_t * adqTh)
{
    free(adqTh);
}

// function to be run by the adquisition thread
void * adqTh_threadFunc(void * ctx)
{
    Adq_Thread_t * adqTh = (Adq_Thread_t *) ctx;
    Rx_Queue_t * rxQ = adqTh->rxQ;
    Tx_Queue_t * txQ = adqTh->txQ;

    int i;

    while(adqTh->running)
    {
        //timestamp 
        //TO BE IMPLEMENTED!!

        //fill buffer pointed by get with data from Dev_Queue

        
        
        //post semaphore of buffer
        if(sem_post(&(rxQ->elements[rxQ->get % RX_Q_SIZE].sem_lock)) < 0) error("sem_post of sem_lock");

        //put buffer in Tx_Queue
        Tx_QueuePut(txQ,&(rxQ->elements[rxQ->get % RX_Q_SIZE]));

    }

    //return to be joined
    return NULL;
}

// sets an adquisition thread to run
void AdqThreadRun(Adq_Thread_t * adqTh)
{
    if(adqTh->running == 1)
    {
        printf("Adquisition thread already running!\n");
        exit(1);
    }

    //assert running flag
    adqTh->running = 1;

    //create adquisition thread
    if(pthread_create(&adqTh->th,NULL,adqTh_threadFunc,adqTh) != 0) error("pthread_create of adqTh");
}

// stops an adquisition thread
void AdqThreadStop(Adq_Thread_t * adqTh)
{
    if(adqTh->running == 0)
    {
        printf("Adquisition thread already stopped!\n");
        exit(1);
    }

    //deassert running flag
    adqTh->running = 0;

    //wait for thread to finish and join
    if(pthread_join(adqTh->th,NULL) != 0) error("pthread_join of adqTh");
}

///TRANSMISSION THREAD

// initializes a Tx_Thread_t
Tx_Thread_t * TxThreadInit(Tx_Queue_t * txQ, char * server_addr, const int server_portno)
{
    struct sockaddr_in serv_addr;
    memset(&serv_addr,0,sizeof(serv_addr));

    struct hostent *server;

    //allocate memory for Tx_Thread_t
    Tx_Thread_t * txTh = malloc(sizeof(Tx_Thread_t));

    //assign transmission queue
    txTh->txQ = txQ;

    //save connection params (just in case we need them in the future)
    txTh->server_addr = server_addr;
    txTh->server_portno = server_portno;

    //open TCP/IP socket
    txTh->sockfd = socket(AF_INET,SOCK_STREAM,0);
    if(txTh->sockfd < 0) error("socket open in txTh");
    //find host
    server = gethostbyname(server_addr);
    if(server == NULL)
    {
        fprintf(stderr,"ERROR, no host found with that address\n");
        exit(1);
    }
    //get server address from host found
    memcpy(server->h_addr_list[0],&serv_addr.sin_addr.s_addr,server->h_length);
    //use port passed as argument
    serv_addr.sin_port=htons(server_portno);
    //connect to server
    if (connect(txTh->sockfd,(struct sockaddr *) &serv_addr,sizeof(serv_addr)) < 0) error("connect to server in txTh");
    printf("Client connected to %s:%d.\n",server_addr,server_portno);
    
    return txTh;
}

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t * txTh)
{
    //close connection with server
    close(txTh->sockfd);

    //release memory
    free(txTh);
}

// function to be run by a transmission thread
void * txTh_threadFunc(void * ctx)
{
    Tx_Thread_t * txTh = (Tx_Thread_t *) ctx;
    Tx_Queue_t * txQ = txTh->txQ;

    while(txTh->running)
    {
        //capture from Tx_Queue

        //send buffer to socket

        //mark buffer as ready to be written again by adquisition thread
    }

    //return to be joined
    return NULL;
}

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t * txTh)
{
    if(txTh->running == 1)
    {
        printf("Transmission thread is already running!\n");
        exit(1);
    }

    //assert running flag
    txTh->running = 1;

    //create thread
    if(pthread_create(&txTh->th,NULL,txTh_threadFunc,txTh) != 0) error ("pthread_create in txTh");
}

// stops a transmission thread
void TxThreadStop(Tx_Thread_t * txTh)
{
    if(txTh->running == 0)
    {
        printf("Transmission thread is already stopped!\n");
        exit(1);
    }

    //deassert running flag
    txTh->running = 0;

    //wait for thread to finish and join
    if(pthread_join(txTh->th,NULL) != 0) error("pthread_join in txTh");
}