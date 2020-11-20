/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Acquisition system main script

Version: 2020-10-17
Comments:
*/

#include "src/AXI_control.h"
#include "src/client_functions.h"

// // Programa principal
int main(int argc, char* argv[])
{
    ClParams_t* clPars = malloc(sizeof(ClParams_t));

    if (argc != 2)
    {
        printf("usage: %s client_config_file\n", argv[0]);
        exit(1);
    }

    //parse parameters from files
    ClientParseFile(argv[1], clPars);

    //initialize client
    Client_t* client = ClientInit(clPars);

    //reseteo debug y FIFO
    async_reset(10);
    fifo_reset();

    //run client
    ClientRun(client);

    //destroy all
    ClientDestroy(client);

    //free
    free(clPars);

    return 0;
}