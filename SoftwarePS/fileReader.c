#include "src/CIAASistAdq.h"

#define WORD0_MASK ((1 << 14)-1)
#define WORD1_MASK (WORD0_MASK << 14)

// // Programa principal
int main(int argc, char *argv[]) 
{

    if (argc != 2)
    {
        printf("usage: %s PATH_TO_FILE\n",argv[0]);
        exit(1);
    }
    
    
    int fd = open(argv[1],O_RDONLY);
    if(fd < 0) error("open file");

    AcqPack_t * acqPack = malloc(sizeof(acqPack));
    
    int ret_rd, i;
    uint16_t word0,word1;
    fifo_flags_t flags;

    while(1)
    {
        ret_rd = read(fd,acqPack,sizeof(AcqPack_t));
        if(ret_rd == 0)
        {
            break;
        }
        else if(ret_rd < 0)
        {
            error("read file");
        }
        else if(ret_rd < sizeof(AcqPack_t))
        {
            printf("Corrupted data!\n");
            exit(1);
        }

        printf("time: %.9f\n",acqPack->header.acq_timestamp.tv_sec + 1e-9*acqPack->header.acq_timestamp.tv_nsec);
        printf("index,word1,word0,empty,full,overflow,rd_rst_busy,wr_rst_busy");
        for(i=0;i<PACK_SIZE;i++)
        {
            word0 = acqPack->data[i] & WORD0_MASK;
            word1 = (acqPack->data[i] & WORD1_MASK) >> 14;
            fifoflags_reg_to_struct(&flags,&acqPack->flags[i]);
            printf("%d,%d,%d,%d,%d,%d,%d,%d\n",i,word1,word0,flags.empty,flags.full,flags.overflow,flags.rd_rst_busy,flags.wr_rst_busy);
        }
        printf("\n");
    }

    
    close(fd);
	return 0;
}