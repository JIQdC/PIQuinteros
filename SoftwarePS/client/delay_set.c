/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Delay set for pin and frame

Version: 2020-11-20
Comments:
*/

#include "src/delay_functions.h"

int main(int argc, char* argv[])
{
    uint8_t delay_val, pin;

    if (argc != 4)
    {
        printf("usage: %s pin/frame number delay_val\n", argv[0]);
        exit(1);
    }

    sscanf(argv[2], "%hhd", &pin);
    sscanf(argv[3], "%hhd", &delay_val);

    if (!strcmp(argv[1], "pin")) inputDelaySet_data(pin, delay_val);
    else if (!strcmp(argv[1], "frame")) inputDelaySet_frame(pin, delay_val);
    else
    {
        printf("First argument must be \"pin\" or \"frame\".\n");
        exit(1);
    }

    return 0;
}