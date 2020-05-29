#include "../fdg/fakeDataGen.h"
#include "client.h"

#define BD_ID 1
#define CH_ID 2
#define SERVER_ADDR "0.0.0.0"
#define SERVER_PORTNO 12345

//#define _DEBUG 1

int main(int argc, char *argv[])
{
    uint64_t rd_buf;
    int efd = eventfd(0,0);
    ClParams_t * clPars = malloc(sizeof(ClParams_t));
    FdgParams_t * fdgPars = malloc(sizeof(FdgParams_t));

    if (argc != 3)
    {
        printf("usage: %s client_config_file fdg_config_file\n",argv[0]);
        exit(1);
    }
    
    //parse parameters from files
    ClientParseFile(argv[1],clPars);
    FdgParseFile(argv[2],fdgPars);

    //initialize FakeDataGen
    FakeDataGen_t * fdg = FakeDataGenInit(fdgPars,efd);

    //initialize client
    Client_t * client = ClientInit(fdg->pq,efd,clPars);

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