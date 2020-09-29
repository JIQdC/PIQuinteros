#include "src/SPI_control.h"

// // Programa principal
int main(int argc, char *argv[]) 
{
    adc_testPattern_t testPattern;

    if (argc != 2)
    {
        printf("usage: %s test_pattern_value\n",argv[0]);
        printf("Supported test pattern values are:\n");
        printf("\toff \n\tmidShort \n\tposFullScale \n\tnegFullScale \n");
        printf("\tcheckerboard \n\tPNseqLong \n\tPNseqShort \n\toneZeroWordToggle\n");
        printf("\toneZeroBitToggle \n\toneXsync \n\toneBitHigh \n\tmixedFrequency\n");
        exit(1);
    }

    if(!strcmp(argv[1],"off")) testPattern=off;
    else if(!strcmp(argv[1],"midShort")) testPattern=midShort;
    else if(!strcmp(argv[1],"posFullScale")) testPattern=posFullScale;
    else if(!strcmp(argv[1],"negFullScale")) testPattern=negFullScale;
    else if(!strcmp(argv[1],"checkerboard")) testPattern=checkerboard;
    else if(!strcmp(argv[1],"PNseqLong")) testPattern=PNseqLong;
    else if(!strcmp(argv[1],"PNseqShort")) testPattern=PNseqShort;
    else if(!strcmp(argv[1],"oneZeroWordToggle")) testPattern=oneZeroWordToggle;
    else if(!strcmp(argv[1],"oneZeroBitToggle")) testPattern=oneZeroBitToggle;
    else if(!strcmp(argv[1],"oneXsync")) testPattern=oneXsync;
    else if(!strcmp(argv[1],"oneBitHigh")) testPattern=oneBitHigh;
    else if(!strcmp(argv[1],"mixedFrequency")) testPattern=mixedFrequency;
    else
    {
        printf("Invalid test pattern entered.\n");
        printf("Supported test pattern values are:\n");
        printf("\toff \n\tmidShort \n\tposFullScale \n\tnegFullScale \n");
        printf("\tcheckerboard \n\tPNseqLong \n\tPNseqShort \n\toneZeroWordToggle\n");
        printf("\toneZeroBitToggle \n\toneXsync \n\toneBitHigh \n\tmixedFrequency\n");
    }
    
    adc_testPattern(testPattern);

	return 0;
}