#include "src/SPI_control.h"

// // Programa principal
int main(int argc, char *argv[]) 
{
    uint8_t value;

    if (argc != 2)
    {
        printf("usage: %s test_pattern_code\n",argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%08hhX", &value);

    if(value < 0 || value > 12)
    {
        printf("test_pattern_code must be between 0x0 and 0xC.\n");
        exit(1);
    }	
	
    //configure both ADCs equally
	SPI_slaves_t slaves[2] = {adc1, adc2};

	int i;
	uint32_t wr_data = value;

	for(i=0;i<2;i++)
	{
		spi_ssel(slaves[i]);

		//output test pattern
		spi_write(ADC_TESTMODE,&wr_data,1);
	}   

    usleep(10);

	return 0;
}