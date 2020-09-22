#include "../SistAdq_project/src/CIAASistAdq.h"

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

    char fout_name[40] = "";
    strcat(fout_name,argv[1]);
    strcat(fout_name,"_full.csv");
    FILE * fout = fopen(fout_name,"w");

    AcqPack_t * acqPack = malloc(sizeof(AcqPack_t));
    if(acqPack == NULL) error("malloc de acqPack");

    int ret_rd, i,j;
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

        fprintf(fout,"time: %.9f\n",acqPack->header.acq_timestamp_sec + 1e-9*acqPack->header.acq_timestamp_nsec);
        fifoflags_reg_to_struct(&flags,&acqPack->header.fifo_flags);
        fprintf(fout,"FIFO flags:\n");
        fprintf(fout,"count\tempty\tfull\tpr_full\tovflow\trdrstbs\twrrstbs\n");
        fprintf(fout,"%d\t\t%d\t\t%d\t\t%d\t\t%d\t\t%d\t\t%d\n",flags.rd_data_count,flags.empty,flags.full,flags.prog_full,flags.overflow,flags.rd_rst_busy,flags.wr_rst_busy);

        j=0;
        
        for(i=0;i<PACK_SIZE;i++)
        {
            word0 = acqPack->data[i] & WORD0_MASK;
            word1 = (acqPack->data[i] & WORD1_MASK) >> 14;
            fprintf(fout,"%d,%d\n",j,word1);
            j++;
            fprintf(fout,"%d,%d\n",j,word0);
            j++;
        }
        printf("\n");
    }

    close(fd);
    fclose(fout);
	return 0;
}