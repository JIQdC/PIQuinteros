#include "error.h"

////ERROR
void error(const char *msg)
{
    perror(msg);
    exit(1);
}