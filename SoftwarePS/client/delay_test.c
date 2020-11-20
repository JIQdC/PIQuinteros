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
    uint8_t adc_ch;

    if (argc!=3)
    {
        printf("usage: %s test_pattern adc_ch\n", argv[0]);
        exit(1);
    }

    if (!strcmp(argv[1], "checkerboard")) test_pattern = checkerboard;
    else if (!strcmp(argv[1], "oneZeroWordToggle")) test_pattern = oneZeroWordToggle;
    else
    {
        printf("test pattern for calibration may be checkerboard or oneZeroWordToggle.\n");
        exit(1);
    }

    sscanf(argv[2], "%hhd", &adc_ch);

    if (adc_ch<0||adc_ch > 15)
    {
        printf("adc_ch must be in range 0-15.\n");
        exit(1);
    }

    inputDelayTest(test_pattern, adc_ch);

    return 0;
}