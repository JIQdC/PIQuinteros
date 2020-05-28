#include "fakeDataGen.h"
#include "client.h"

#define BD_ID 1
#define CH_ID 2
#define SERVER_ADDR "0.0.0.0"
#define SERVER_PORTNO 12345

//#define _DEBUG 1

int main()
{
    uint64_t rd_buf;
    int efd = eventfd(0,0);
    //initialize FakeDataGen
    struct timespec update_time;
    update_time.tv_sec = UPDATE_TIME_SEC;
    update_time.tv_nsec = UPDATE_TIME_NSEC;
    FakeDataGen_t * fdg = FakeDataGenInit(update_time,countOffset,1000,efd);

    //initialize client
    Client_t * client = ClientInit(fdg->pq,BD_ID,CH_ID,SERVER_ADDR,SERVER_PORTNO,efd,sampleNumber,manual);

    //run fdg
    FakeDataGenRun(fdg);
    //run client
    ClientRun(client);

    //wait for client to finish
    read(efd,&rd_buf,sizeof(rd_buf));
    //stop fdg
    FakeDataGenStop(fdg);   

    //destroy all
    FakeDataGenDestroy(fdg);
    ClientDestroy(client);

    return 0;
}