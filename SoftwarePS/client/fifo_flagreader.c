/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
FIFO flag reader script for specified data channel

Version: 2020-10-24
Comments:
*/

#include "src/AXI_control.h"

int main(int argc, char* argv[])
{
    uint8_t adc_ch;
    if (argc != 2)
    {
        printf("usage: %s adc_ch\n", argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hhd", &adc_ch);

    uint32_t rd_data;

    memread(DATA_BASE_ADDR+FIFOFLAGS_OFF+4*adc_ch, &rd_data, 1);

    fifo_flags_t* flags = malloc(sizeof(fifo_flags_t));
    memset(flags, 0, sizeof(fifo_flags_t));
    fifoflags_reg_to_struct(flags, &rd_data);
    print_fifo_flags(flags);
    free(flags);

    return 0;
}