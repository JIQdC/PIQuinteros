/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Delay test script for specified data channel and test pattern

Version: 2020-11-11
Comments:
*/

#include "src/AXI_control.h"
#include "src/delay_functions.h"

// // Programa principal
int main(int argc, char* argv[])
{
    adc_testPattern_t test_pattern;

    if (argc!=2)
    {
        printf("usage: %s test_pattern\n", argv[0]);
        exit(1);
    }

    if (!strcmp(argv[1], "checkerboard")) test_pattern = checkerboard;
    else if (!strcmp(argv[1], "oneZeroWordToggle")) test_pattern = oneZeroWordToggle;
    else
    {
        printf("test pattern for calibration may be checkerboard or oneZeroWordToggle.\n");
        exit(1);
    }

    if (test_pattern != oneZeroWordToggle && test_pattern != checkerboard)
    {
        printf("inputDelayTest: test pattern for delay_test may be checkerboard or oneZeroWordToggle.\n");
        exit(1);
    }
    uint16_t sample_dif;
    if (test_pattern == oneZeroWordToggle) sample_dif = CAL_DIFF_WT;
    else sample_dif = CAL_DIFF_CHK;

    int i, k;

    int result;

    //configure ADC to desired test conditions
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
            inputDelaySet_frame(0, i);
            inputDelaySet_data(0, k);

            //compute bad samples
            result = computeBadSamples(0, sample_dif);

            //print result
            printf("%d\t", result);
        }
        printf("\n");
    }

    //return both input delays to 0
    inputDelaySet_frame(0, 0);
    inputDelaySet_data(0, 0);

    return 0;

}