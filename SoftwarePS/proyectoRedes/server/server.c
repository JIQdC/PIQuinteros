#include "server.h"

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
    if(sem_init(&(pQ->sem_lock),0,1)<0) error("init of sem lock");
    if(sem_init(&(pQ->sem_get),0,0)<0) error("init of sem get");
    if(sem_init(&(pQ->sem_put),0,CL_Q_SIZE)<0) error("init of sem put");

    return pQ;
}

// destroys a Cl_Queue_t queue
void Cl_QueueDestroy(Cl_Queue_t *pQ)
{
    //destroy semaphores
    if(sem_destroy(&(pQ->sem_lock))<0) error("destroy of sem lock");
    if(sem_destroy(&(pQ->sem_get))<0) error("destroy of sem get");
    if(sem_destroy(&(pQ->sem_put))<0) error("destroy of sem put");

    //release memory
    free(pQ);
}

// Adds a new element to a Cl_Queue_t queue
void Cl_QueuePut(Cl_Queue_t *pQ, Buffer_t elem)
{
    //wait for put semaphore for available space in queue
    if(sem_wait(&(pQ->sem_put))<0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait of sem_lock");

    //write element in queue
    pQ->elements[pQ->put & CL_Q_MASK] = elem;

    //increase put counter
    pQ->put++;
    
    //post get semaphore
    if(sem_post(&(pQ->sem_get))<0) error("sem_post of sem_get");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post of sem_lock");
}

// Gets and removes an element from a Cl_Queue_t queue
Buffer_t Cl_QueueGet(Cl_Queue_t *pQ)
{
    Buffer_t result;

    //wait for get semaphore for available space in queue
    if(sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    result = pQ->elements[pQ->get & CL_Q_MASK];

    //increase get counter
    pQ->get++;

    //post put semaphore
    if(sem_post(&(pQ->sem_put))<0) error("sem_post de sem_put");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");

    return result;
}

// Gets the number of elements in a Cl_Queue_t queue
int Cl_QueueSize(Cl_Queue_t *pQ)
{
    int dif = (pQ->put - pQ->get)& CL_Q_MASK;
    if(dif>=0)
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
    if(sem_init(&(pQ->sem_lock),0,1)<0) error("init of sem lock");
    if(sem_init(&(pQ->sem_get),0,0)<0) error("init of sem get");
    if(sem_init(&(pQ->sem_put),0,CL_Q_SIZE)<0) error("init of sem put");

    return pQ;
}

// destroys a Th_Queue_t queue
void Th_QueueDestroy(Th_Queue_t *pQ)
{
    //destroy semaphores
    if(sem_destroy(&(pQ->sem_lock))<0) error("destroy of sem lock");
    if(sem_destroy(&(pQ->sem_get))<0) error("destroy of sem get");
    if(sem_destroy(&(pQ->sem_put))<0) error("destroy of sem put");

    //release memory
    free(pQ);
}

// Adds a new element to a Th_Queue_t queue
void Th_QueuePut(Th_Queue_t *pQ, pthread_t elem)
{
    //wait for put semaphore for available space in queue
    if(sem_wait(&(pQ->sem_put))<0) error("sem_wait of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait of sem_lock");

    //write element in queue
    pQ->elements[pQ->put & TH_Q_MASK] = elem;

    //increase put counter
    pQ->put++;
    
    //post get semaphore
    if(sem_post(&(pQ->sem_get))<0) error("sem_post of sem_get");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post of sem_lock");
}

// Gets and removes an element from a Th_Queue_t queue
pthread_t Th_QueueGet(Th_Queue_t *pQ)
{
    pthread_t result;

    //wait for get semaphore for available space in queue
    if(sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    result = pQ->elements[pQ->get & TH_Q_MASK];

    //increase get counter
    pQ->get++;

    //post put semaphore
    if(sem_post(&(pQ->sem_put))<0) error("sem_post de sem_put");
    //post lock semaphore
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");

    return result;
}

// Gets the number of elements in a Th_Queue_t queue
int Th_QueueSize(Th_Queue_t *pQ)
{
    int dif = (pQ->put - pQ->get)& TH_Q_MASK;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return TH_Q_SIZE - dif;
    }
}

////CLIENT THREAD
// initializes an Cl_Thread_t
Cl_Thread_t * ClThreadInit(Server_t * server)
{
    Cl_Thread_t * clTh = malloc(sizeof(Cl_Thread_t));

    //initialize a new queue for this client thread
    clTh->pQ = Cl_QueueInit();
    //not running
    clTh->running = 0;
    //server as passed in argument
    clTh->server=server;

    return clTh;
}

// destroys a Cl_Thread_t
void ClThreadDestroy(Cl_Thread_t * clTh)
{
    //destroy queue
    Cl_QueueDestroy(clTh->pQ);

    //release
    free(clTh);
}

// reads msg_size bytes from socket and place them into msg. Retries reading until full msg is read. Returns 0 on success, -1 on read error, 1 on connection closed.
int socketRead(int sockfd, void * msg, size_t size_msg)
{
    int n;

    //cast msg as char * to be able to read parts of it
    char * msg_c = (char *) msg;
    
    //read from socket
    memset(msg, 0, size_msg);
    n = recv(sockfd,msg,size_msg,0);

    if (n == size_msg)
    {
        //message received succesfully
        return 0;
    }
    else if(n > 0)
    {
        //retry reading the remaining characters
        return socketRead(sockfd,msg_c+n,size_msg-n);
    }
    else if(n == 0)
    {
        //connection closed
        return 1;              
    }
    else // n < 0
    {
        //error
        return -1;
    }
    
}

// close connection on a thread and prepare it to be joined
void closeConnection(Cl_Thread_t * clTh, Server_t * server)
{
    close(clTh->sockfd);
    Th_QueuePut(server->thQ,clTh->th);
    clTh->running = 0;
}

// function to be run by the client thread
void * clTh_threadFunc(void * ctx)
{
    Cl_Thread_t * clTh = (Cl_Thread_t *) ctx;
    Server_t * server = (Server_t *) clTh->server;

    Buffer_t * buf = malloc(sizeof(Buffer_t));
    memset(buf,0,sizeof(Buffer_t));

    struct timeval tv;
    tv.tv_sec = CL_BLOCKTIME_SEC;
    tv.tv_usec = CL_BLOCKTIME_USEC;
    fd_set rfds;
    int sel_ret;

    int rd_ret;

    while(clTh->running)
    {
        //block until socket or server->stop_flag are triggered
        FD_ZERO(&rfds);
        FD_SET(clTh->sockfd,&rfds);
        FD_SET(server->stop_flag,&rfds);
        sel_ret = select(int_max(clTh->sockfd,server->stop_flag)+1,&rfds,NULL,NULL,NULL);
        if(sel_ret < 0) error("thread select"); 

        if(FD_ISSET(server->stop_flag,&rfds))
        {
            //server stopped. close connection
            closeConnection(clTh,server);
        }      
        if(FD_ISSET(clTh->sockfd,&rfds))
        {
            //read from socket
            rd_ret = socketRead(clTh->sockfd,buf,sizeof(Buffer_t));
            switch (rd_ret)
            {
            case 0:
                //place read value on queue
                Cl_QueuePut(clTh->pQ,*buf);
                break;

            case 1:
                //connection closed
                closeConnection(clTh,server);
                break;

            default: // -1
                error("socket read in clTh");
                break;
            }
        }

    }

    //return to be joined
    return NULL;
}

// sets a client thread to run
void ClThreadRun(Cl_Thread_t * clTh, int sockfd)
{
    if(clTh->running == 1)
    {
        printf("Client thread already running!\n");
        exit(1);
    }

    //assign sockfd passed as argument
    clTh->sockfd = sockfd;

    //assert running flag
    clTh->running = 1;

    //create client thread
    if(pthread_create(&clTh->th,NULL,clTh_threadFunc,clTh) != 0) error("pthread_create of clTh");
}

////PROCESSING THREAD
// initializes a Proc_Thread_t
Proc_Thread_t * ProcThreadInit(Server_t * server)
{
    Proc_Thread_t * prTh = malloc(sizeof(Proc_Thread_t));

    prTh->running = 0;
    prTh->server = server;

    return prTh;
}

// destroys a Proc_Thread_t
void ProcThreadDestroy(Proc_Thread_t * prTh)
{
    free(prTh);
}

// function to be run by the processing thread
void * procTh_threadFunc(void * ctx)
{
    // TEST IMPLEMENTATION: get first value from active threads
    Proc_Thread_t * pTh = (Proc_Thread_t *) ctx;
    Server_t * server = (Server_t *) pTh->server;
    Buffer_t buf;

    int i;

    while(pTh->running)
    {
        for(i=0;i<MAX_CLIENT_THREADS;i++)
        {
            if(server->clTh[i]->running)
            {
                buf = Cl_QueueGet(server->clTh[i]->pQ);
                printf("Client thread %d with output value %d.\n",i,buf.data[0]);
            }
        }
    }

}

// sets a processing thread to run
void ProcThreadRun(Proc_Thread_t * prTh)
{
    if(prTh->running == 1)
    {
        printf("Processing thread already running!\n");
        exit(1);
    }

    //assert running flag
    prTh->running = 1;

    //create client thread
    if(pthread_create(&prTh->th,NULL,procTh_threadFunc,prTh) != 0) error("pthread_create of prTh");
}

// stops a processing thread
void ProcThreadStop(Proc_Thread_t * prTh)
{
    if(prTh->running == 0)
    {
        printf("Client thread already stopped!\n");
        exit(1);
    }

    //deassert running flag
    prTh->running = 0;

    //wait for thread to finish and join
    if(pthread_join(prTh->th,NULL) != 0) error("pthread_join of clTh");
}

////SERVER
// initializes a Server_t
Server_t * ServerInit(int server_portno)
{
    Server_t * server = malloc(sizeof(Server_t));
    struct sockaddr_in serv_addr;
    int i;
    int val = 1;

    //open socket, set attributes
    server->sockfd = socket(PF_INET, SOCK_STREAM, 0);
    if (server->sockfd < 0) 
        error("ERROR opening socket");
    setsockopt(server->sockfd, SOL_SOCKET, SO_REUSEADDR,
               &val, sizeof(val));
    //set server address and bind
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = INADDR_ANY;
    serv_addr.sin_port = htons(server_portno);
    if (bind(server->sockfd, (struct sockaddr *) &serv_addr,
            sizeof(serv_addr)) < 0) 
        error("ERROR on binding");
    //listen for client connections
    listen(server->sockfd,5);
    server->clilen = sizeof(server->cli_addr);

    printf("Server listening on all addresses, port %d.\n",server_portno);

    //initialize thread semaphore
    if(sem_init(&server->sem_threads,0,MAX_CLIENT_THREADS) < 0) error("sem_init in ServerInit");
    //initialize client threads
    for(i=0;i<MAX_CLIENT_THREADS;i++)
    {
        server->clTh[i]=ClThreadInit(server);
    }

    //initialize thread queue
    server->thQ = Th_QueueInit();
    
    //initialize processing thread
    server->prTh=ProcThreadInit(server);

    //server has not been stopped
    server->stop_flag = eventfd(0,EFD_SEMAPHORE);

    return server;
}

// destroys a Server_t
void ServerDestroy(Server_t * server)
{
    //close socket
    close(server->sockfd);

    //destroy thread semaphore
    if(sem_destroy(&server->sem_threads) < 0) error("sem_destroy in ServerDestroy");

    //destroy client threads
    int i;
    for(i=0;i<MAX_CLIENT_THREADS;i++)
    {
        ClThreadDestroy(server->clTh[i]);
    }
    //destroy thread queue
    Th_QueueDestroy(server->thQ);

    //destroy processing thread
    ProcThreadDestroy(server->prTh);

    //close eventfd
    close(server->stop_flag);

    //release
    free(server);
}

// join pending threads from server thread queue
void joinPendingThreads(Server_t * server)
{
    while(Th_QueueSize(server->thQ) != 0)
    {
        //hago join con el thread
        pthread_join(Th_QueueGet(server->thQ),NULL);
    }
}

// function to be run by server
void ServerRun(Server_t * server)
{
    int newsockfd;

    fd_set rfds;
    struct timeval tv;
    int sel_ret;

    int n,i;
    char buffer[STDIN_BUF_LENGTH];

    //run processing thread
    ProcThreadRun(server->prTh);
    
    //wait for new connections and pass them to a thread
    while(1)
    {
        //join pending threads
        joinPendingThreads(server);

        //block until socket or stdin trigger
        FD_ZERO(&rfds);
        FD_SET(server->sockfd,&rfds);
        FD_SET(0,&rfds);
        sel_ret = select(server->sockfd+1,&rfds,NULL,NULL,NULL);
        if(sel_ret < 0)
        {
           error("select in ServerRun");
        }
        else
        {
            sel_ret = FD_ISSET(0,&rfds);
            if(FD_ISSET(0,&rfds))
            {
                memset(buffer,0,sizeof(buffer));
                fgets(buffer,STDIN_BUF_LENGTH-1,stdin);
                printf("Read from stdin: %s\n",buffer);

                //check if close has been issued
                if(strstr(buffer,"stop") != NULL)
                {
                    //ack
                    printf("Stop command received. Exiting active threads.\n");
                    //signal threads to stop
                    n = 1;
                    write(server->stop_flag,&n,sizeof(n));
                    //join all pending threads
                    joinPendingThreads(server);
                    //break
                    break;
                }
            }
            if(FD_ISSET(server->sockfd,&rfds))
            {
                //wait for an available thread
                sem_wait(&server->sem_threads);

                //accept new connection in newsockfd
                newsockfd = accept(server->sockfd, 
                        (struct sockaddr *) &server->cli_addr, 
                        &server->clilen);
                if (newsockfd < 0) error("server accept");

                //find available thread
                for(i=0;i<MAX_CLIENT_THREADS;i++)
                {
                    if(server->clTh[i]->running == 0)
                    {
                        //run this thread
                        ClThreadRun(server->clTh[i],newsockfd);
                        break;
                    }
                    //this should NOT happen
                    if(i == MAX_CLIENT_THREADS - 1)
                    {
                        printf("something is wrong...\n");
                        exit(1);
                    }
                }
            }   
        }
    }

    //stop processing thread
    ProcThreadStop(server->prTh);
    
    printf("Server stopped correctly.\n");
}