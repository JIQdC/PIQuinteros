#include "src/CIAASistAdq.h"

// // Programa principal
int main(int argc, char *argv[]) 
{   
    uint32_t rd_data;

    memread(AXI_BASE_ADDR+FIFOFLAGS_ADDR,&rd_data,1);

    fifo_flags_t *flags = malloc(sizeof(fifo_flags_t));
    memset(flags,0,sizeof(fifo_flags_t));
    fifoflags_reg_to_struct(flags,&rd_data);
    print_fifo_flags(flags);
    free(flags);

	return 0;
}