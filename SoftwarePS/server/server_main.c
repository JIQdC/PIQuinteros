/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Server main script

Version: 2020-10-24
Comments:
*/

//remember that, when using TCP, functions are TCPServerXXXX
#include "src/UDPserver.h"

int main()
{
    int portno = 12345;
    //create server
    Server_t* server = ServerInit(portno);

    //run server
    ServerRun(server);

    //destroy server
    ServerDestroy(server);

    return 0;
}