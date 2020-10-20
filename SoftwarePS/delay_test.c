/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Delay test script for specified data channel

Version: 2020-10-20
Comments:
*/

#include "src/AXI_control.h"
#include "src/SPI_control.h"

// // Programa principal
int main(int argc, char* argv[])
{
    uint8_t clk_divider = 0;
    adc_testPattern_t test_pattern = checkerboard;
    uint16_t sample_dif = 0b10101010101010 - 0b01010101010101;
    uint8_t adc_ch, frame;

    if (argc!=2)
    {
        printf("usage: %s adc_ch\n", argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hhd", &adc_ch);

    if (adc_ch<0||adc_ch > 15)
    {
        printf("adc_ch must be in range 0-15.\n");
        exit(1);
    }

    //use frame corresponding to adc_ch position
    frame = g_adcPinPositions[adc_ch];

    Multi_MemPtr_t* mPtr_flags, * mPtr_data, * mPtr_progFull;

    AcqPack_t* acqPack = malloc(sizeof(AcqPack_t));
    memset(acqPack, 0, sizeof(AcqPack_t));

    uint16_t expanded_data[2*CHDATA_SIZE];
    memset(expanded_data, 0, 2*CHDATA_SIZE*sizeof(uint16_t));

    int i, j, k;

    int result;
    uint32_t flags_addr, data_addr, progFull_addr;

    //map memory spaces to read FIFO flags and data
    flags_addr = DATA_BASE_ADDR+FIFOFLAGS_OFF+4*adc_ch;
    data_addr = DATA_BASE_ADDR+FIFODATA_OFF+4*adc_ch;
    progFull_addr = DATA_BASE_ADDR+PROGFULL_OFF;

    mPtr_flags = multi_minit(&flags_addr, 1);
    mPtr_data = multi_minit(&data_addr, 1);
    mPtr_progFull = multi_minit(&progFull_addr, 1);

    //configure ADC to desired test conditions
    adc_clkDividerSet(clk_divider);
    adc_testPattern(test_pattern);

    printf("Rows: Tap 0 (frame)\n");
    printf("Columns: Tap 1 (data)\n");

    printf("\t");
    for (i = 0; i<32; i++) printf("T%d\t", i);
    printf("\n");
    for (i = 0; i<32; i++)
    {
        printf("T%d\t", i);
        for (k = 0; k<32; k++)
        {
            //change IDELAY 0 to i value and IDELAY 1 to k value
            inputDelaySet_frame(frame, i);
            inputDelaySet_data(adc_ch, k);

            //reset FIFO and debug modules
            async_reset(10);
            fifo_reset();

            //select debug output from deserializer and enable FIFO input
            debug_output(DESERIALIZER_CTRL, adc_ch);
            debug_enable();

            //acquire
            acquire_data(acqPack, mPtr_flags, mPtr_data, mPtr_progFull);

            //disable FIFO input
            debug_disable();

            //expand data
            for (j = 0; j<CHDATA_SIZE; j++)
            {
                expanded_data[2*j] = acqPack->data[0][j].data16[1];
                expanded_data[2*j+1] = acqPack->data[0][j].data16[0];
            }

            result = 0;
            //compute bad samples checking if the difference between them differs from SAMPLE_DIF
            for (j = 1; j<2*CHDATA_SIZE; j++)
            {
                if ((abs(expanded_data[j]-expanded_data[j-1]))!=sample_dif) result++;
            }

            //print result
            printf("%d\t", result);
        }
        printf("\n");
    }

    //return both input delays to 0
    inputDelaySet_frame(frame, 0);
    inputDelaySet_data(adc_ch, 0);

    multi_mdestroy(mPtr_data);
    multi_mdestroy(mPtr_flags);
    multi_mdestroy(mPtr_progFull);

    free(acqPack);

    return 0;
}