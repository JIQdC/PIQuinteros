/*
 * Copyright (c) 2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

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

#define PAGE_SIZE getpagesize()

int memwrite(uint32_t addr, const uint32_t *data, size_t count, int incr) {
	int result = -1;
	int fd = open("/dev/mem", O_RDWR);
	if (fd != -1) {
		uint32_t align_addr = addr & (~(PAGE_SIZE - 1));
		off_t align_offset = addr & (PAGE_SIZE - 1);
		uint8_t *ptr = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED,
				fd, align_addr);
		if (ptr) {
			int n;
			for (n = 0; n < count; n++) {
				*((volatile uint32_t*) (ptr + align_offset)) = *data;
				if (incr) {
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

int memread(uint32_t addr, uint32_t *data, size_t count, int incr) {
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
				if (incr) {
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

// Programa principal
int main(int argc, char *argv[]) {

	uint32_t registro, valor;
	sscanf(argv[1], "%08X", &registro);
	sscanf(argv[2], "%08X", &valor);
	printf("Registro a escribir: %08X\n", registro);
	printf("Valor a escribir: %08X\n", valor);

	memwrite(registro, &valor, 1, 0);

	return 0;
}