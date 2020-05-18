#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>
#include <semaphore.h>
#include <sys/time.h>
#include <sys/select.h>
#include <strings.h>
#include <errno.h>
#include <sys/eventfd.h>
#include <signal.h>

#define SEM_WAIT_SEC 0
#define SEM_WAIT_NSEC 10000

#define MAX_CONNECTIONS 3       //hasta 32
#define BUSY_MAX_VAL ((1 << MAX_CONNECTIONS)-1)
#define BUF_LENGTH 256
#define SELECT_WAIT_SEC 0
#define SELECT_WAIT_USEC 500

typedef struct
{
    void * server;
    int newsockfd;
    int idx;
} Thread_Ctx_t;

typedef struct
{
    sem_t sem_lock;
    sem_t sem_put;
    sem_t sem_get;

    int put;
    int get;
    int q_size;

    pthread_t elements[MAX_CONNECTIONS];
} Queue_t;

typedef struct
{
    pthread_t thread;
    int active;
    Thread_Ctx_t th_ctx;
} Client_Thread_t;

typedef struct
{
    int sockfd;
    int portno;
    socklen_t clilen;
    struct sockaddr_in serv_addr, cli_addr;

    Queue_t * pQ;

    sem_t sem_threads;
    Client_Thread_t cTh[MAX_CONNECTIONS];

    int stop_flag;
} Server_t;

////ERROR
void error(const char *msg);

////COLA
// Inicializa (debe residir en un segmento de shared memory)
Queue_t* QueueInit();

// Destruye el contenedor, liberando recursos
void QueueDestroy(Queue_t *pQ);

// Agrega un Nuevo elemento. Bloquea si no hay espacio
void QueuePut(Queue_t *pQ, pthread_t elem);

// Remueve y retorna un elemento, si estuviera disponible. Si la cola está vacía retorna -1
pthread_t QueueGet(Queue_t *pQ);

// recupera la cantidad de elementos en la cola
int QueueSize(Queue_t *pQ);

////SERVER
//inicializa el server, escuchando en todas las direcciones, en el puerto portno
Server_t * serverInit(int portno);

//joinea threads pendientes de la cola de threads del server, siempre que no esté vacía
void joinPendingThreads(Server_t * server);

//devuelve el máximo entre dos enteros
int int_max(const int i1, const int i2);

//pasa un string a mayúsculas
char * capitalize(char* str,int len);

//cierra una conexión desde el thread que atiende a un cliente
void closeConnection(const int sockfd, Server_t * server, const int idx);

//función que corre cada thread
void * thread_func(void * ctx);

//pone el server a correr
void serverRun(Server_t * server);

//destruye el server
void serverDestroy(Server_t * server);