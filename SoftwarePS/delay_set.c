#include "src/SPI_control.h"

int main(int argc, char *argv[]) 
{
    uint8_t delay_val,pin;

    if (argc != 3)
    {
        printf("usage: %s pin delay_val\n",argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hhd", &pin);
    sscanf(argv[2], "%hhd", &delay_val);

    //change IDELAY to i value
    inputDelaySet(pin,delay_val);

	return 0;
}