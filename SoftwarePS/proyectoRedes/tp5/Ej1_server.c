/* A (not so) simple server in the internet domain using TCP
   The port number is passed as an argument */
#include "Ej1_lib_2.0.h"

int main(int argc, char *argv[])
{
    Server_t * server;
    
    if (argc < 2) {
    fprintf(stderr,"ERROR, no port provided\n");
    exit(1);
    }

    server = serverInit(atoi(argv[1]));

    serverRun(server);

    serverDestroy(server);

    printf("\nProgram finished succesfully.");
    printf("\n");

    return 0; 
}