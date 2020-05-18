#include "fakeDataGen.h"

////ERROR
void error(const char *msg);

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
    pQ->elements[pQ->put % DEV_Q_SIZE] = elem;

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
    uint16_t * result;

    //wait for get semaphore for available space in queue
    if(sem_wait(&(pQ->sem_get)) < 0) error("sem_get of sem_put");
    //wait for queue lock semaphore
    if(sem_wait(&(pQ->sem_lock))<0) error("sem_wait de sem_lock");

    //get element from queue
    result = pQ->elements[pQ->get % DEV_Q_SIZE];

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
    int dif = (pQ->put - pQ->get)%DEV_Q_SIZE;
    if(dif>=0)
    {
        return dif;
    }
    else
    {
        return DEV_Q_SIZE - dif;
    }
}

////FAKE DATA GEN
// initializes a fake data generator
FakeDataGen_t * FakeDataGenInit(time_t update_period, OpMode_t mode)
{
    FakeDataGen_t * fdg = malloc(sizeof(FakeDataGen_t));

    fdg->update_period = update_period;
    fdg->mode = mode;
    fdg->pq = Dev_QueueInit();
    fdg->running = 0;

    return fdg;
}

// destroys a fake data generator
void FakeDataGenDestroy(FakeDataGen_t * fdg)
{
    Dev_QueueDestroy(&(fdg->pq));
    free(fdg);
}

// function to be run by the fake data generator
void * fdg_threadFunc (void * ctx)
{
    FakeDataGen_t * fdg =  (FakeDataGen_t *) ctx;
    uint16_t result;
    double time_o = 0;

    //seed for randomness
    srand(time(NULL));    

    //first, check mode chosen
    switch (fdg->mode)
    {
        case sine2k:
            //produce a sine wave of 2kHz frequency until stopped
            while(fdg->running)
            {
                //calculate sine, put in queue, update time
                result = (uint16_t) (SINE_AMPLITUDE * sin(2*M_PI*2000*time_o) + SINE_OFFSET);
                Dev_QueuePut(fdg->pq,result);
                time_o += fdg->update_period;
                usleep(fdg->update_period*1000000);
            }
            break;
        case sine4k:
            //produce a sine wave of 2kHz frequency until stopped
            while(fdg->running)
            {
                //calculate sine, put in queue, update time
                result = (uint16_t) (SINE_AMPLITUDE * sin(2*M_PI*4000*time_o) + SINE_OFFSET);
                Dev_QueuePut(fdg->pq,result);
                time_o += fdg->update_period;
                usleep(fdg->update_period*1000000);
            }
            break;
        case randConst:
            //pick a random constant and output to queue until stopped
            result = rand() % UINT16_MAX;
            while (fdg->running)
            {
                Dev_QueuePut(fdg->pq,result);
                usleep(fdg->update_period*1000000);
            }
            break;      
        default: //noise
            //output random numbers to queue until stopped
            while (fdg->running)
            {
                result = rand() % UINT16_MAX;
                Dev_QueuePut(fdg->pq,result);
                usleep(fdg->update_period*1000000);
            }            
            break;
    }

    //return to be joined by FakeDataGenStop
    return NULL;
}
// sets a fake data gen to run
void FakeDataGenRun(FakeDataGen_t * fdg)
{
    if(fdg->running == 1)
    {
        printf("FakeDataGen is already running!\n");
        exit(1);
    }

    //assert running flag
    fdg->running = 1;
    //create thread
    if(pthread_create(&fdg->th,NULL,fdg_threadFunc,fdg) != 0) error("pthread_create in fdg");
}

//stops a fake data gen
void FakeDataGenStop(FakeDataGen_t * fdg)
{
    if(fdg->running == 0)
    {
        printf("FakeDataGen is already stopped!\n");
        exit(1);
    }

    //deassert running flag
    fdg->running = 0;

    //wait for thread to finish
    if(pthread_join(fdg->th,NULL) != 0) error("pthread_join in fdg");
}