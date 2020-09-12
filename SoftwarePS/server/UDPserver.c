#include "UDPserver.h"

struct Ch_File_Str
{
    uint8_t ch_id;
    int f;
    Ch_File_t * chList_next;
};

////PROCESSING THREAD
// initializes a Proc_Thread_t
Proc_Thread_t * ProcThreadInit(Server_t * server)
{
    Proc_Thread_t * prTh = malloc(sizeof(Proc_Thread_t));

    prTh->running = 0;
    prTh->server = server;
    prTh->chList_head = NULL;

    return prTh;
}

// destroys a Proc_Thread_t
void ProcThreadDestroy(Proc_Thread_t * prTh)
{
    free(prTh);
}

// opens a channel file with current time_ch_id as filename. writes header for AcqPack_t
static Ch_File_t * chFileOpen(Proc_Thread_t * prTh, uint8_t ch_id)
{
    Ch_File_t * chF = malloc(sizeof(Ch_File_t));
    struct timespec t;
    char * word1;
    char word2[40] = "";
    char str_ch_id[10] = "";

    //identify chFile with ch_id
    chF->ch_id = ch_id;
    //set element next list
    chF->chList_next = prTh->chList_head;    
    
    //get time from clock and place it formatted in word 1
    if(clock_gettime(CLOCK_REALTIME,&t) < 0) error("clock_gettime in fileOpen");
    word1 = ctime(&t.tv_sec);
    //remove last char
    word1[strlen(word1)-1] = ' ';
    //remove undesired chars
    char * target;
    while(target = strchr(word1,':'),target !=NULL)
    {
        *target = '_';
    }
    while(target = strchr(word1,' '),target !=NULL)
    {
        *target = '_';
    }
    //place in word2
    strncpy(word2,word1,strlen(word1));
    //convert int ch_id into str ch_id
    sprintf(str_ch_id," ch%d",ch_id);
    //concat
    strcat(word2,str_ch_id);
    //open file with name
    chF->f = open(word2,O_CREAT|O_RDWR,0640);
    if(chF->f < 0) error("open in fileOpen");

    //notify
    printf("prTh: opened file with name %s\n",word2);

    return chF;
}

// writes an AcqPack_t into ch_file
static void chFileWritePack(const AcqPack_t * pack,Ch_File_t * chF)
{
    if(write(chF->f,pack,sizeof(AcqPack_t)) < 0) error("write in chFileWritePack");
}

// function to be run by the processing thread
static void * procTh_threadFunc(void * ctx)
{
    Proc_Thread_t * pTh = (Proc_Thread_t *) ctx;
    Server_t * server = (Server_t *) pTh->server;
    AcqPack_t pack;
    Ch_File_t * chF;

    while(pTh->running)
    {
        //get from queue
        while(Cl_QueueSize(server->clQ)!= 0)
        {

            Cl_QueueGet(server->clQ,&pack);

            //check if channel is on prTh channel list
            chF = pTh->chList_head;
            while(chF != NULL)
            {
                if(chF->ch_id == pack.header.ch_id)
                {
                    //write pack to this channel file
                    chFileWritePack(&pack,chF);
                    break;
                }
                else
                {
                    //keep looking on next element
                    chF = chF->chList_next;
                }                
            }
            //if chFile is not opened, open and write
            if(chF == NULL)
            {
                chF = chFileOpen(pTh,pack.header.ch_id);
                pTh->chList_head = chF;
                chFileWritePack(&pack,pTh->chList_head);
            }
        }
    }

    //once stopped, close all open files
    chF = pTh->chList_head;
    while(chF != NULL)
    {
        close(chF->f);
        chF = chF->chList_next;
    }    

    return NULL;
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

    //open UDP socket, set attributes
    server->sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (server->sockfd < 0) 
        error("ERROR opening UDP socket");

    //set server address and bind
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family = AF_INET;
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    serv_addr.sin_port = htons(server_portno);
    if (bind(server->sockfd, (struct sockaddr *) &serv_addr,
            sizeof(serv_addr)) < 0) 
        error("ERROR on binding");

    printf("UDP server listening on all addresses, port %d.\n",server_portno);

    //initialize client queue
    server->clQ = Cl_QueueInit();
    
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

    //destroy processing thread
    ProcThreadDestroy(server->prTh);

    //close eventfd
    close(server->stop_flag);

    //destroy queue
    Cl_QueueDestroy(server->clQ);

    //release
    free(server);
}

// reads msg_size bytes from UDP socket and place them into msg. Retries reading until full msg is read. Returns 0 on success, -1 on read error, 1 on connection closed.
static int socketUDPRead(int sockfd, void * msg, size_t size_msg)
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
        return socketUDPRead(sockfd,msg_c+n,size_msg-n);
    }
    else if(n == 0)
    {
        //empty datagram
        return 1;              
    }
    else // n < 0
    {
        //error
        return -1;
    }
    
}

// function to be run by server
void ServerRun(Server_t * server)
{
    fd_set rfds;
    int sel_ret;

    int n;
    char buffer[STDIN_BUF_LENGTH];

    AcqPack_t * rxPack = malloc(sizeof(AcqPack_t));
    memset(rxPack,0,sizeof(AcqPack_t));

    //run processing thread
    ProcThreadRun(server->prTh);
    
    //wait for new connections and pass them to a thread
    while(1)
    {
        //block until socket or stdin trigger
        FD_ZERO(&rfds);
        FD_SET(server->sockfd,&rfds);
        FD_SET(0,&rfds);
        sel_ret = select(server->sockfd+1,&rfds,NULL,NULL,NULL);
        if(sel_ret < 0)
        {
           error("select in qServerRun");
        }
        else
        {
            sel_ret = FD_ISSET(0,&rfds);
            if(FD_ISSET(0,&rfds))
            {
                memset(buffer,0,sizeof(buffer));
                fgets(buffer,STDIN_BUF_LENGTH-1,stdin);
                printf("Server: Read from stdin: %s\n",buffer);

                //check if close has been issued
                if(strstr(buffer,"stop") != NULL)
                {
                    //ack
                    printf("Server: Stop command received. Exiting active threads.\n");
                    //signal threads to stop
                    n = 1;
                    write(server->stop_flag,&n,sizeof(n));

                    //break
                    break;
                }
            }
            if(FD_ISSET(server->sockfd,&rfds))
            {
                //receive incoming pack
                n = socketUDPRead(server->sockfd,rxPack,sizeof(AcqPack_t));
                switch (n)
                {
                case 0:
                    //place read value on queue
                    Cl_QueuePut(server->clQ,rxPack);
                    break;

                case 1:
                    //ignore broken or empty datagram
                    break;
                
                default: // -1
                    error("UDP socket read");
                    break;
                }
                
                
            }   
        }
    }

    //stop processing thread
    ProcThreadStop(server->prTh);

    free(rxPack);

    printf("Server stopped correctly.\n");
}                       