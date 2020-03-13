/*
 * CIAASistAdq.c
 *
 *  Created on: Mar 13, 2020
 *      Author: jiqdc
 */


/*
Programa de encendido de placa CIAA-ACC
José Quinteros del Castillo
Instituto Balseiro

Versión: 2020-03-13
Comentarios: Este programa ajusta el valor del potenciómetro que se encuentra en la placa CIAA-ACC a través de bus I2C, y luego enciende el regulador de alimentación de los bancos 12 y 13 de la FPGA.
*/

#include "src/CIAASistAdq.h"

// Programa principal
int main()
{
	//valor de encendido del regulador
	uint32_t data = 1;

	//configuro el potenciómetro en POT_VALUE
	char command[20]="i2cset -y 1 2f ";
	char value_str[20]="0";
	sprintf(value_str,"%d",POT_VALUE);
	strcat(command,value_str);
	system(command);

	//enciendo el regulador
	if(memwrite(CONTROL_BASE_ADDR+REG_ADDR,&data)==0)
	{
		printf("\nPotenciómetro seteado en 0x%d. Regulador encendido correctamente.\n\n",POT_VALUE);
	}
	else
	{
		printf("\nFallo en encendido de regulador.\n\n");
	}

	return 0;
}
