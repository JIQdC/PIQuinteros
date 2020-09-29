#include "src/CIAASistAdq.h"
#include "src/SPI_control.h"
#include "lib/intToBase.h"

// // Programa principal
int main(int argc, char *argv[]) 
{
    uint16_t sample_num;

    if (argc != 2)
    {
        printf("usage: %s sample_num\n",argv[0]);
        exit(1);
    }

    sscanf(argv[1], "%hd", &sample_num);
    if((sample_num % 2) != 0)
    {
        printf("sample_num must be even\n");
        exit(1);
    }

    Multi_MemPtr_t * memPtr = malloc(sizeof(Multi_MemPtr_t));
    memset(memPtr,0,sizeof(Multi_MemPtr_t));

    AcqPack_t * acqPack = malloc(sizeof(AcqPack_t));
    memset(acqPack,0,sizeof(AcqPack_t));

    int j;

    uint32_t addr[2];
    char* buffer;

    //map memory spaces to read FIFO flags and data
	addr[0] = AXI_BASE_ADDR + FIFOFLAGS_ADDR;
	addr[1] = AXI_BASE_ADDR + FIFODATA_ADDR;
	memPtr = multi_minit(addr,2);

    //reset FIFO and debug modules
    debug_reset(10);
    fifo_reset();

    //enable debug output from deserializer
    debug_output(DESERIALIZER_CTRL);

    //acquire
    acquire_data(acqPack,memPtr);

    //disable debug output
    debug_output(DISABLED_CTRL);

    //print required samples
    for(j=0;j<sample_num/2;j++)
    {
        buffer = intToBase((acqPack->data[j] & WORD1_MASK) >> 14,2);
        printf("%s\n",buffer);
        buffer = intToBase(acqPack->data[j] & WORD0_MASK,2);
        printf("%s\n",buffer);
    }

    free(memPtr);
    free(acqPack);

	return 0;
}