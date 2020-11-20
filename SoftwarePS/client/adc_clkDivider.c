/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Script for setting ADC clock divider

Version: 2020-09-16
Comments:
*/

#include "src/SPI_control.h"

int main(int argc, char* argv[])
{
    uint8_t divide_value;

    if (argc != 2)
    {
        printf("usage: %s divide_value\n", argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hhd", &divide_value);

    if (divide_value < 1 || divide_value > 8)
    {
        printf("divide_value must be in range 1-8.\n");
        exit(1);
    }

    adc_clkDividerSet(divide_value-1);

    usleep(10);

    return 0;
}