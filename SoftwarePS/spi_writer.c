#include "src/CIAASistAdq.h"
#include "src/SPI_control.h"

// // Programa principal
int main(int argc, char *argv[]) 
{
    uint32_t data = 0;
    memset(&data,0,sizeof(uint32_t));
    uint16_t address;
    int adc_number;

	sscanf(argv[1], "%d", &adc_number);
	sscanf(argv[2], "%08hX", &address);
	sscanf(argv[3], "%08X", &data);

    SPI_slaves_t slave;

    switch (adc_number)
    {
    case 1:
        slave = adc1;
        break;

    case 2:
        slave = adc2;
        break;
    
    default:
        break;
    }

    //reseteo el bus SPI
    spi_reset();
    
    //parámetros de configuración del bus SPI
    spi_CR_config(ManualSSelAssertEn,0);
    spi_CR_config(SPIsystemEn,1);
    spi_CR_config(MasterMode,1);
    spi_CR_config(MasterTransInhibit,0);
    spi_ssel(slave);

    spi_write(address,&data,1);
    
    printf("\nSe escribió el valor 0x%02X en la dirección 0x%02X.\n",data, address);

    //apago sistema
    spi_CR_config(SPIsystemEn,0);
	
	return 0;
}