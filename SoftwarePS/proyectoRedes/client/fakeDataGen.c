#include "fakeDataGen.h"

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
    Dev_QueueDestroy(fdg->pq);
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
            result = rand() & UINT16_MAX;
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
                result = rand() & UINT16_MAX;
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