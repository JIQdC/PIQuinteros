/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Client control functions for CIAA-ACC

Version: 2020-10-17
Comments:
*/

#include "client_functions.h"

////ACQUISITION THREAD
// initializes an Acq_Thread_t
Acq_Thread_t* AcqThreadInit(Client_t* client)
{
    Acq_Thread_t* acqTh = malloc(sizeof(Acq_Thread_t));

    acqTh->client = client;

    acqTh->running = 0;

    //map memory spaces to read FIFO flags and data
    uint32_t flags_addr[16], data_addr[16], progfull_addr;
    int i;
    for (i = 0; i < 16; i++)
    {
        flags_addr[i] = DATA_BASE_ADDR + FIFOFLAGS_OFF + 4 * i;
        data_addr[i] = DATA_BASE_ADDR + FIFODATA_OFF + 4 * i;
    }
    progfull_addr = DATA_BASE_ADDR + PROGFULL_OFF;

    acqTh->multiPtr_flags = multi_minit(flags_addr, 16);
    acqTh->multiPtr_data = multi_minit(data_addr, 16);
    acqTh->multiPtr_progfull = multi_minit(&progfull_addr, 1);

    return acqTh;
}

// destroys an Acq_Thread_t
void AcqThreadDestroy(Acq_Thread_t* acqTh)
{
    multi_mdestroy(acqTh->multiPtr_flags);
    multi_mdestroy(acqTh->multiPtr_data);
    multi_mdestroy(acqTh->multiPtr_progfull);
    free(acqTh);
}

// function to be run by the acquisition thread
static void* acqTh_threadFunc(void* ctx)
{
    Acq_Thread_t* acqTh = (Acq_Thread_t*)ctx;
    uint64_t wr_buf;
    AcqPack_t* acqPack = malloc(sizeof(AcqPack_t));

    int count = acqTh->client->n_samples;

    int i;

    //select FIFO data input from debug_control    
    for (i = 0; i < acqTh->multiPtr_data->mem_num; i++) debug_output(acqTh->client->debug_output, i);

    //enable FIFO input
    debug_enable();

    if (acqTh->client->capMode == sampleNumber)
    {
        //capture until reaching the required number of samples or thread is stopped
        while (acqTh->running && count--)
        {
            acqPack = Rx_Queue_Acquire(acqTh->client->rxQ);
            acquire_data(acqPack, acqTh->multiPtr_flags, acqTh->multiPtr_data, acqTh->multiPtr_progfull);
            //clk_divider
            acqPack->header.clk_divider = acqTh->client->clk_divider;
            Tx_QueuePut(acqTh->client->txQ, acqPack);
        }
        //notify client
        wr_buf = 1;
        write(acqTh->client->eventfd_samples, &wr_buf, sizeof(wr_buf));
    }
    else
    {
        //capture until thread is stopped
        while (acqTh->running)
        {
            acqPack = Rx_Queue_Acquire(acqTh->client->rxQ);
            acquire_data(acqPack, acqTh->multiPtr_flags, acqTh->multiPtr_data, acqTh->multiPtr_progfull);
            Tx_QueuePut(acqTh->client->txQ, acqPack);
        }
    }

    //disable FIFO input
    debug_disable();

    //return to be joined
    return NULL;
}

// sets an acquisition thread to run
void AcqThreadRun(Acq_Thread_t* acqTh)
{
    if (acqTh->running == 1)
    {
        printf("Acquisition thread already running!\n");
        exit(1);
    }

    //assert running flag
    acqTh->running = 1;

    //create acquisition thread
    if (pthread_create(&acqTh->th, NULL, acqTh_threadFunc, acqTh) != 0) error("pthread_create of acqTh");
}

// stops an acquisition thread
void AcqThreadStop(Acq_Thread_t* acqTh)
{
    if (acqTh->running == 0)
    {
        printf("Acquisition thread already stopped!\n");
        exit(1);
    }

    //deassert running flag
    acqTh->running = 0;

    //wait for thread to finish and join
    if (pthread_join(acqTh->th, NULL) != 0) error("pthread_join of acqTh");
}

//// TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t* TxThreadInit(Client_t* client, char* server_addr, const int server_portno)
{
    //allocate memory for Tx_Thread_t
    Tx_Thread_t* txTh = malloc(sizeof(Tx_Thread_t));
    memset(txTh, 0, sizeof(Tx_Thread_t));

    struct hostent* server;

    //assign client
    txTh->client = client;
    txTh->running = 0;

    if (client->tx_mode == TCP || client->tx_mode == UDP)
    {
        //find host
        server = gethostbyname(server_addr);
        if (server == NULL)
        {
            fprintf(stderr, "ERROR, no host found with that address\n");
            exit(1);
        }
        //get server address from host found
        txTh->serv_addr.sin_family = AF_INET;
        bcopy((char*)server->h_addr_list[0],
            (char*)&txTh->serv_addr.sin_addr.s_addr,
            server->h_length);    //use port passed as argument
        txTh->serv_addr.sin_port = htons(server_portno);

        if (client->tx_mode == TCP)
        {
            //open TCP/IP socket
            txTh->sockfd = socket(AF_INET, SOCK_STREAM, 0);
            if (txTh->sockfd < 0) error("txTh: TCP/IP socket open");

            //connect to server
            if (connect(txTh->sockfd, (struct sockaddr*)&txTh->serv_addr, sizeof(txTh->serv_addr)) < 0) error("txTh: connect to TCP/IP server");
            printf("Client connected to %s:%d.\n", server_addr, server_portno);
        }
        else
        {
            //open UDP socket
            txTh->sockfd = socket(PF_INET, SOCK_DGRAM, 0);
            if (txTh->sockfd < 0) error("txTh: TCP/IP socket open");

            printf("Client ready to send UDP packages to %s:%d.\n", server_addr, server_portno);
        }
    }

    return txTh;
}

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t* txTh)
{
    if (txTh->client->tx_mode == TCP || txTh->client->tx_mode == UDP)
    {
        //close connection with server
        close(txTh->sockfd);
    }

    //release memory
    free(txTh);
}

// writes a msg to UDP sockfd and address serv_addr. Retries writing until full msg is sent. Returns 0 on success, -1 on write error, 1 on connection closed
static int socketWriteUDP(int sockfd, void* msg, size_t size_msg, struct sockaddr* serv_addr)
{
    int n;

    //cast msg to char * to be able to chop it
    char* msg_c = (char*)msg;

    n = sendto(sockfd, msg, size_msg, 0, serv_addr, sizeof(struct sockaddr));

    if (n == size_msg)
    {
        return 0;
    }
    else if (n > 0)
    {
        return socketWriteUDP(sockfd, msg_c + n, size_msg - n, serv_addr);
    }
    else if (n == 0)
    {
        return 1;
    }
    else // n < 0
    {
        return -1;
    }
}

// function to be run by a transmission thread when txMode is UDP
static void* txTh_threadFuncUDP(void* ctx)
{
    Tx_Thread_t* txTh = (Tx_Thread_t*)ctx;
    Tx_Queue_t* txQ = txTh->client->txQ;
    Rx_Queue_t* rxQ = txTh->client->rxQ;
    AcqPack_t* acqPack;

    //transmit packets over network
    int wr_ret;
    while (txTh->running && txTh->client->acqTh->running)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

        //send buffer to UDP socket
        wr_ret = socketWriteUDP(txTh->sockfd, acqPack, sizeof(AcqPack_t), (struct sockaddr*)&(txTh->serv_addr));
        if (wr_ret > 0)
        {
            //do something for closed server. Die perhaps?
        }
        if (wr_ret < 0) error("socket write in txTh");

        //release buffer
        Rx_Queue_Release(rxQ, acqPack);
    }

    //if needed, empty Tx_Queue
    while (Tx_QueueSize(txQ) > 0)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

        //send buffer to UDP socket
        wr_ret = socketWriteUDP(txTh->sockfd, acqPack, sizeof(AcqPack_t), (struct sockaddr*)&(txTh->serv_addr));
        if (wr_ret > 0)
        {
            //do something for closed server. Die perhaps?
        }
        if (wr_ret < 0) error("socket write in txTh");
        //release buffer
        Rx_Queue_Release(rxQ, acqPack);
    }

    //return to be joined
    return NULL;
}

// writes a msg to TCP connected sockfd. Retries writing until full msg is sent. Returns 0 on success, -1 on write error, 1 on connection closed
static int socketWriteTCP(int sockfd, void* msg, size_t size_msg)
{
    int n;

    //cast msg to char * to be able to chop it
    char* msg_c = (char*)msg;

    n = write(sockfd, msg_c, size_msg);

    if (n == size_msg)
    {
        return 0;
    }
    else if (n > 0)
    {
        return socketWriteTCP(sockfd, msg_c + n, size_msg - n);
    }
    else if (n == 0)
    {
        return 1;
    }
    else // n < 0
    {
        return -1;
    }
}

// function to be run by a transmission thread when tx_mode is TCP
static void* txTh_threadFuncTCP(void* ctx)
{
    Tx_Thread_t* txTh = (Tx_Thread_t*)ctx;
    Tx_Queue_t* txQ = txTh->client->txQ;
    Rx_Queue_t* rxQ = txTh->client->rxQ;
    AcqPack_t* acqPack;

    //transmit packets over network
    int wr_ret;
    while (txTh->running && txTh->client->acqTh->running)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

        //send buffer to TCP socket
        wr_ret = socketWriteTCP(txTh->sockfd, acqPack, sizeof(AcqPack_t));
        if (wr_ret > 0)
        {
            //do something for closed server. Die perhaps?
        }
        if (wr_ret < 0) error("socket write in txTh");

        //release buffer
        Rx_Queue_Release(rxQ, acqPack);
    }

    //if needed, empty Tx_Queue
    while (Tx_QueueSize(txQ) > 0)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

        //send buffer to TCP socket
        wr_ret = socketWriteTCP(txTh->sockfd, acqPack, sizeof(AcqPack_t));
        if (wr_ret > 0)
        {
            //do something for closed server. Die perhaps?
        }
        if (wr_ret < 0) error("socket write in txTh");

        //release buffer
        Rx_Queue_Release(rxQ, acqPack);
    }

    //return to be joined
    return NULL;
}

// opens a file with current time as name, and brief description of content
static int fileOpen()
{
    int fout;
    struct timespec t;
    char* word1;
    //char * word2 = NULL;

    //get time from clock and place it formatted in word 1
    if (clock_gettime(CLOCK_REALTIME, &t) < 0) error("clock_gettime in fileOpen");
    word1 = ctime(&t.tv_sec);
    //remove last char
    word1[strlen(word1) - 1] = ' ';
    //remove undesired chars
    char* target;
    while (target = strchr(word1, ':'), target != NULL)
    {
        *target = '_';
    }
    while (target = strchr(word1, ' '), target != NULL)
    {
        *target = '_';
    }
    //open file with name
    fout = open(word1, O_CREAT | O_RDWR, 0640);
    if (fout < 0) error("open in fileOpen");

    //notify
    printf("txTh: opened file with name %s\n", word1);

    return fout;
}

// writes the contents of an acqPack into file fout
static void fileWrite(int fout, AcqPack_t* acqPack)
{
    if (write(fout, acqPack, sizeof(AcqPack_t)) < 0) error("write in fileWrite");
}

// function to be run by a transmission thread when txMode is file
static void* txTh_threadFuncFile(void* ctx)
{
    Tx_Thread_t* txTh = (Tx_Thread_t*)ctx;
    Tx_Queue_t* txQ = txTh->client->txQ;
    Rx_Queue_t* rxQ = txTh->client->rxQ;
    AcqPack_t* acqPack;

    //open file
    int fout = fileOpen();
    while (txTh->running && txTh->client->acqTh->running)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

        //write to file
        fileWrite(fout, acqPack);

        //release buffer
        Rx_Queue_Release(rxQ, acqPack);
    }

    //if needed, empty Tx_Queue
    while (Tx_QueueSize(txQ) > 0)
    {
        //capture from Tx_Queue
        acqPack = Tx_QueueGet(txQ);

        //write to file
        fileWrite(fout, acqPack);

        //release buffer
        Rx_Queue_Release(rxQ, acqPack);
    }

    //close file
    close(fout);

    //return to be joined
    return NULL;
}

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t* txTh)
{
    if (txTh->running == 1)
    {
        printf("Transmission thread is already running!\n");
        exit(1);
    }

    //assert running flag
    txTh->running = 1;

    //create thread with function according to client->txMode
    switch (txTh->client->tx_mode)
    {
    case file:
        if (pthread_create(&txTh->th, NULL, txTh_threadFuncFile, txTh) != 0) error("pthread_create in txTh");
        break;

    case TCP:
        if (pthread_create(&txTh->th, NULL, txTh_threadFuncTCP, txTh) != 0) error("pthread_create in txTh");
        break;

    default: //UDP
        if (pthread_create(&txTh->th, NULL, txTh_threadFuncUDP, txTh) != 0) error("pthread_create in txTh");
        break;
    }

}

// stops a transmission thread
void TxThreadStop(Tx_Thread_t* txTh)
{
    if (txTh->running == 0)
    {
        printf("Transmission thread is already stopped!\n");
        exit(1);
    }

    //deassert running flag
    txTh->running = 0;

    //wait for thread to finish and join
    if (pthread_join(txTh->th, NULL) != 0) error("pthread_join in txTh");
}

//// CLIENT
// initializes a Client_t
Client_t* ClientInit(ClParams_t* params)
{
    Client_t* client = malloc(sizeof(Client_t));
    memset(client, 0, sizeof(Client_t));

    struct itimerspec timerfd_start_spec;

    //rx and tx queues must be initialized
    client->rxQ = Rx_QueueInit();
    client->txQ = Tx_QueueInit();

    //modes from params
    client->tx_mode = params->txMode;
    client->capMode = params->capMode;
    client->trigMode = params->trigMode;

    client->debug_output = params->debug_output;
    client->clk_divider = params->clk_divider;

    //initialize threads
    client->acqTh = AcqThreadInit(client);
    client->txTh = TxThreadInit(client, params->serv_addr, params->server_portno);

    //set clock divider in ADC
    adc_clkDividerSet(params->clk_divider);

    switch (client->capMode)
    {
    case sampleNumber:
        //initialize eventfd for acqTh notification
        client->eventfd_samples = eventfd(0, 0);
        //get sample number from params      
        client->n_samples = params->n_samples;
        break;

    case timeInterval:
        //get time interval from params
        client->timerfd_stop_spec = params->timerfd_stop_spec;
        //create timer
        client->timerfd_stop = timerfd_create(CLOCK_REALTIME, 0);
        if (client->timerfd_stop < 0) error("timerfd_create in ClientInit");
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
        memset(&timerfd_start_spec, 0, sizeof(timerfd_start_spec));
        //get start time from params
        timerfd_start_spec.it_value.tv_sec = mktime(&params->timerfd_start_br);
        //create and start timer
        client->timerfd_start = timerfd_create(CLOCK_REALTIME, 0);
        timerfd_settime(client->timerfd_start, TFD_TIMER_ABSTIME, &timerfd_start_spec, NULL);
        break;

    case noDelay:
        //nothing to be done here. No delay trigger is set in ClientRun()
        break;

    default:
        break;
    }

    return client;
}

// destroys a Client_t
void ClientDestroy(Client_t* client)
{
    TxThreadDestroy(client->txTh);
    AcqThreadDestroy(client->acqTh);
    Rx_QueueDestroy(client->rxQ);
    Tx_QueueDestroy(client->txQ);
    if (client->timerfd_start) close(client->timerfd_start);
    if (client->timerfd_stop) close(client->timerfd_stop);
    if (client->timerfd_stop) close(client->eventfd_samples);
}

// stops a Client_t
void ClientStop(Client_t* client)
{
    AcqThreadStop(client->acqTh);
    TxThreadStop(client->txTh);
}

// runs a Client_t
void ClientRun(Client_t* client)
{
    uint64_t rd_buf;
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
        read(client->timerfd_start, &rd_buf, sizeof(rd_buf));
        break;

    case noDelay:
        //do nothing. Start at once
        break;
    default:
        break;
    }

    clock_gettime(CLOCK_REALTIME, &tspec);
    printf("Client started capture at time %s", ctime(&tspec.tv_sec));
    //if capture with time interval, start this timer
    if (client->capMode == timeInterval)
    {
        timerfd_settime(client->timerfd_stop, 0, &client->timerfd_stop_spec, NULL);
    }

    //run threads
    AcqThreadRun(client->acqTh);
    TxThreadRun(client->txTh);

    switch (client->capMode)
    {
    case sampleNumber:
        //wait for acqThread notification
        read(client->eventfd_samples, &rd_buf, sizeof(rd_buf));
        ClientStop(client);
        break;

    case timeInterval:
        //wait for time Interval
        read(client->timerfd_stop, &rd_buf, sizeof(rd_buf));
        ClientStop(client);
        break;
    default:
        break;
    }

}