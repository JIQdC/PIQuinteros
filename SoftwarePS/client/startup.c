/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Startup routine for CIAA-ACC and AD9249

Version: 2020-11-11
Comments: This routine performs the following startup tasks for the acquisition system:
1. Enables PTP daemon.
2. Writes a specified value to potentiometer via I2C.
3. Enables power regulator to banks 12 and 13.
4. Detects if AD9249 is connected and powered:
    a. Checks if FMC connector is present.
    b. Checks if FCO1 and FCO2 are toggling
4. If AD9249 evaluation board is connected and powered:
    a. Configures AXI SPI module.
    b. Configures ADC to default operation values.
    c. Runs input delay calibration routine.

*/

#include "src/AXI_control.h"
#include "src/SPI_control.h"
#include "src/delay_functions.h"

// Programa principal
int main()
{
    //enable PTP daemon
    system("/mnt/ptpd2 -b eth0 -g");
    printf("PTPD daemon started.\n");

    //enable regulator
    regulator_enable();

    //detect AD9249 eval board

    //check if FMC is connected
    if (fmc_present())
    {
        printf("FMC connector detected.\n");
        //check if both FCOs are locked
        if (locked_FCO1())
        {
            printf("ADC FCO1 signal locked.\n");
            if (locked_FCO2())
            {
                printf("ADC FCO2 signal locked.\n");
            }
            else
            {
                printf("ADC FCO2 signal not locked. Skipping SPI and ADC default configuration.\n");
                exit(1);
            }
        }
        else
        {
            printf("ADC FCO1 signal not locked. Skipping SPI and ADC default configuration.\n");
            exit(1);
        }
    }
    else
    {
        printf("FMC connector not detected. Skipping SPI and ADC default configuration.\n");
        exit(1);
    }

    printf("\n");

    //default configuration for AXI module and ADC
    spi_defaultConfig();

    //TODO: el default config tiene que ser muestrear en complemento a 2
    adc_defaultConfig();

    //run input delay calibration routine
    printf("Running input delay calibration routine with testPattern checkerboard...\n");
    inputDelayCalibrate(checkerboard);
    adc_testPattern(off);
    return 0;
}