#include "src/CIAASistAdq.h"
#include "src/SPI_control.h"

// // Programa principal
int main(int argc, char *argv[]) 
{
    uint8_t clk_divider;
    uint8_t test_pattern;
    uint16_t sample_dif;

    if (argc != 4)
    {
        printf("usage: %s clock_divider test_pattern_code sample_dif\n",argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hhd", &clk_divider);

    if(clk_divider < 1 || clk_divider > 8)
    {
        printf("clk_divider must be in range 1 - 8.\n");
        exit(1);
    }	

    sscanf(argv[2], "%hhd", &test_pattern);

    if(test_pattern < 0x0 || test_pattern > 0xC)
    {
        printf("test_pattern must be in range 0x0 - 0xC.\n");
        exit(1);
    }	

    sscanf(argv[3], "%hd", &sample_dif);
    if(sample_dif < 0 || sample_dif > ((1<<14)-1))
    {
        printf("sample_dif must be in range 0 - %d.\n",((1<<14)-1));
        exit(1);
    }
    Multi_MemPtr_t * memPtr = malloc(sizeof(Multi_MemPtr_t));
    memset(memPtr,0,sizeof(Multi_MemPtr_t));

    AcqPack_t * acqPack = malloc(sizeof(AcqPack_t));
    memset(acqPack,0,sizeof(AcqPack_t));

    uint16_t expanded_data[2*CHDATA_SIZE];
    memset(expanded_data,0,2*CHDATA_SIZE*sizeof(uint16_t));

    int i,j,k;

    int result;
    uint32_t addr[2];

    //map memory spaces to read FIFO flags and data
	addr[0] = AXI_BASE_ADDR + FIFOFLAGS_ADDR;
	addr[1] = AXI_BASE_ADDR + FIFODATA_ADDR;
	memPtr = multi_minit(addr,2);

    //configure ADC to desired test conditions
    adc_clkDividerSet(clk_divider);
    adc_testPattern(test_pattern);

    printf("Rows: Tap 0 (frame)\n");
    printf("Columns: Tap 1 (data)\n");

    printf("\t");
    for(i=0;i<32;i++) printf("T%d\t",i);
    printf("\n");
    for(i=0;i<32;i++)
    {
        printf("T%d\t",i);
        for(k=0;k<32;k++)
        {
            //change IDELAY 0 to i value and IDELAY 1 to k value
            inputDelaySet(0,i);
            inputDelaySet(1,k);

            //reset FIFO and debug modules
            debug_reset(10);
            fifo_reset();

            //enable debug output from deserializer
            debug_output(DESERIALIZER_CTRL);

            //acquire
            acquire_data(acqPack,memPtr);

            //disable debug output
            debug_output(DISABLED_CTRL);

            //expand data
            for(j=0;j<CHDATA_SIZE;j++)
            {
                expanded_data[2*j] = (acqPack->data[j] & WORD1_MASK) >> 14;
                expanded_data[2*j+1] = acqPack->data[j] & WORD0_MASK;
            }

            result = 0;
            //compute bad samples checking if the difference between them differs from SAMPLE_DIF
            for(j=1;j<2*CHDATA_SIZE;j++)
            {
                if((abs(expanded_data[j]-expanded_data[j-1])) != sample_dif) result++;
            }

            //print result
            printf("%d\t",result);
        }
        printf("\n");
    }

    //return both input delays to 0
    inputDelaySet(0,0);
    inputDelaySet(1,0);

    free(memPtr);
    free(acqPack);

	return 0;
}