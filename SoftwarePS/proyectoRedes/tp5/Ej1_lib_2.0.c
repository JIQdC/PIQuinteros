/* A simple server in the internet domain using TCP
The port number is passed as an argument */
#include "Ej1_lib_2.0.h"

////ERROR
void error(const char *msg)
{
    perror(msg);
    exit(1);
}

////COLA
// Inicializa (debe residir en un segmento de shared memory)
Queue_t* QueueInit()
{
    //alloco memoria para cola
    Queue_t* pQ = malloc(sizeof(Queue_t));
    //inicializo elementos básicos
    pQ->get = 0;
    pQ->put = 0;
    pQ->q_size = MAX_CONNECTIONS;

    //inicializo semáforos
    if(sem_init(&(pQ->sem_lock),1,1)<0) error("init de sem lock");
    if(sem_init(&(pQ->sem_get),1,0)<0) error("init de sem get");
    if(sem_init(&(pQ->sem_put),1,MAX_CONNECTIONS)<0) error("init de sem put");

    return pQ;
}

// Destruye el contenedor, liberando recursos
void QueueDestroy(Queue_t *pQ)
{
    //destruyo semáforos
    if(sem_destroy(&(pQ->sem_get))<0) error("destroy de sem get");
    if(sem_destroy(&(pQ->sem_get))<0) error("destroy de sem get");
    if(sem_destroy(&(pQ->sem_get))<0) error("destroy de sem get");

    //libero memoria
    free(pQ);
}

// Agrega un Nuevo elemento. Bloquea si no hay espacio
void QueuePut(Queue_t *pQ, pthread_t elem)
{
    //espero a que haya lugar en la cola y bajo semaforo put
    if(sem_wait(&(pQ->sem_put))<0) error("sem_wait de sem_put");
    //espero a que se pueda escribir y bloqueo cola
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //escribo
    pQ->elements[pQ->put % MAX_CONNECTIONS] = elem;

    //aumento put
    pQ->put++;
    
    //aumento semáforo de get
    if(sem_post(&(pQ->sem_get))<0) error("sem_post de sem_get");
    //desbloqueo cola
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");
}

// Remueve y retorna un elemento, si estuviera disponible. Si la cola está vacía retorna -1
pthread_t QueueGet(Queue_t *pQ)
{
    int retval;
    pthread_t result;

    //espero a que haya un elemento en la cola y bajo semaforo get
    retval = sem_wait(&(pQ->sem_get));
    if(retval < 0) error("sem_trywait");
    
    //espero a que se pueda leer y bloqueo cola
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //leo
    result = pQ->elements[pQ->get % MAX_CONNECTIONS];

    //aumento get
    pQ->get++;

    //aumento semáforo put
    if(sem_post(&(pQ->sem_put))<0) error("sem_post de sem_put");
    //desbloqueo cola
    if(sem_post(&(pQ->sem_lock))<0) error("sem_post de sem_lock");

    return result;
}

// recupera la cantidad de elementos en la cola
int QueueSize(Queue_t *pQ)
{
    int dif = (pQ->put - pQ->get)%MAX_CONNECTIONS;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return MAX_CONNECTIONS - dif;
    }
}

////SERVER
//inicializa el server, escuchando en todas las direcciones, en el puerto portno
Server_t * serverInit(int portno)
{
    Server_t * server = malloc(sizeof(Server_t));

    int val = 1;
    int i;

    //abro socket, seteo atributos
    server->sockfd = socket(PF_INET, SOCK_STREAM, 0);
    if (server->sockfd < 0) 
        error("ERROR opening socket");
    setsockopt(server->sockfd, SOL_SOCKET, SO_REUSEADDR,
               &val, sizeof(val));
    //seteo direcciones del server y bindeo
    memset(&server->serv_addr, 0, sizeof(server->serv_addr));
    server->portno = portno;
    server->serv_addr.sin_family = AF_INET;
    server->serv_addr.sin_addr.s_addr = INADDR_ANY;
    server->serv_addr.sin_port = htons(server->portno);
    if (bind(server->sockfd, (struct sockaddr *) &server->serv_addr,
            sizeof(server->serv_addr)) < 0) 
        error("ERROR on binding");
    //socket en modo pasivo para aceptar conexiones de clientes
    listen(server->sockfd,5);
    server->clilen = sizeof(server->cli_addr);

    //queue init
    server->pQ = QueueInit();

    //initialize sem_threads with MAX_CONNECTIONS
    sem_init(&server->sem_threads,0,MAX_CONNECTIONS);

    //server has not been stopped
    server->stop_flag = eventfd(0,EFD_SEMAPHORE);

    //init threads
    for(i=0;i<MAX_CONNECTIONS;i++)
    {
        server->cTh[i].active = 0;
        server->cTh[i].th_ctx.idx = i;
        server->cTh[i].th_ctx.server = (void *) server;
    }

    return server;
}

//joinea threads pendientes de la cola de threads del server, siempre que no esté vacía
void joinPendingThreads(Server_t * server)
{
    while(QueueSize(server->pQ) != 0)
    {
        //hago join con el thread
        pthread_join(QueueGet(server->pQ),NULL);
    }
}

//devuelve el máximo entre dos enteros
int int_max(const int i1, const int i2)
{
    if(i1 > i2)
    {
        return i1;
    }
    return i2;
}

//pasa un string a mayúsculas
char * capitalize(char* str,int len)
{
    char* capStr = malloc(len*sizeof(char));

    int i;
    for(i=0;i<len;i++)
    {
        //check if this char is lowercase
        if((str[i] >= 37) && (str[i] <= 122))
        {
            //capitalize this char
            capStr[i]=str[i] - 32;
        }
        else
        {
            //just copy
            capStr[i]=str[i];
        }
    }

    return capStr;
}

//cierra una conexión desde el thread que atiende a un cliente
void closeConnection(const int sockfd, Server_t * server, const int idx)
{
    //cierro socket
    close(sockfd);
    //bajo flag active
    server->cTh[idx].active = 0;
    //pongo thread en cola para joinear
    QueuePut(server->pQ,server->cTh[idx].thread);
    //pateo semáforo de conexiones
    sem_post(&server->sem_threads);
}

//función que corre cada thread
void * thread_func(void * ctx)
{
    Thread_Ctx_t * th_ctx = (Thread_Ctx_t *) ctx;
    Server_t * server = (Server_t *) th_ctx->server;

    int sockfd = th_ctx->newsockfd;
    int n;

    fd_set rfds;
    int sel_ret;

    char buffer[BUF_LENGTH];

    while(1)
    {
        //block until socket or server->stop_flag are triggered
        FD_ZERO(&rfds);
        FD_SET(sockfd,&rfds);
        FD_SET(server->stop_flag,&rfds);
        sel_ret = select(int_max(sockfd,server->stop_flag)+1,&rfds,NULL,NULL,NULL);
        if(sel_ret < 0) error("thread select");

        if(FD_ISSET(sockfd,&rfds))
        {
            //read from socket
            memset(buffer, 0, sizeof(buffer));
            n = recv(sockfd,buffer,BUF_LENGTH-1,0);

            if (n == 0)
            {
                //close connection, because client has closed the connection
                closeConnection(sockfd,server,th_ctx->idx);
                break;                
            }
            else if(n < 0)
            {
                error("thread read from socket");
            }

            printf("Received from client: %s\n",buffer);

            //if "close", acknowledge to client, close sockfd, and close connection
            if(strstr(buffer,"close") != NULL)
            {
                n = write(sockfd,"Connection closed.",18);
                if (n < 0) error("thread write to socket");
                closeConnection(sockfd,server,th_ctx->idx);
                break;
            }

            //capitalize
            memcpy(buffer,capitalize(buffer,n),n);
            
            //write back to socket
            n = write(sockfd,buffer,n);
            if (n < 0) error("thread write to socket");
        }
        if(FD_ISSET(server->stop_flag,&rfds))
        {
            //notify client of server closure, close sockfd, and close connection
            n = write(sockfd,"Connection closed by server.",28);
            if (n < 0) error("thread write to socket");
            closeConnection(sockfd,server,th_ctx->idx);
            break;
        }        
    }

    //return so that server can join this thread
    return NULL;    
}

//pone el server a correr
void serverRun(Server_t * server)
{
    int newsockfd;

    fd_set rfds;
    struct timeval tv;
    int sel_ret;

    int n,i;
    char buffer[BUF_LENGTH];

    //accept new connections and pass to a thread
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
           error("server select");
        }
        else
        {
            sel_ret = FD_ISSET(0,&rfds);
            if(FD_ISSET(0,&rfds))
            {
                memset(buffer,0,sizeof(buffer));
                fgets(buffer,BUF_LENGTH-1,stdin);
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
                for(i=0;i<MAX_CONNECTIONS;i++)
                {
                    if(server->cTh[i].active == 0)
                    {
                        //activate this thread
                        server->cTh[i].active = 1;
                        server->cTh[i].th_ctx.newsockfd = newsockfd;
                        pthread_create(&server->cTh[i].thread,NULL,thread_func,&server->cTh[i].th_ctx);
                        break;
                    }
                    //this should NOT happen
                    if(i == MAX_CONNECTIONS - 1)
                    {
                        printf("something is wrong...\n");
                        exit(1);
                    }
                }
            }   
        }
    }
    printf("Server stopped correctly.\n");
}

//destruye el server
void serverDestroy(Server_t * server)
{
    sem_destroy(&server->sem_threads);
    QueueDestroy(server->pQ);
    close(server->sockfd);
    free(server);
    printf("Server destroyed correctly.\n");
}