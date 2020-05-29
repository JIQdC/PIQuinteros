#include "fakeDataGen.h"

////FAKE DATA GEN
// initializes a fake data generator
FakeDataGen_t * FakeDataGenInit(const FdgParams_t * params, int eventfd_out)
{
    FakeDataGen_t * fdg = malloc(sizeof(FakeDataGen_t));

    fdg->update_period = params->update_period;
    fdg->mode = params->mode;
    fdg->mode_param = params->mode_param;
    fdg->pq = Dev_QueueInit();
    fdg->running = 0;

    //init timefd
    fdg->timefd = timerfd_create(CLOCK_REALTIME,0);
    if(fdg->timefd < 0) error("timerfd_create in fdg init");

    fdg->eventfd_out = eventfd_out;

    return fdg;
}

// destroys a fake data generator
void FakeDataGenDestroy(FakeDataGen_t * fdg)
{
    Dev_QueueDestroy(fdg->pq);
    close(fdg->timefd);
    free(fdg);
}

// function to be run by the fake data generator
static void * fdg_threadFunc (void * ctx)
{
    FakeDataGen_t * fdg =  (FakeDataGen_t *) ctx;
    uint16_t result;
    double time_o = 0;
    uint64_t rd_buf;

    //seed for randomness
    srand(time(NULL));

    //SYNC WITH CLIENT: wait for signal from outer world
    read(fdg->eventfd_out,&rd_buf,sizeof(rd_buf));

    //run timer
    struct itimerspec it;
    it.it_interval=fdg->update_period;
    it.it_value=fdg->update_period;
    if(timerfd_settime(fdg->timefd,0,&it,NULL)<0) error("timerfd_settime in fdg_threadFunc");

    switch (fdg->mode)
    {
        case sine:
            printf("FDG: generating sine wave of frequency %d Hz.\n",fdg->mode_param);
            //produce a sine wave of frequency set in mode_param until stopped
            while(fdg->running)
            {
                //calculate sine, put in queue, update time
                result = (uint16_t) (SINE_AMPLITUDE * sin(2*M_PI*fdg->mode_param*time_o) + SINE_OFFSET);
                Dev_QueuePut(fdg->pq,result);
                time_o += fdg->update_period.tv_sec + 1e-9*fdg->update_period.tv_nsec;
                //wait for timer
                read(fdg->timefd,&rd_buf,sizeof(uint64_t));
            }
            break;
        case randConst:
            //pick a random constant and output to queue until stopped
            result = rand() & UINT16_MAX;
            printf("FDG: writing %d into queue.\n",result);
            while (fdg->running)
            {
                Dev_QueuePut(fdg->pq,result);
                //wait for timer
                read(fdg->timefd,&rd_buf,sizeof(uint64_t));
            }
            break; 
        case countOffset:
            //count from offset passed as mode_param
            result = fdg->mode_param;
            printf("FDG: generating counter from offset %d.\n",fdg->mode_param);
            while(fdg->running)
            {
                Dev_QueuePut(fdg->pq,result++);
                //wait for timer
                read(fdg->timefd,&rd_buf,sizeof(uint64_t));
            }
            break;
        default: //noise
            //output random numbers to queue until stopped
            printf("FDG: generating random data.\n");
            while (fdg->running)
            {
                result = rand() & UINT16_MAX;
                Dev_QueuePut(fdg->pq,result);
                //wait for timer
                read(fdg->timefd,&rd_buf,sizeof(uint64_t));
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