#include "client.h"

////QUEUES
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

// Returns a pointer to a free Buffer_t
Buffer_t * Rx_Queue_Acquire(Rx_Queue_t *q)
{
    sem_wait(&q->sem);
    Buffer_t * ret = &(q->elements[q->acq++ & RX_Q_MASK]);
    #ifdef _DEBUG
    ret->rx_qstate = Rx_QueueSize(q);
    #endif
    return ret;
}

// Releases an Buffer_t making it ready to be reused
void Rx_Queue_Release(Rx_Queue_t *q, Buffer_t * rxBuf)
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
void Tx_QueuePut(Tx_Queue_t *pQ, Buffer_t * elem)
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
Buffer_t * Tx_QueueGet(Tx_Queue_t *pQ)
{
    Buffer_t * result;

    //wait for get semaphore for available space in queue
    if(sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
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

////ADQUISITION THREAD

// initializes an Adq_Thread_t
Adq_Thread_t * AdqThreadInit(Client_t * client, Rx_Queue_t * rxQ, Tx_Queue_t * txQ, const uint8_t bd_id, const uint8_t ch_id, Dev_Queue_t * devQ)
{
    Adq_Thread_t * adqTh = malloc(sizeof(Adq_Thread_t));

    adqTh->client = client;

    adqTh->rxQ = rxQ;
    adqTh->txQ = txQ;
    adqTh->devQ = devQ;

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

// acquires a buffer, fills it with data, and passes it to Tx_Queue
void acquireFillPass(Adq_Thread_t * adqTh)
{
    Rx_Queue_t * rxQ = adqTh->rxQ;
    Tx_Queue_t * txQ = adqTh->txQ;
    Dev_Queue_t * devQ = adqTh->devQ;

    Buffer_t * rxBuf;

    int i;

    uint16_t dev_data;

    //acquire a free Buffer_t
    rxBuf = Rx_Queue_Acquire(rxQ);

    //timestamp this buffer
    if(clock_gettime(CLOCK_REALTIME,&rxBuf->tp)<0) error("clock_gettime in adqTh");
    
    //fill buffer with data from FakeDataGen    
    for(i=0;i<BUF_SIZE;i++)
    {
        dev_data = Dev_QueueGet(devQ);
        rxBuf->data[i]= dev_data;
    }    

    //put buffer in Tx_Queue
    Tx_QueuePut(txQ,rxBuf);
}

// function to be run by the adquisition thread
void * adqTh_threadFunc(void * ctx)
{
    Adq_Thread_t * adqTh = (Adq_Thread_t *) ctx;
    uint64_t wr_buf;

    if(adqTh->client->capMode == sampleNumber)
    {
        //capture until reaching the required number of samples or thread is stopped
        while(adqTh->running && (adqTh->devQ->get < adqTh->client->n_samples)) acquireFillPass(adqTh);
        //notify client
        wr_buf = 1;
        write(adqTh->client->eventfd_samples,&wr_buf,sizeof(wr_buf));
    }
    else
    {
        //capture until thread is stopped
        while(adqTh->running) acquireFillPass(adqTh);
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
Tx_Thread_t * TxThreadInit(Tx_Queue_t * txQ, Rx_Queue_t * rxQ, char * server_addr, const int server_portno)
{
    struct sockaddr_in serv_addr;
    memset(&serv_addr,0,sizeof(serv_addr));

    struct hostent *server;

    //allocate memory for Tx_Thread_t
    Tx_Thread_t * txTh = malloc(sizeof(Tx_Thread_t));

    //assign transmission and reception queue
    txTh->txQ = txQ;
    txTh->rxQ = rxQ;

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
    serv_addr.sin_family = AF_INET;
    bcopy((char *)server->h_addr_list[0], 
         (char *)&serv_addr.sin_addr.s_addr,
         server->h_length);    //use port passed as argument
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

// writes a msg to sockfd. Retries writing until full msg is sent. Returns 0 on success, -1 on write error, 1 on connection closed
int socketWrite(int sockfd, void * msg, size_t size_msg)
{
    int n;

    //cast msg to char * to be able to chop it
    char * msg_c = (char *) msg;

    n = write(sockfd,msg_c,size_msg);

    if(n == size_msg)
    {
        return 0;
    }
    else if(n > 0)
    {
        return socketWrite(sockfd,msg_c+n,size_msg-n);
    }
    else if(n == 0)
    {
        //is this the correct way of asserting that the connection is closed by the server?
        //should I try reading from socket instead?
        return 1;
    }
    else // n < 0
    {
        return -1;
    }    
}

// function to be run by a transmission thread
void * txTh_threadFunc(void * ctx)
{
    Tx_Thread_t * txTh = (Tx_Thread_t *) ctx;
    Tx_Queue_t * txQ = txTh->txQ;
    Rx_Queue_t * rxQ = txTh->rxQ;
    Buffer_t * rxBuf;

    int wr_ret;

    while(txTh->running)
    {
        //capture from Tx_Queue
        rxBuf = Tx_QueueGet(txQ);

        //send buffer to socket
        wr_ret = socketWrite(txTh->sockfd,rxBuf,sizeof(Buffer_t));
        if(wr_ret > 0)
        {
            //do something for closed server. Die perhaps?
        }
        if(wr_ret < 0) error("socket write in txTh");

        //release buffer
        Rx_Queue_Release(rxQ,rxBuf);
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

//// CLIENT
// initializes a Client_t
Client_t * ClientInit(Dev_Queue_t * devQ, uint8_t bd_id, uint8_t ch_id, char * server_addr, int server_portno, int eventfd_out, CaptureMode_t capMode, TriggerMode_t trigMode)
{
    Client_t * client = malloc(sizeof(Client_t));

    struct tm time_br;
    struct timespec time_sp;
    struct itimerspec timerfd_start_spec;

    //devQ is external
    client->devQ = devQ;
    //rx and tx queues must be initialized
    client->rxQ = Rx_QueueInit();
    client->txQ = Tx_QueueInit();

    //initialize threads
    client->adqTh = AdqThreadInit(client,client->rxQ,client->txQ,bd_id,ch_id,client->devQ);
    client->txTh = TxThreadInit(client->txQ,client->rxQ,server_addr,server_portno);

    //SYNC WITH FDG: eventfd initialized externally
    client->eventfd_out = eventfd_out;

    //modes passed as argument
    client->capMode = capMode;
    client->trigMode = trigMode;

    switch (client->capMode)
    {
    case sampleNumber:
        //initialize eventfd for adqTh notification
        client->eventfd_samples = eventfd(0,0);
        //get sample number from user        
        printf("ClientInit: Enter samples to acquire from Dev:");
        scanf("%d",&client->n_samples);
        break;

    case timeInterval:
        //set stop time to 0
        memset(&client->timerfd_stop_spec,0,sizeof(client->timerfd_stop_spec));
        //get time interval from user
        printf("ClientInit: enter time interval for capture (in seconds): ");
        scanf("%ld",&client->timerfd_stop_spec.it_value.tv_sec);
        //create timer
        client->timerfd_stop = timerfd_create(CLOCK_REALTIME,0);
        if(client->timerfd_stop < 0) error("timerfd_create in ClientInit");    
        break;

    default:
        break;
    }

    switch (client->trigMode)
    {
    case manual:
        //nothing to be done here. Manual trigger is set in ClientRun()
        break;
    
    case timer:
        //clear timer start time
        memset(&timerfd_start_spec,0,sizeof(timerfd_start_spec));
        //get local time
        if(clock_gettime(CLOCK_REALTIME,&time_sp)<0) error("clock_gettime in ClientInit");
        localtime_r(&time_sp.tv_sec,&time_br);
        //change hour, minute, second
        printf("ClientInit: enter start hour (0-23): ");
        scanf("%d",&time_br.tm_hour);
        printf("ClientInit: enter start minute (0-59): ");
        scanf("%d",&time_br.tm_min);
        printf("ClientInit: enter start second (0-59): ");
        scanf("%d",&time_br.tm_sec);
        //create and start timer
        timerfd_start_spec.it_value.tv_sec = mktime(&time_br);
        client->timerfd_start = timerfd_create(CLOCK_REALTIME,0);

        timerfd_settime(client->timerfd_start,TFD_TIMER_ABSTIME,&timerfd_start_spec,NULL);
        break;

    default:
        break;
    }

    return client;
}

// destroys a Client_t
void ClientDestroy(Client_t * client)
{
    TxThreadDestroy(client->txTh);
    AdqThreadDestroy(client->adqTh);
    Rx_QueueDestroy(client->rxQ);
    Tx_QueueDestroy(client->txQ);
    close(client->timerfd_start);
    close(client->timerfd_stop);
    close(client->eventfd_samples);
}

// stops a Client_t
void ClientStop(Client_t * client)
{
    TxThreadStop(client->txTh);
    AdqThreadStop(client->adqTh);
}

// runs a Client_t
void ClientRun(Client_t * client)
{
    uint64_t rd_buf,wr_buf;
    struct timespec tspec;

    switch (client->trigMode)
    {
        case manual:
            printf("Client ready to capture. Press any key to start capture...\n");
            getchar();
            getchar();
            break;
        
        case timer:
            printf("Client waiting for timer to run.\n");
            read(client->timerfd_start,&rd_buf,sizeof(rd_buf));
            break;
        default:
            break;
    }

    clock_gettime(CLOCK_REALTIME,&tspec);
    printf("Client started capture at time %s",ctime(&tspec.tv_sec));
    //if capture with time interval, start this timer
    if(client->capMode == timeInterval)
    {
        timerfd_settime(client->timerfd_stop,0,&client->timerfd_stop_spec,NULL);
    }

    //SYNC WITH FDG: signal outer world of start
    wr_buf = 1;
    write(client->eventfd_out,&wr_buf,sizeof(wr_buf));

    //run threads
    AdqThreadRun(client->adqTh);
    TxThreadRun(client->txTh);

    switch (client->capMode)
    {
    case sampleNumber:
        //wait for adqThread notification
        read(client->eventfd_samples,&rd_buf,sizeof(rd_buf));
        ClientStop(client);
        break;
    
    case timeInterval:
        //wait for time Interval
        read(client->timerfd_stop,&rd_buf,sizeof(rd_buf));
        ClientStop(client);
        break;
    default:
        break;
    }

    //SYNC WITH FDG: signal outer world of stopping
    wr_buf = 1;
    write(client->eventfd_out,&wr_buf,sizeof(wr_buf));
}