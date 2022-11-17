/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
AXI data and control functions for CIAA-ACC

Version: 2020-11-21
Comments:
*/

#include "AXI_control.h"

// GENERAL PURPOSE FUNCTIONS
// writes data to a memory register
int memwrite(uint32_t addr, const uint32_t* data, size_t count) {
    int result = -1;
    int fd = open("/dev/mem", O_RDWR);
    if (fd != -1) {
        uint32_t align_addr = addr & (~(PAGE_SIZE - 1));
        off_t align_offset = addr & (PAGE_SIZE - 1);
        uint8_t* ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
            fd, align_addr);
        if (ptr) {
            int n;
            for (n = 0; n < count; n++) {
                *((volatile uint32_t*)(ptr + align_offset)) = *data;
                if (MEM_INCR) {
                    align_offset += sizeof(uint32_t);
                }
            }
            munmap(ptr, PAGE_SIZE);
            result = 0;
        }
        else
            puts("mmap fail");
        close(fd);
    }
    else
        puts("open /dev/mmap");
    return result;
}

// reads data from a memory register
int memread(uint32_t addr, uint32_t* data, size_t count) {
    int result = -1;
    int fd = open("/dev/mem", O_RDWR);
    if (fd != -1) {
        uint32_t align_addr = addr & (~(PAGE_SIZE - 1));
        off_t align_offset = addr & (PAGE_SIZE - 1);
        uint8_t* ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
            fd, align_addr);
        if (ptr) {
            while (count--) {
                *data++ = *((volatile uint32_t*)(ptr + align_offset));
                if (MEM_INCR) {
                    align_offset += sizeof(uint32_t);
                }
            }
            munmap(ptr, PAGE_SIZE);
            result = 0;
        }
        else
            puts("mmap fail");
        close(fd);
    }
    else
        puts("open /dev/mmap");
    return result;
}

// checks if FMC connector is present in CIAA-ACC
bool fmc_present()
{
    uint32_t rd_data;

    memread(CONTROL_BASE_ADDR + FMCPRESENT_OFF, &rd_data, 1);

    return !rd_data;
}

// checks if FCO1 is locked
bool locked_FCO1()
{
    uint32_t rd_data;

    memread(CONTROL_BASE_ADDR + FCO1LOCK_OFF, &rd_data, 1);

    return rd_data;
}

// checks if FCO2 is locked
bool locked_FCO2()
{
    uint32_t rd_data;

    memread(CONTROL_BASE_ADDR + FCO2LOCK_OFF, &rd_data, 1);

    return rd_data;
}

// resets FIFO
void fifo_reset()
{
    uint32_t wr_data, rd_data;
    bool condition;

    //activate reset
    wr_data = 1;
    memwrite(DATA_BASE_ADDR + FIFORST_OFF, &wr_data, 1);

    //wait for assertion of wr_rst_busy and rd_rst_busy 
    do
    {
        memread(DATA_BASE_ADDR + FIFOFLAGS_OFF, &rd_data, 1);
        condition = (rd_data & WRRSTBUSY_MASK) && (rd_data & RDRSTBUSY_MASK);
    } while (!condition);

    //deactivate reset
    wr_data = 0;
    memwrite(DATA_BASE_ADDR + FIFORST_OFF, &wr_data, 1);

    //wait for deassertion of wr_rst_busy and rd_rst_busy 
    do
    {
        memread(DATA_BASE_ADDR + FIFOFLAGS_OFF, &rd_data, 1);
        condition = (rd_data & WRRSTBUSY_MASK) && (rd_data & RDRSTBUSY_MASK);
    } while (condition);
}

// triggers async reset for duration in usec
void async_reset(unsigned int duration)
{
    uint32_t wr_data;

    wr_data = 1;
    memwrite(DATA_BASE_ADDR + ASYNCRST_OFF, &wr_data, 1);
    usleep(duration);
    wr_data = 0;
    memwrite(DATA_BASE_ADDR + ASYNCRST_OFF, &wr_data, 1);
}

//enables bank 12 and 13 regulator, setting the potentiometer to specified value via I2C
void regulator_enable()
{
    //regulator enable value
    uint32_t data = 1;

    //set potentiometer to POT_VALUE
    char command[20] = "i2cset -y 1 2f ";
    char value_str[20] = "0";
    sprintf(value_str, "%d", POT_VALUE);
    strcat(command, value_str);
    system(command);

    //enable regulator
    if (memwrite(CONTROL_BASE_ADDR + REG_OFF, &data, 1) == 0)
    {
        printf("\nPotenciómetro seteado en 0x%d. Regulador encendido correctamente.\n\n", POT_VALUE);
    }
    else
    {
        printf("\nFallo en encendido de regulador.\n\n");
    }
}

//disables bank 12 and 13 regulator
void regulator_disable()
{
    //regulator disable value
    uint32_t data = 0;

    //enable regulator
    if (memwrite(CONTROL_BASE_ADDR + REG_OFF, &data, 1) == 0)
    {
        printf("\nRegulador apagado.\n\n");
    }
    else
    {
        printf("\nFallo en apagado de regulador.\n\n");
    }
}

// sets debug output of ADC channel adc_ch to desired value
void debug_output(uint8_t value, uint8_t adc_ch)
{
    if (adc_ch < 0 || adc_ch > 15)
    {
        printf("debug_output: adc_ch must be in range 0-15.\n");
        exit(1);
    }
    uint32_t data = value;
    memwrite(DATA_BASE_ADDR + CONTROL_OFF + 4 * adc_ch, &data, 1);
}

// enables FIFO input for all ADC channels
void debug_enable()
{
    uint32_t data = 1;
    memwrite(DATA_BASE_ADDR + ENABLE_OFF, &data, 1);
}

// disables FIFO input for all ADC channels
void debug_disable()
{
    uint32_t data = 0;
    memwrite(DATA_BASE_ADDR + ENABLE_OFF, &data, 1);
}

// enables FIFO raw data (without preprocessing) input for all ADC channel
void raw_data_enable()
{
    uint32_t data = 3;
    memwrite(PREPROC_BASE_ADDR + RAW_DATA_OFF, &data, 1);
}

// disables FIFO raw data (without preprocessing) input for all ADC channel
void raw_data_disable()
{
    uint32_t data = 0;
    memwrite(PREPROC_BASE_ADDR + RAW_DATA_OFF, &data, 1);
}

// enable external trigger logic
void ext_trigger_enable()
{
    uint32_t data = 0;
    memwrite(DATA_BASE_ADDR + EXT_TRIGGER_EN_OFF, &data, 1);
}

// disable external trigger logic
void ext_trigger_disable()
{
    uint32_t wr_data = 0;
    memwrite(DATA_BASE_ADDR + EXT_TRIGGER_EN_OFF, &wr_data, 1);
}

// wait on external trigger signal
void ext_trigger_wait()
{
    printf("wait_on_ext_trigger: Waiting on external trigger...\n");
    uint32_t rd_data;
    do
    {
        memread(DATA_BASE_ADDR + EXT_TRIGGER_OFF, &rd_data, 1);
    } while (rd_data != 1);
    printf("wait_on_ext_trigger: External trigger detected.\n");
}

//// AXI DATA INTERFACE

// initializes a Multi_MemPtr_t, mapping the memory addresses passed as argument
Multi_MemPtr_t* multi_minit(uint32_t* addr, uint8_t mem_num)
{
    Multi_MemPtr_t* multiPtr = malloc(sizeof(Multi_MemPtr_t));

    multiPtr->mem_num = mem_num;
    multiPtr->addr = malloc(mem_num * sizeof(uint32_t));
    memcpy(multiPtr->addr, addr, mem_num * sizeof(uint32_t));
    multiPtr->ptr = malloc(mem_num * sizeof(uint8_t*));
    multiPtr->align_offset = malloc(mem_num * sizeof(off_t));

    int fd = open("/dev/mem", O_RDWR);
    if (fd < 0) error("/dev/mem open in multi_memopen");

    uint32_t align_addr;

    int i;
    for (i = 0; i < multiPtr->mem_num; i++)
    {
        align_addr = multiPtr->addr[i] & (~(PAGE_SIZE - 1));
        multiPtr->align_offset[i] = multiPtr->addr[i] & (PAGE_SIZE - 1);
        multiPtr->ptr[i] = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, align_addr);
        if (multiPtr->ptr[i] == MAP_FAILED) error("mmap in multi_memopen");
    }
    close(fd);

    return multiPtr;
}

// destroys a Multi_MemPtr_t, unmapping its memory spaces
void multi_mdestroy(Multi_MemPtr_t* multiPtr)
{
    int i;
    for (i = 0; i < multiPtr->mem_num; i++)
    {
        if (munmap(multiPtr->ptr[i], PAGE_SIZE) < 0) error("munmap in multi_munmap");
    }

    free(multiPtr->addr);
    free(multiPtr->ptr);
    free(multiPtr->align_offset);
    free(multiPtr);
}

// fills an AcqPack_t with external data from Acquisition System
void acquire_data(AcqPack_t* acqPack, Multi_MemPtr_t* multiPtr_flags, Multi_MemPtr_t* multiPtr_data, Multi_MemPtr_t* multiPtr_progFull, Multi_MemPtr_t* multiPtr_crc)
{
    int i, j = 0;
    uint32_t flags;

    struct timespec t;

    //wait until prog_full is asserted
    do
    {
        flags = *((volatile uint32_t*)(multiPtr_progFull->ptr[0] + multiPtr_progFull->align_offset[0]));
    } while (!(flags & PROGFULL_ASSERT));

    //reset fifo flags register

    //ID data
    acqPack->header.ch_adc = CH_ADC;
    acqPack->header.payload_size = PAYLOAD_SIZE;
    //FIFO flags
    for (i = 0; i < multiPtr_flags->mem_num; i++)
    {
        acqPack->header.fifo_flags[i] = *((volatile uint32_t*)(multiPtr_flags->ptr[i] + multiPtr_flags->align_offset[i]));
    }

    //ACQUIRE
    //Incluir modulito CRC (o suma), incluir enable y clear
    //Usar cada pulsito de read para mandarle la muestra a un CRC en la fpga
    //read data
    for (i = 0; i < CHDATA_SIZE; i++)
    {
        for (j = 0; j < multiPtr_data->mem_num; j++)
        acqPack->data[i][j].data = *((volatile uint32_t*)(multiPtr_data->ptr[j] + multiPtr_data->align_offset[j]));
    }
    //apagar y leer crc
    acqPack->crc = *((volatile uint32_t*)(multiPtr_crc->ptr[0] + multiPtr_crc->align_offset[0]));
    //read FIFO flags register to see what happened during capture.

    //timestamp
    if (clock_gettime(CLOCK_REALTIME, &t) < 0) error("clock_gettime in acquire_data");
    acqPack->header.acq_timestamp_sec = t.tv_sec;
    acqPack->header.acq_timestamp_nsec = t.tv_nsec;


    // For debugging: append data to file
    // FILE *fp;
    // fp = fopen("data.txt", "a");
    // if (fp == NULL) error("fopen in acquire_data");
    // for (i = 0; i < CHDATA_SIZE; i++)
    // {
    //     for (j = 0; j < multiPtr_data->mem_num; j++)
    //     {
    //         fprintf(fp, "%d ", acqPack->data[i][j].data);
    //     }
    //     fprintf(fp, "\n");
    // }
    // fclose(fp);    
}
