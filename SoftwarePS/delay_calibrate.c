/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Delay calibration script

Version: 2020-11-11
Comments:
*/

#include "src/delay_functions.h"

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

    inputDelayCalibrate(test_pattern);

    return 0;
}