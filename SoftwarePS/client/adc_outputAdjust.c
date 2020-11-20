/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Script for setting ADC output adjust drive

Version: 2020-09-16
Comments:
*/

#include "src/SPI_control.h"

int main(int argc, char* argv[])
{
    uint8_t value;

    if (argc != 2)
    {
        printf("usage: %s state(0,1)\n", argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hhd", &value);

    if (value < 0 || value > 1)
    {
        printf("state must be 1 or 0.\n");
        exit(1);
    }

    //configure both ADCs equally
    SPI_slaves_t slaves[2] = { adc1, adc2 };

    int i;
    uint32_t wr_data = value;

    for (i = 0; i<2; i++)
    {
        spi_ssel(slaves[i]);

        //output adjust
        spi_write(ADC_OUTPUTADJUST, &wr_data, 1);
    }

    usleep(10);

    return 0;
}