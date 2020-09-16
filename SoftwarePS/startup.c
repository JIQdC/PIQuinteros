/*
Emulation, acquisition and data processing system for sensor matrices 
José Quinteros del Castillo
Instituto Balseiro
---
Startup routine for CIAA-ACC and AD9249

Version: 2020-09-09
Comments: This routine performs the following startup tasks for the acquisition system:
1. Enables PTP daemon.
2. Writes a specified value to potentiometer via I2C.
3. Enables power regulator to banks 12 and 13.
4. If AD9249 evaluation board is present:
    a. Configures AXI SPI module.
    b. Configures ADC to default operation values.

*/

#include "src/CIAASistAdq.h"
#include "src/SPI_control.h"

// Programa principal
int main()
{
    //enable PTP daemon
    system("/mnt/ptpd2 -b eth0 -g");

	//enable regulator
    regulator_enable();

    //detect AD9249 eval board
    // ---------------TO BE IMPLEMENTED-----------------

    //default configuration for AXI module and ADC
    spi_defaultConfig();
    adc_defaultConfig();

	return 0;
}
