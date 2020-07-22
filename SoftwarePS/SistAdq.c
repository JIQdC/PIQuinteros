#include "src/CIAASistAdq.h"

#define TX_MODE 0

// // Programa principal
int main(int argc, char *argv[]) 
{

    ClParams_t * clPars = malloc(sizeof(ClParams_t));

    if (argc != 2)
    {
        printf("usage: %s client_config_file\n",argv[0]);
        exit(1);
    }
    
    //parse parameters from files
    ClientParseFile(argv[1],clPars);

    //initialize client
    Client_t * client = ClientInit(clPars);

    //reseteo debug y FIFO
    fifo_reset();
    debug_reset(10);

    //run client
    ClientRun(client);

    //destroy all
    ClientDestroy(client);

	return 0;
}