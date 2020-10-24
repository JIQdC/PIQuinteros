/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Binary file reader script

Version: 2020-10-24
Comments:
*/

#include "src/UDPserver.h"

// // Programa principal
int main(int argc, char* argv[])
{
    if (argc != 2)
    {
        printf("usage: %s PATH_TO_FILE\n", argv[0]);
        exit(1);
    }

    int fd = open(argv[1], O_RDONLY);
    if (fd < 0) error("open file");

    char fout_name[50] = "";
    strcat(fout_name, argv[1]);
    strcat(fout_name, "_full.csv");
    FILE* fout = fopen(fout_name, "w");

    AcqPack_t* acqPack = malloc(sizeof(AcqPack_t));
    if (acqPack == NULL) error("malloc de acqPack");

    int ret_rd, i, j, k, l;
    fifo_flags_t flags;

    while (1)
    {
        ret_rd = read(fd, acqPack, sizeof(AcqPack_t));
        if (ret_rd == 0)
        {
            break;
        }
        else if (ret_rd < 0)
        {
            error("read file");
        }
        else if (ret_rd < sizeof(AcqPack_t))
        {
            printf("Corrupted data!\n");
            exit(1);
        }

        fprintf(fout, "time: %.9f\n", acqPack->header.acq_timestamp_sec + 1e-9*acqPack->header.acq_timestamp_nsec);
        fprintf(fout, "FIFO flags\n");
        fprintf(fout, "ch_name,count,empty,full,pr_full,ovflow,rdrstbs,wrrstbs\n");
        for (i = 0; i<16; i++)
        {
            fifoflags_reg_to_struct(&flags, &acqPack->header.fifo_flags[i]);
            fprintf(fout, "%s,%d,%d,%d,%d,%d,%d,%d\n", g_ch_names[i], flags.rd_data_count, flags.empty, flags.full, flags.prog_full, flags.overflow, flags.rd_rst_busy, flags.wr_rst_busy);
        }

        fprintf(fout, "\n");
        j = 0;

        for (i = 0; i<CHDATA_SIZE; i++)
        {
            for (l = 1; l>-1; l--)
            {
                fprintf(fout, "%d", j);
                for (k = 0; k<16; k++)
                {
                    fprintf(fout, ",%d", acqPack->data[k][i].data16[l]);
                }
                fprintf(fout, "\n");
                j++;
            }
        }
        fprintf(fout, "\n");
    }

    printf("\n");

    close(fd);
    fclose(fout);
    return 0;
}