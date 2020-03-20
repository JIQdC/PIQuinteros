/*
Programa de apagado de regulador de placa CIAA-ACC
José Quinteros del Castillo
Instituto Balseiro

Versión: 2020-03-13
Comentarios: Este programa apaga el regulador de alimentación de los bancos 12 y 13 de la FPGA.
*/

#include "src/CIAASistAdq.h"

// Programa principal
int main()
{
	//valor de encendido del regulador
	uint32_t data = 0;

	//apago el regulador
	if(memwrite(CONTROL_BASE_ADDR+REG_ADDR,&data)==0)
	{
		printf("\nRegulador apagado correctamente.\n\n");
	}
	else
	{
		printf("\nFallo en apagado de regulador.\n\n");
	}

	return 0;
}
