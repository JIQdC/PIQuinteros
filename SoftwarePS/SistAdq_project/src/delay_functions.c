/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Control functions for input delays and calibration

Version: 2020-10-21
Comments:
*/

#include "delay_functions.h"

////INPUT DELAY CONTROL

// changes the input delay of frame pin i (0 for BANK12, 1 for BANK13) to value taps.
int inputDelaySet_frame(uint8_t i, uint8_t taps)
{
    uint32_t rd_val = 0, wr_val = 0;
    uint32_t locked_addr, ld_addr, in_addr, out_addr;

    if (i < 0 || i > 1)
    {
        printf("inputDelaySet_frame: frame pin i must be 0 for BANK12 or 1 for BANK13.\n");
        exit(1);
    }

    if (taps < 0 || taps > 31)
    {
        printf("inputDelaySet_frame: taps must be between 0 and 31.\n");
        exit(1);
    }

    if (i)
    {
        locked_addr = DELAY_BASE_ADDR + LOCKED13_OFF;
        ld_addr = DELAY_BASE_ADDR + FRAME_LD_13_OFF;
        in_addr = DELAY_BASE_ADDR + FRAME_IN_13_OFF;
        out_addr = DELAY_BASE_ADDR + FRAME_OUT_13_OFF;
    }
    else
    {
        locked_addr = DELAY_BASE_ADDR + LOCKED12_OFF;
        ld_addr = DELAY_BASE_ADDR + FRAME_LD_12_OFF;
        in_addr = DELAY_BASE_ADDR + FRAME_IN_12_OFF;
        out_addr = DELAY_BASE_ADDR + FRAME_OUT_12_OFF;
    }

    //assert DELAY CTRL is locked for corresponding FPGA bank
    memread(locked_addr, &rd_val, 1);
    if (rd_val != 1)
    {
        printf("inputDelaySet_frame: DELAY CTRL is not locked!\n");
        exit(1);
    }

    //set input delay values
    wr_val = taps;
    memwrite(in_addr, &wr_val, 1);

    //trigger reset for 20 us
    wr_val = 1;
    memwrite(ld_addr, &wr_val, 1);
    usleep(20);
    wr_val = 0;
    memwrite(ld_addr, &wr_val, 1);
    rd_val = 0;

    //wait for DELAY CTRL lock
    do
    {
        memread(locked_addr, &rd_val, 1);
    } while (rd_val != 1);

    //assert desired value is set
    rd_val = 0;
    memread(out_addr, &rd_val, 1);
    if (rd_val != taps)
    {
        printf("inputDelaySet_frame: tap %d not set to desired value.\n", i);
        exit(1);
    }

    usleep(10);

    return 0;
}

// changes the input delay of adc_ch to value taps
int inputDelaySet_data(uint8_t adc_ch, uint8_t taps)
{
    uint32_t rd_val = 0, wr_val = 0;
    uint32_t locked_addr;

    if (taps < 0 || taps > 31)
    {
        printf("inputDelaySet_data: taps must be between 0 and 31.\n");
        exit(1);
    }

    //assert DELAY CTRL is locked for corresponding FPGA bank
    if (g_adcPinPositions[adc_ch]) locked_addr = DELAY_BASE_ADDR + LOCKED13_OFF;
    else locked_addr = DELAY_BASE_ADDR + LOCKED12_OFF;
    memread(locked_addr, &rd_val, 1);
    if (rd_val != 1)
    {
        printf("inputDelaySet_data: DELAY CTRL is not locked!\n");
        exit(1);
    }

    //set input delay values
    wr_val = taps;
    memwrite(DELAY_BASE_ADDR + DATA_IN_OFF + 4 * adc_ch, &wr_val, 1);

    //trigger reset for 20 us
    wr_val = 1;
    memwrite(DELAY_BASE_ADDR + DATA_LD_OFF + 4 * adc_ch, &wr_val, 1);
    usleep(20);
    wr_val = 0;
    memwrite(DELAY_BASE_ADDR + DATA_LD_OFF + 4 * adc_ch, &wr_val, 1);
    rd_val = 0;

    //wait for DELAY CTRL lock
    do
    {
        memread(locked_addr, &rd_val, 1);
    } while (rd_val != 1);

    //assert desired value is set
    rd_val = 0;
    memread(DELAY_BASE_ADDR + DATA_OUT_OFF + 4 * adc_ch, &rd_val, 1);
    if (rd_val != taps)
    {
        printf("inputDelaySet_data: tap %d not set to desired value.\n", adc_ch);
        exit(1);
    }

    usleep(10);

    return 0;
}

// computes bad samples acquired when compared to a calibration pattern
static int computeBadSamples(uint8_t adc_ch)
{
    int result;
    uint16_t expanded_data[2*CHDATA_SIZE];
    int j;
    AcqPack_t* acqPack = malloc(sizeof(AcqPack_t));
    memset(acqPack, 0, sizeof(AcqPack_t));

    //map memory spaces to read FIFO flags and data
    Multi_MemPtr_t* mPtr_flags, * mPtr_data, * mPtr_progFull;
    uint32_t flags_addr, data_addr, progFull_addr;
    flags_addr = DATA_BASE_ADDR+FIFOFLAGS_OFF+4*adc_ch;
    data_addr = DATA_BASE_ADDR+FIFODATA_OFF+4*adc_ch;
    progFull_addr = DATA_BASE_ADDR+PROGFULL_OFF;
    mPtr_flags = multi_minit(&flags_addr, 1);
    mPtr_data = multi_minit(&data_addr, 1);
    mPtr_progFull = multi_minit(&progFull_addr, 1);

    //reset FIFO and debug modules
    async_reset(10);
    fifo_reset();

    //select debug output from deserializer and enable FIFO input
    debug_output(DESERIALIZER_CTRL, adc_ch);
    debug_enable();

    //acquire
    acquire_data(acqPack, mPtr_flags, mPtr_data, mPtr_progFull);

    //disable FIFO input and debug output
    debug_disable();
    debug_output(DISABLED_CTRL, adc_ch);

    //expand data
    for (j = 0; j<CHDATA_SIZE; j++)
    {
        expanded_data[2*j] = acqPack->data[0][j].data16[1];
        expanded_data[2*j+1] = acqPack->data[0][j].data16[0];
    }

    result = 0;
    //compute bad samples checking if the difference between them differs from CAL_DIFF
    for (j = 1; j<2*CHDATA_SIZE; j++)
    {
        if ((abs(expanded_data[j]-expanded_data[j-1]))!=CAL_DIFF) result++;
    }

    //free resources
    free(acqPack);
    multi_mdestroy(mPtr_flags);
    multi_mdestroy(mPtr_data);
    multi_mdestroy(mPtr_progFull);

    return result;
}

//sets input delays to optimal values
int inputDelayCalibrate()
{
    //set clock divider to 0
    adc_clkDividerSet(0);
    //set test pattern to CAL_PATTERN
    adc_testPattern(CAL_PATTERN);

    //get two lists for each bank
    uint8_t i;
    uint8_t* bank12 = malloc(16*sizeof(uint8_t));
    memset(bank12, 0, 16*sizeof(uint8_t));
    uint8_t* bank13 = malloc(16*sizeof(uint8_t));
    memset(bank13, 0, 16*sizeof(uint8_t));
    uint8_t bank12_size = 0, bank13_size = 0;

    for (i = 0; i<16; i++)
    {
        if (g_adcPinPositions[i])
        {
            bank13[bank13_size] = i;
            bank13_size++;
        }
        else
        {
            bank12[bank12_size] = i;
            bank12_size++;
        }
    }

    //calibrate bank 12 and 13
    bool frame;
    uint8_t* active_list;
    uint8_t active_size;
    int j, k, l, m;
    int bad_samples_matrix[TAP_MAX][TAP_MAX];
    int bad_samples_line[TAP_MAX];
    int fr_win[2];
    memset(fr_win, 0, 2*sizeof(int));
    uint8_t fr_opt_delay = 0, data_opt_delay = 0;
    bool in_window = false;
    bool fr_opt_found = false;
    int bank_name[2] = { 12,13 };

    for (i = 0; i<2; i++)
    {
        if (i)
        {
            active_list = bank13;
            active_size = bank13_size;
        }
        else
        {
            active_list = bank12;
            active_size = bank12_size;
        }
        frame = i;

        //first calibrate frame and data channel jointly. Use first element of active_list as reference
        j = 0;

        //fill frame/data bad samples matrix acquiring data
        for (k = 0; k<TAP_MAX; k++)
        {
            for (l = 0; l<TAP_MAX; l++)
            {
                //set frame delay to k and data delay to l
                inputDelaySet_frame(frame, k);
                inputDelaySet_data(active_list[j], l);

                //compute bad samples and save to matrix
                bad_samples_matrix[k][l] = computeBadSamples(j);
            }
        }


        //search in matrix for bad_samples below BAD_SAMPLES_TRESHOLD
        l = 0; m = 0;
        while (l < TAP_MAX && !fr_opt_found)
        {
            for (k = 0; k<TAP_MAX; k++)
            {
                if (bad_samples_matrix[k][l] < BAD_SAMPLES_TRESHOLD)
                {
                    if (!in_window)
                    {
                        //we have entered the window
                        in_window = true;
                        //save lower window bound
                        fr_win[m] = k;
                        m++;
                    }
                }
                else if (in_window)
                {
                    //we have exited the window
                    in_window = false;
                    //save upper window bound
                    fr_win[m] = k;
                    m++;
                }
                if (m > 1)
                {
                    fr_opt_found = true;
                    break;
                }
            }
            l++;
        }
        //fail catastrophically if optimal window is not found
        if (!fr_opt_found)
        {
            printf("inputDelayCalibrate: failed to calibrate frame for bank %d!\n", bank_name[frame]);
            exit(1);
        }
        //optimal frame delay is average of lower and upper window bounds
        fr_opt_delay = (int)((fr_win[0]+fr_win[1])/2);
        inputDelaySet_frame(frame, fr_opt_delay);
        printf("Delay for frame in bank %d set to %d.\n", bank_name[frame], fr_opt_delay);

        //calculate optimal data delay for data channels in this bank
        for (k = 0; k<active_size; k++)
        {
            for (l = 0; l<TAP_MAX; l++)
            {
                //set data delay to l
                inputDelaySet_data(active_list[k], l);
                //compute bad samples and save to line
                bad_samples_line[l] = computeBadSamples(active_list[k]);
            }

            m = 0;
            in_window = false;
            memset(fr_win, 0, 2*sizeof(int));

            for (l = 0; l<TAP_MAX; l++)
            {
                if (bad_samples_line[l] < BAD_SAMPLES_TRESHOLD)
                {
                    if (!in_window)
                    {
                        //we have entered the window
                        in_window = true;
                        //save lower window bound
                        fr_win[m] = l;
                        m++;
                    }
                }
                else if (in_window)
                {
                    //we have exited the window
                    in_window = false;
                    //save upper window bound
                    fr_win[m] = l;
                    m++;
                }
                if (m > 1)
                {
                    //data opt found
                    break;
                }
            }
            if (fr_win[0] == fr_win[1])
            {
                //unable to find optimal for this data. print warning and continue
                printf("Unable to find optimal delay value for data channel %d in bank %d.\n", active_list[k], bank_name[i]);
                continue;
            }

            //optimal data delay is average of lower and upper window bounds
            data_opt_delay = (int)((fr_win[0]+fr_win[1])/2);
            inputDelaySet_data(active_list[k], data_opt_delay);
            printf("Delay for data channel %d in bank %d set to %d.\n", active_list[k], bank_name[frame], data_opt_delay);
        }
    }

    free(bank12);
    free(bank13);

    return 0;
}