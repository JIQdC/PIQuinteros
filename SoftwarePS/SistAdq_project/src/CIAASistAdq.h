/*
 * CIAASistAdq.h
 *
 *  Created on: Mar 2, 2020
 *      Author: jiqdc
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
#include <inttypes.h>
#include <sys/time.h>
#include <assert.h>

#define PAGE_SIZE getpagesize()

// direcciones de los registros de la interfaz AXI
#define AXI_BASE_ADDR 0x43C00000
#define SELECTCLK_ADDR 0b00000
#define CONTROL_ADDR 0b00100
#define USRW1_ADDR 0b01000
#define USRW2_ADDR 0b01100
#define COREID_ADDR 0b10000
#define RWREG_ADDR 0b10100
#define FIFODATA_ADDR 0b11000
#define FIFOFLAGS_ADDR 0b11100

//direcciones de los registros del módulo de control de pines
#define CONTROL_BASE_ADDR 0x43C10000
#define REG_ADDR 0b000000
#define SPI_TRISTATE_ADDR 0b000100

//valor del potenciómetro
#define POT_VALUE 29

// valores para memread y memwrite
#define MEM_COUNT 1
#define MEM_INCR 0

// máscaras para FIFO flags
#define EMPTY_MASK 0b10000
#define FULL_MASK 0b01000
#define OVERFLOW_MASK 0b00100
#define RDRSTBUSY_MASK 0b00010
#define WRRSTBUSY_MASK 0b00001

// secuencias de control para debug
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

// valores para clk de debug
#define CLK_FPGA_VAL 1
#define CLK_ADC_VAL 0

// estructura para almacenar los datos de las flags de la FIFO
typedef struct
{
    bool full;
    bool empty;
    bool wr_rst_busy;
    bool rd_rst_busy;
    bool overflow;
} fifo_flags_t;

// función para leer datos de un registro
int memwrite(uint32_t addr, const uint32_t *data);

// función para escribir datos a un registro
int memread(uint32_t addr, uint32_t *data);

// función para leer el estado de las flags de la FIFO
void read_fifo_flags(fifo_flags_t *flags);

//función para imprimir las flags de la FIFO
void print_fifo_flags(fifo_flags_t *flags);

long getMicrotime();


#endif /* SRC_CIAASISTADQ_H_ */
