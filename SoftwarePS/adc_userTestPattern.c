/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
ADC User Test Pattern set script

Version: 2020-10-21
Comments:
*/

#include "src/AXI_control.h"
#include "src/SPI_control.h"

// // Programa principal
int main(int argc, char* argv[])
{
    uint16_t word1, word2;

    if (argc != 3)
    {
        printf("usage: %s word1 word2\n", argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hd", &word1);
    sscanf(argv[2], "%hd", &word2);

    adc_userTestPattern(word1, word2);

    return 0;
}