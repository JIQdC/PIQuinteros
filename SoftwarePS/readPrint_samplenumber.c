#include <unistd.h>
#include <stdio.h>
#include <stdint.h>

#include "src/CIAASistAdq.h"

#define WORD0_MASK ((1 << 14)-1)
#define WORD1_MASK (WORD0_MASK << 14)

struct Multi_MemPtr_str
{
	uint32_t * addr;
	uint8_t ** ptr;
	off_t * align_offset;
	uint8_t mem_num;
};

// initializes a Multi_MemPtr_t, mapping the memory addresses passed as argument
static Multi_MemPtr_t * multi_minit(uint32_t * addr, uint8_t mem_num)
{
	Multi_MemPtr_t * multiPtr = malloc(sizeof(Multi_MemPtr_t));

    multiPtr->mem_num = mem_num;
	multiPtr->addr = malloc(mem_num*sizeof(uint32_t));
	memcpy(multiPtr->addr,addr,mem_num*sizeof(uint32_t));
	multiPtr->ptr = malloc(mem_num*sizeof(uint8_t*));
	multiPtr->align_offset = malloc(mem_num*sizeof(off_t));

	int fd = open("/dev/mem", O_RDWR);
	if (fd < 0) error("/dev/mem open in multi_memopen");

	uint32_t align_addr;

	int i;
	for(i=0;i<multiPtr->mem_num;i++)
	{
		align_addr = multiPtr->addr[i] & (~(PAGE_SIZE - 1));
		multiPtr->align_offset[i] = multiPtr->addr[i] & (PAGE_SIZE - 1);
		multiPtr->ptr[i] = mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, align_addr);
		if(multiPtr->ptr[i] == MAP_FAILED) error("mmap in multi_memopen");
	}
	close(fd);

	return multiPtr;
}

// destroys a Multi_MemPtr_t, unmapping its memory spaces
static void multi_mdestroy(Multi_MemPtr_t * multiPtr)
{
	int i;
	for(i=0;i<multiPtr->mem_num;i++)
	{
		if(munmap(multiPtr->ptr[i],PAGE_SIZE) < 0) error("munmap in multi_munmap");
	}

	free(multiPtr->addr);
	free(multiPtr->ptr);
	free(multiPtr->align_offset);
	free(multiPtr);
}

int main(int argc, char *argv[]) 
{
	if (argc != 2)
    {
        printf("usage: %s REQUIRED_DATA\n",argv[0]);
        exit(1);
    }

	int req_samples;
	sscanf(argv[1], "%d", &req_samples);

    //map memory space
    uint32_t addr = AXI_BASE_ADDR + FIFODATA_ADDR;
    Multi_MemPtr_t * multiPtr = multi_minit(&addr,1);

    //allocate enough space for read
    uint32_t *data = malloc(req_samples * sizeof(uint32_t));
	if(data == NULL) error("malloc de data");
    memset(data,0,req_samples*sizeof(uint32_t));

    //trigger FIFO reset
    uint32_t d_wr = 3;
    memwrite(AXI_BASE_ADDR+RESET_ADDR,&d_wr,1);

    //wait 1sec
    sleep(2);

    //read required data
    int i;
	for(i=0;i<req_samples;i++)
	{
		data[i] = *((volatile uint32_t*) (multiPtr->ptr[0] + multiPtr->align_offset[0]));
	}
    
	
    //print data
	uint16_t word0,word1;
	for(i=0;i<req_samples;i++)
	{
		word0 = data[i] & WORD0_MASK;
		word1 = (data[i] & WORD1_MASK) >> 14;

		printf("%d,%d,%d\n",i,word1,word0);
	}

    //release resources
    free(data);
    multi_mdestroy(multiPtr);

    return 0;
}