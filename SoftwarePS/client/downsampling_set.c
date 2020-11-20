/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Downsampling treshold set script

Version: 2020-10-24
Comments:
*/

#include "src/preproc_functions.h"

int main(int argc, char* argv[])
{
    uint16_t val;

    if (argc != 2)
    {
        printf("usage: %s tresh_val\n", argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hd", &val);

    downsampling_set(val);

    return 0;
}