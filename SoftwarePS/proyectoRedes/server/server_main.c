#include "server.h"

int main()
{
    int portno = 12345;
    //create server
    Server_t * server = ServerInit(portno);

    //run server
    ServerRun(server);

    //destroy server
    ServerDestroy(server);
    
    return 0;
}