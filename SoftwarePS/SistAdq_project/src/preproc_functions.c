/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Preprocessing stages control functions

Version: 2020-10-24
Comments:
*/

#include "preproc_functions.h"

//set downsampling threshold to value val
int downsampling_set(const uint16_t val)
{
    if (val < 0 || val >((1 << DOWNSMPL_TRESH_REG_SIZE)-1))
    {
        printf("downsampling_set: val out of range.\n");
        exit(1);
    }

    //load val in treshold register
    uint32_t wr_data = val;
    memwrite(DOWNSMPL_BASE_ADDR + TRESH_VAL_OFF, &wr_data, 1);

    //assert load for treshold register
    wr_data = 1;
    memwrite(DOWNSMPL_BASE_ADDR + TRESH_LD_OFF, &wr_data, 1);

    //wait
    usleep(1);

    //deassert load for treshold register
    wr_data = 0;
    memwrite(DOWNSMPL_BASE_ADDR + TRESH_LD_OFF, &wr_data, 1);

    //to be implemented: read treshold register and check if it is set to original value

    return 0;
}