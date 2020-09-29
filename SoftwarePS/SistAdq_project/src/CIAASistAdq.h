/*
Emulation, acquisition and data processing system for sensor matrices 
José Quinteros del Castillo
Instituto Balseiro
---
Data acquisition interface for CIAA-ACC AXI bus

Version: 2020-09-23
Comments:
*/

#ifndef SRC_CIAASISTADQ_H_
#define SRC_CIAASISTADQ_H_

#define _GNU_SOURCE

#include <memory.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <stdbool.h>
#include <assert.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <sys/eventfd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include "../lib/error.h"
#include "../lib/acqPack.h"
#include "client_queues.h"
#include "client_params.h"

#include "../src/SPI_control.h"

#define PAGE_SIZE getpagesize()

// AXI interface register addresses
#define AXI_BASE_ADDR   0x43C00000
#define COREID_ADDR     (0x00<<2)
#define CONTROL_ADDR    (0x01<<2)
#define USRW1_ADDR      (0x02<<2)
#define USRW2_ADDR      (0x03<<2)
#define DEBRST_ADDR     (0x04<<2)
#define FIFODATA_ADDR   (0x05<<2)
#define FIFOFLAGS_ADDR  (0x06<<2)
#define FIFORST_ADDR    (0x07<<2)
#define FRWRCLK_ADDR    (0x08<<2)
#define FRRDEN_ADDR     (0x09<<2)
#define USRAUX_ADDR     (0xFF<<2)

//pin control module register addresses
#define CONTROL_BASE_ADDR   0x43C10000
#define REG_ADDR            (0x0<<2)
#define SPI_TRISTATE_ADDR   (0x1<<2)

//delay control module register addresses
#define DELAY_BASE_ADDR     0x43C20000
#define LOCKED_RESET_ADDR   (0x0<<2)
#define DELAY_TAP0_ADDR     (0x1<<2)
#define DELAY_TAP_NUMBER    2

//potentiometer value for required VADJ voltage
#define POT_VALUE 29

//memwrite and memread do not require memory increase
#define MEM_INCR 0

//masks to read FIFO flags register
#define RDDATACOUNT_POS 6
#define RDDATACOUNT_MASK (((1 << 18) -1) << RDDATACOUNT_POS)
#define PROGFULL_MASK (1 << 5)
#define EMPTY_MASK (1 << 4)
#define FULL_MASK (1 << 3)
#define OVERFLOW_MASK (1 << 2)
#define RDRSTBUSY_MASK (1 << 1)
#define WRRSTBUSY_MASK (1 << 0)

//debug control sequences
#define DISABLED_CTRL           0x0
#define MIDSCALE_SH_CTRL        0x1
#define PLUS_FULLSCALE_SH_CTRL  0x2
#define MINUS_FULLSCALE_SH_CTRL 0x3
#define USR_W1_CTRL             0x8
#define USR_W2_CTRL             0x9
#define ONEX_BITSYNC_CTRL       0xA
#define ONEBIT_HIGH_CTRL        0xB
#define MIXED_FREQ_CTRL         0xC
#define DESERIALIZER_CTRL       0xD
#define CONT_NBITS_CTRL         0xF

typedef struct
{
    bool full;
    bool empty;
    bool wr_rst_busy;
    bool rd_rst_busy;
    bool overflow;
    bool prog_full;
    uint32_t rd_data_count;
}fifo_flags_t;

struct Client_str;
typedef struct Client_str Client_t;

//a Multi_MemPtr_t contains several mapped memory spaces for easy read/write operations
typedef struct
{
	uint32_t * addr;
	uint8_t ** ptr;
	off_t * align_offset;
	uint8_t mem_num;
}Multi_MemPtr_t;

typedef struct
{
    Client_t * client;
    pthread_t th;
    int running;
    Multi_MemPtr_t *multiPtr;
} Acq_Thread_t;

typedef struct
{
    pthread_t th;
    int running;
    Client_t * client;
    struct sockaddr_in serv_addr;
    int sockfd;
} Tx_Thread_t;

struct Client_str
{
    Tx_Mode_t tx_mode;
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;

    Acq_Thread_t * acqTh;
    Tx_Thread_t * txTh;

    CaptureMode_t capMode;
    TriggerMode_t trigMode;

    int timerfd_start;

    int timerfd_stop;
    struct itimerspec timerfd_stop_spec;
    
    int eventfd_samples;
    int n_samples;

    uint16_t debug_output;
    uint16_t clk_divider;
};

// GENERAL PURPOSE FUNCTIONS

// writes data to a memory register
int memwrite(uint32_t addr, const uint32_t *data, size_t count);

// reads data from a memory register
int memread(uint32_t addr, uint32_t *data, size_t count);

// human readable print of FIFO flags structure
void print_fifo_flags(fifo_flags_t *flags);

// converts FIFO flag register to FIFO flags structure
void fifoflags_reg_to_struct(fifo_flags_t *flags, uint32_t * flag_reg);

// resets FIFO
void fifo_reset();

// resets debug module for duration microseconds
void debug_reset(unsigned int duration);

//enables bank 12 and 13 regulator, setting the potentiometer to specified value via I2C
void regulator_enable();

// sets debug output to desired value
void debug_output(uint8_t value);

//// AXI INTERFACE

// initializes a Multi_MemPtr_t, mapping the memory addresses passed as argument
Multi_MemPtr_t * multi_minit(uint32_t * addr, uint8_t mem_num);

// destroys a Multi_MemPtr_t, unmapping its memory spaces
void multi_mdestroy(Multi_MemPtr_t * multiPtr);

// fills an AcqPack_t with external data from Acquisition System
void acquire_data(AcqPack_t * acqPack, Multi_MemPtr_t * multiPtr);

////ACQUISITION THREAD

// initializes an Acq_Thread_t
Acq_Thread_t * AcqThreadInit(Client_t * client);

// destroys an Acq_Thread_t
void AcqThreadDestroy(Acq_Thread_t * acqTh);

// sets an acquisition thread to run
void AcqThreadRun(Acq_Thread_t * acqTh);

// stops an acquisition thread
void AcqThreadStop(Acq_Thread_t * acqTh);

//// TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t * TxThreadInit(Client_t * client, char * server_addr, const int server_portno);

// destroys a Tx_Thread_t
void TxThreadDestroy(Tx_Thread_t * txTh);

// sets a transmission thread to run
void TxThreadRun(Tx_Thread_t * txTh);

// stops a transmission thread
void TxThreadStop(Tx_Thread_t * txTh);

//// CLIENT
// initializes a Client_t
Client_t * ClientInit(ClParams_t * params);

// destroys a Client_t
void ClientDestroy(Client_t * client);

// stops a Client_t
void ClientStop(Client_t * client);

// runs a Client_t
void ClientRun(Client_t * client);

////INPUT DELAY CONTROL
// changes the input delay of pin i to value taps
void inputDelaySet(uint8_t i, uint8_t taps);

#endif /* SRC_CIAASISTADQ_H_ */
