/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Script for acquiring a fixed sample number for one ADC channel

Version: 2020-10-21
Comments:
*/

#include "src/AXI_control.h"
#include "src/SPI_control.h"
#include "lib/intToBase.h"

// // Programa principal
int main(int argc, char* argv[])
{
    uint8_t adc_ch;
    uint16_t sample_num;

    if (argc != 3)
    {
        printf("usage: %s adc_ch sample_num\n", argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hhd", &adc_ch);
    if (adc_ch < 1 || adc_ch > 16)
    {
        printf("adc_ch must be in range 1-16\n");
        exit(1);
    }

    sscanf(argv[2], "%hd", &sample_num);
    if ((sample_num % 2) != 0)
    {
        printf("sample_num must be even\n");
        exit(1);
    }

    Multi_MemPtr_t* memPtr_flags, * memPtr_data, * memPtr_progfull;
    AcqPack_t* acqPack = malloc(sizeof(AcqPack_t));
    memset(acqPack, 0, sizeof(AcqPack_t));

    int j;
    char* buffer;

    //map memory spaces to read FIFO flags and data
    Multi_MemPtr_t* mPtr_flags, * mPtr_data, * mPtr_progFull;
    uint32_t flags_addr, data_addr, progFull_addr;
    flags_addr = DATA_BASE_ADDR+FIFOFLAGS_OFF+4*adc_ch;
    data_addr = DATA_BASE_ADDR+FIFODATA_OFF+4*adc_ch;
    progFull_addr = DATA_BASE_ADDR+PROGFULL_OFF;
    mPtr_flags = multi_minit(&flags_addr, 1);
    mPtr_data = multi_minit(&data_addr, 1);
    mPtr_progFull = multi_minit(&progFull_addr, 1);

    //reset FIFO and debug modules
    async_reset(10);
    fifo_reset();

    //select debug output from deserializer and enable FIFO input
    debug_output(DESERIALIZER_CTRL, adc_ch);
    debug_enable();

    //acquire
    acquire_data(acqPack, mPtr_flags, mPtr_data, mPtr_progFull);

    //disable FIFO input and debug output
    debug_disable();
    debug_output(DISABLED_CTRL, adc_ch);

    //print required samples
    for (j = 0; j<sample_num/2; j++)
    {
        buffer = intToBase((acqPack->data[j][0].data16[1]) >> 14, 2);
        printf("%s\n", buffer);
        buffer = intToBase(acqPack->data[j][0].data16[0], 2);
        printf("%s\n", buffer);
    }

    //free resources
    free(acqPack);
    multi_mdestroy(mPtr_flags);
    multi_mdestroy(mPtr_data);
    multi_mdestroy(mPtr_progFull);

    return 0;
}