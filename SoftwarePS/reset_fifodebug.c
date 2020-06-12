#include "src/CIAASistAdq.h"

int main()
{
    uint32_t data = 3;      //reseteo debug y FIFO
    memwrite(AXI_BASE_ADDR+RESET_ADDR,&data,1);
    printf("\nSe resetearon módulos de debug y FIFO.\n");
}
