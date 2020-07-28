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
    debug_reset(10);
    fifo_reset();

    //activo salida a fifo
    uint32_t wr_data = 0xD;
    memwrite(AXI_BASE_ADDR+CONTROL_ADDR,&wr_data,1);

    //run client
    ClientRun(client);

    //apago salida a FIFO
    wr_data = 0x0;
    memwrite(AXI_BASE_ADDR+CONTROL_ADDR,&wr_data,1);

    //destroy all
    ClientDestroy(client);

	return 0;
}