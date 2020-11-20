/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
FIFO reset script

Version: 2020-10-18
Comments:
*/

#include "src/AXI_control.h"

// // Programa principal
int main(int argc, char* argv[])
{
    fifo_reset();

    printf("\nFIFO reset\n");

    return 0;
}