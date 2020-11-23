/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Server main script

Version: 2020-11-21
Comments:
*/

#include "src/UDPserver.h"

int main()
{
    int portno = 50000;
    //create server
    Server_t* server = ServerInit(portno);

    //run server
    ServerRun(server);

    //destroy server
    ServerDestroy(server);

    return 0;
}