/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Asyncronic and FIFO reset trigger script

Version: 2020-10-18
Comments:
*/

#include "src/AXI_control.h"

int main()
{
    uint16_t duration = 20;
    async_reset(duration);
    fifo_reset();
    printf("\nSe resetearon módulos de debug y FIFO.\n");
}
