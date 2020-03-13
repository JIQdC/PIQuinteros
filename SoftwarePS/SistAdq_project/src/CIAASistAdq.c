/*
 * CIAASistAdq.c
 *
 *  Created on: Mar 2, 2020
 *      Author: jiqdc
 */


/*
Funciones para interfaz de control y adquisición de datos para sistema de adquisición de AD9249 con CIAA-ACC
José Quinteros del Castillo
Instituto Balseiro

Versión: 2020-02-28
Comentarios:
*/

#include "CIAASistAdq.h"

// función para leer datos de un registro
int memwrite(uint32_t addr, const uint32_t *data) {
	int result = -1;
	int fd = open("/dev/mem", O_RDWR);
	if (fd != -1) {
		uint32_t align_addr = addr & (~(PAGE_SIZE - 1));
		off_t align_offset = addr & (PAGE_SIZE - 1);
		uint8_t *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
				fd, align_addr);
		if (ptr) {
			int n;
			for (n = 0; n < MEM_COUNT; n++) {
				*((volatile uint32_t*) (ptr + align_offset)) = *data;
				if (MEM_INCR) {
					align_offset += sizeof(uint32_t);
				}
			}
			munmap(ptr, PAGE_SIZE);
			result = 0;
		} else
			puts("mmap fail");
		close(fd);
	} else
		puts("open /dev/mmap");
	return result;
}

// función para escribir datos a un registro
int memread(uint32_t addr, uint32_t *data) {
	size_t count = MEM_COUNT;
	int result = -1;
	int fd = open("/dev/mem", O_RDWR);
	if (fd != -1) {
		uint32_t align_addr = addr & (~(PAGE_SIZE - 1));
		off_t align_offset = addr & (PAGE_SIZE - 1);
		uint8_t *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
				fd, align_addr);
		if (ptr) {
			while (count--) {
				*data++ = *((volatile uint32_t*) (ptr + align_offset));
				if (MEM_INCR) {
					align_offset += sizeof(uint32_t);
				}
			}
			munmap(ptr, PAGE_SIZE);
			result = 0;
		} else
			puts("mmap fail");
		close(fd);
	} else
		puts("open /dev/mmap");
	return result;
}

// función para leer el estado de las flags de la FIFO
void read_fifo_flags(fifo_flags_t *flags)
{
    //leo el registro que tiene las flags
    uint32_t flag_reg;
    memread(AXI_BASE_ADDR + FIFOFLAGS_ADDR,&flag_reg);

	//asigno los valores leídos a la estructura flags usando bitwise and y máscaras
	flags->empty = flag_reg & EMPTY_MASK;
	flags->full = flag_reg & FULL_MASK;
	flags->overflow = flag_reg & OVERFLOW_MASK;
	flags->rd_rst_busy = flag_reg & RDRSTBUSY_MASK;
	flags->wr_rst_busy = flag_reg & WRRSTBUSY_MASK;
}

//función para imprimir las flags de la FIFO
void print_fifo_flags(fifo_flags_t *flags)
{
	printf("FIFO empty: %d\n",flags->empty);
	printf("FIFO full: %d\n",flags->full);
	printf("FIFO overflow: %d\n",flags->overflow);
	printf("FIFO wr_rst busy: %d\n",flags->wr_rst_busy);
	printf("FIFO rd_rst busy: %d\n",flags->rd_rst_busy);
}

long getMicrotime(){
	struct timeval currentTime;
	gettimeofday(&currentTime, NULL);
	return currentTime.tv_sec * (int)1e6 + currentTime.tv_usec;
}
