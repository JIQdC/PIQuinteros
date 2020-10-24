/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Data packaging format

Version: 2020-10-24
Comments:
*/

#include "acqPack.h"

// converts FIFO flag register to FIFO flags structure
void fifoflags_reg_to_struct(fifo_flags_t* flags, uint32_t* flag_reg)
{
    flags->empty = *flag_reg & EMPTY_MASK;
    flags->full = *flag_reg & FULL_MASK;
    flags->overflow = *flag_reg & OVERFLOW_MASK;
    flags->rd_rst_busy = *flag_reg & RDRSTBUSY_MASK;
    flags->wr_rst_busy = *flag_reg & WRRSTBUSY_MASK;
    flags->prog_full = *flag_reg & PROGFULL_MASK;
    flags->rd_data_count = *flag_reg & RDDATACOUNT_MASK;
}

// human readable print of FIFO flags structure
void print_fifo_flags(fifo_flags_t* flags)
{
    printf("FIFO empty: %d\n", flags->empty);
    printf("FIFO full: %d\n", flags->full);
    printf("FIFO overflow: %d\n", flags->overflow);
    printf("FIFO wr_rst busy: %d\n", flags->wr_rst_busy);
    printf("FIFO rd_rst busy: %d\n", flags->rd_rst_busy);
    printf("FIFO prog full: %d\n", flags->prog_full);
    printf("FIFO read data count: %d\n", flags->rd_data_count);
}