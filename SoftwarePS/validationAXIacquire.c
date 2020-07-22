#include "src/CIAASistAdq.h"

// // Programa principal
int main(int argc, char *argv[]) 
{
    ClParams_t * clPars = malloc(sizeof(ClParams_t));

    if (argc != 2)
    {
        printf("usage: %s client_config_file\n",argv[0]);
        exit(1);
    }

    //reset FIFO
	fifo_reset();

    //reset counter for 10 microseconds
    debug_reset(10);
    
    //parse parameters from files
    ClientParseFile(argv[1],clPars);

    //initialize client
    Client_t * client = ClientInit(clPars);

    //trigger wr_en
    uint32_t wr_data = 1;
    memwrite(AXI_BASE_ADDR + USRAUX_ADDR,&wr_data,1);

    //run client
    ClientRun(client);

    //deassert wr_en
    wr_data = 0;
    memwrite(AXI_BASE_ADDR + USRAUX_ADDR,&wr_data,1);

    //destroy all
    ClientDestroy(client);
	
    return 0;
}