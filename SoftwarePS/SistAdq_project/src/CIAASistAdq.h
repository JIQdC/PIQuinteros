/*
Emulation, acquisition and data processing system for sensor matrices 
José Quinteros del Castillo
Instituto Balseiro
---
Data acquisition interface for CIAA-ACC AXI bus

Version: 2020-06-11
Comments:
*/

#ifndef SRC_CIAASISTADQ_H_
#define SRC_CIAASISTADQ_H_

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

#include "../lib/error.h"
#include "../lib/acqPack.h"
#include "client_queues.h"
#include "client_params.h"

#define PAGE_SIZE getpagesize()

// AXI interface register addresses
#define AXI_BASE_ADDR 0x43C00000
#define SELECTCLK_ADDR 0b00000
#define CONTROL_ADDR 0b00100
#define USRW1_ADDR 0b01000
#define USRW2_ADDR 0b01100
#define COREID_ADDR 0b10000
#define RWREG_ADDR 0b10100
#define FIFODATA_ADDR 0b11000
#define FIFOFLAGS_ADDR 0b11100
#define RESET_ADDR 0b100000

//pin control module register addresses
#define CONTROL_BASE_ADDR 0x43C10000
#define REG_ADDR 0b000000
#define SPI_TRISTATE_ADDR 0b000100

//potentiometer value for required VADJ voltage
#define POT_VALUE 29

//memwrite and memread do not require memory increase
#define MEM_INCR 0

//masks to read FIFO flags register
#define EMPTY_MASK 0b10000
#define FULL_MASK 0b01000
#define OVERFLOW_MASK 0b00100
#define RDRSTBUSY_MASK 0b00010
#define WRRSTBUSY_MASK 0b00001

//debug control sequences
#define APAGADO_CTRL 0b000
#define MIDSCALE_SH_CTRL 0b001
#define PLUS_FULLSCALE_SH_CTRL 0b0010
#define MINUS_FULLSCALE_SH_CTRL 0b0011
#define CHECKERBOARD_CTRL 0b0100
#define ONEZERO_WORDTOGGLE_CTRL 0b0111
#define USER_WORDTOGGLE_CTRL 0b1000
#define ONEZERO_BITTOGGLE_CTRL 0b1001
#define ONEX_BITSYNC_CTRL 0b1010
#define ONEBIT_HIGH_CTRL 0b1011
#define MIXED_FREQ_CTRL 0b1100
#define DESERIALIZER_CTRL 0b1101
#define LIBRE_CTRL 0b1100
#define CONT_NBITS_CTRL 0b1111

typedef struct
{
    bool full;
    bool empty;
    bool wr_rst_busy;
    bool rd_rst_busy;
    bool overflow;
}fifo_flags_t;

struct Client_str;
typedef struct Client_str Client_t;

struct Multi_MemPtr_str;
typedef struct Multi_MemPtr_str Multi_MemPtr_t;

typedef struct
{
    Client_t * client;
    pthread_t th;
    int running;
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;
    Multi_MemPtr_t *multiPtr;
} Acq_Thread_t;

typedef struct
{
    pthread_t th;
    int running;
    Rx_Queue_t *rxQ;
    Tx_Queue_t *txQ;
    #if TX_MODE == 1
    char *server_addr;
    int server_portno;
    int sockfd;
    #endif
} Tx_Thread_t;

struct Client_str
{
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
};

// writes data to a memory register
int memwrite(uint32_t addr, const uint32_t *data, size_t count);

// reads data from a memory register
int memread(uint32_t addr, uint32_t *data, size_t count);

// human readable print of FIFO flags structure
void print_fifo_flags(fifo_flags_t *flags);

// converts FIFO flag register to FIFO flags structure
void fifoflags_reg_to_struct(fifo_flags_t *flags, uint8_t * flag_reg);

////ACQUISITION THREAD

// initializes an Acq_Thread_t
Acq_Thread_t * AcqThreadInit(Client_t * client, Rx_Queue_t * rxQ, Tx_Queue_t * txQ);

// destroys an Acq_Thread_t
void AcqThreadDestroy(Acq_Thread_t * acqTh);

// sets an acquisition thread to run
void AcqThreadRun(Acq_Thread_t * acqTh);

// stops an acquisition thread
void AcqThreadStop(Acq_Thread_t * acqTh);

//// TRANSMISSION THREAD
// initializes a Tx_Thread_t
Tx_Thread_t * TxThreadInit(Tx_Queue_t * txQ, Rx_Queue_t * rxQ
#if TX_MODE == 1
, char * server_addr, const int server_portno
#endif
);

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
#endif /* SRC_CIAASISTADQ_H_ */
