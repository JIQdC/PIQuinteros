/*
Funciones para control de AD9249 por interfaz AXI-SPI en CIAA-ACC
José Quinteros del Castillo
Instituto Balseiro

Versión: 2020-06-10
Comentarios:
*/

#include "SPI_control.h"

//función para resetear el módulo SPI
void spi_reset()
{
	uint32_t data = 0xa;
	memwrite(SPI_BASE_ADDR+SPI_SRR_ADDR,&data,1);
}

//función de configuración de registro SPI_CR
void spi_CR_config(SPI_CR_params_t params, bool value)
{
	//leo el valor actual del registro de configuración
	uint32_t cr_data = 0;
	memread(SPI_BASE_ADDR + SPI_CR_ADDR,&cr_data,1);

	//seteo el valor del bit a configurar en 0
	cr_data = cr_data & (~params);

	//si tengo que escribir un 1, lo escribo
	if(value)
	{
		cr_data = cr_data | params;
	}

	//escribo el registro modificado de nuevo en su lugar
	memwrite(SPI_BASE_ADDR + SPI_CR_ADDR,&cr_data,1);
}

//función de lectura de flags de estado de SPI_SR
void spi_SR_get(SPI_SR_t * flags)
{
	// leo el reg
	uint32_t sr_reg;
	memread(SPI_BASE_ADDR+SPI_SR_ADDR,&sr_reg,1);

	//guardo los datos leídos en la estructura de flags
	flags->commandErr =  sr_reg & (1 << 10);
	flags->loopbackErr = sr_reg & (1 << 9);
	flags->MSBerr = sr_reg & (1 << 8);
	flags->slaveModeErr = sr_reg & (1 << 7);
	flags->CPOL_CPHAErr = sr_reg & (1 << 6);
	flags->slaveModeSel = sr_reg & (1 << 5);
	flags->MODF = sr_reg & (1 << 4);
	flags->txFull = sr_reg & (1 << 3);
	flags->txEmpty = sr_reg & (1 << 2);
	flags->rxFull = sr_reg & (1 << 1);
	flags->rxEmpty = sr_reg & (1 << 0);
}

//función de escritura por SPI al ADC, teniendo en cuenta su formato de instrucción propio. Recibe como argumento una dirección de 13 bits, y un puntero al primer elemento de un array de n_bytes elementos de 8 bits.
int spi_write(uint16_t address, const uint32_t * data, uint8_t n_bytes)
{
	if(n_bytes<=0)
	{
		printf("\nSPI write: el número de bytes a escribir debe ser positivo.\n");
		return 1;
	}

	if(address>0x1fff) //dirección de más de 13 bits
		{
		printf("\nSPI write: La dirección de escritura no puede ser de más de 13 bits.\n");
		return 1;
	}

	//posiciono el tristate que controla la salida, en modo escritura
	uint32_t data_tr = SPI_WRITE;
	memwrite(CONTROL_BASE_ADDR+SPI_TRISTATE_ADDR,&data_tr,1);

	//transmito los bytes en grupos de a 3
	int i;
	uint16_t instruction;
	uint32_t instructionMSByte,instructionLSByte;
	uint8_t w1w0;

	for(i=0;i<n_bytes;i++)
	{
		if((i%3)==0)
		{
			//al inicio de cada grupo de 3 bytes, transmito la instrucción
			
			// configuro los bits de cantidad de bytes a transmitir en este grupo
			w1w0 = 0;
			if((i+3)<n_bytes)
			{
				w1w0 = 2;
			}
			else
			{
				w1w0 = (n_bytes - i) - 1;
			}
			
			//armo la instrucción de 16 bits
			instruction = 0;
			instruction += 0*(1 << 15);	//bit 16 en 0 porque es escritura
			instruction += w1w0 * (1 << 13);	//bits 15 y 14 para cantidad de bytes a escribir
			instruction += address;		//dirección va en los bits restantes

			//separo la instrucción en MSByte y LSByte y transmito
			instructionMSByte = (instruction & 0xff00) >> 8;
			instructionLSByte = (instruction & 0x00ff);
			memwrite(SPI_BASE_ADDR+SPI_DTR_ADDR,&instructionMSByte,1);
			memwrite(SPI_BASE_ADDR+SPI_DTR_ADDR,&instructionLSByte,1);
		}
		//transmito el byte i
		memwrite(SPI_BASE_ADDR+SPI_DTR_ADDR,&(data[i]),1);
	}

	return 0;
}

//función de lectura por SPI al ADC, teniendo en cuenta su formato de instrucción, y la bidireccionalidad de la lectura. Recibe como argumento una dirección de 13 bits, y un puntero al lugar de memoria donde escribirá n_bytes leídos.
int spi_read(uint16_t address, uint32_t * data, uint8_t n_bytes)
{
	if(n_bytes<=0)
	{
		printf("\nSPI read: el número de bytes a leer debe ser positivo.\n");
		return 1;
	}

	if(address>0x1fff) //dirección de más de 13 bits
		{
		printf("\nSPI read: La dirección de lectura no puede ser de más de 13 bits.\n");
		return 1;
	}

	//transmito los bytes en grupos de a 3
	int i,j=0;
	uint32_t data_tr,data_rx=0;
	uint16_t instruction;
	uint32_t instructionMSByte,instructionLSByte;
	uint8_t w1w0;

	for(i=0;i<n_bytes;i++)
	{
		if((i%3)==0)
		{
			//al inicio de cada grupo de 3 bytes, transmito la instrucción

			//posiciono el tristate que controla la salida, en modo escritura
			data_tr = SPI_WRITE;
			memwrite(CONTROL_BASE_ADDR+SPI_TRISTATE_ADDR,&data_tr,1);
			printf("\nTristate en modo escritura (%d)\n",data_tr);
						
			// configuro los bits de cantidad de bytes a leer en este grupo
			w1w0 = 0;
			if((i+3)<n_bytes)
			{
				w1w0 = 2;
			}
			else
			{
				w1w0 = (n_bytes - i) - 1;
			}
			
			//armo la instrucción de 16 bits
			instruction = 0;
			instruction += 1*(1 << 15);	        //bit 16 en 1 porque es lectura
			instruction += w1w0 * (1 << 13);	//bits 15 y 14 para cantidad de bytes a leer
			instruction += address;		        //dirección va en los bits restantes

			//separo la instrucción en MSByte y LSByte y transmito
			instructionMSByte = (instruction & 0xff00) >> 8;
			instructionLSByte = (instruction & 0x00ff);
			printf("\nInstruction MSByte: %02x\n",instructionMSByte);
			printf("\nInstruction LSByte: %02x\n",instructionLSByte);
			assert(~memwrite(SPI_BASE_ADDR+SPI_DTR_ADDR,&instructionMSByte,1));
			printf("\nSe escribió Instruction MSByte\n");
			assert(~memwrite(SPI_BASE_ADDR+SPI_DTR_ADDR,&instructionLSByte,1));
			printf("\nSe escribió Instruction LSByte\n");
		}

		//acciono la transición a modo lectura
		data_tr = SPI_READ;
		assert(~memwrite(CONTROL_BASE_ADDR+SPI_TRISTATE_ADDR,&data_tr,1));
		printf("\nEnviada transición a modo lectura (%d)\n",data_tr);
		//espero a que el tristate se posicione en modo lectura
		while(1)
		{
			assert(~memread(CONTROL_BASE_ADDR+SPI_TRISTATE_ADDR,&data_rx,1));
			j++;
			printf("\nCiclo %d leí %d\n",j,data_rx);
			if(data_rx == SPI_READ)
			{
				printf("\nEsperé por %d ciclos\n",j);
				break;
			}
		}
		//ver de cambiar por do(memread) while 
		
		printf("\nTerminada transición a modo lectura (%d)\n",data_tr);

		//escribo dummy data
		data_tr = 0xd;
		assert(~memwrite(SPI_BASE_ADDR+SPI_DTR_ADDR,&instructionMSByte,1));

		//leo el byte i
		memread(SPI_BASE_ADDR+SPI_DRR_ADDR,&(data[i]),1);
		printf("\nLectura byte %d\n",i);
	}

	return 0;
}

//función de selección de esclavo SPI
int spi_ssel(SPI_slaves_t slave)
{
	uint32_t data;

	switch(slave)
	{
		case adc1:
			data = 1;
			break;

		case adc2:
			data = 2;
			break;
		
		case none:
			data = 3;
			break;
	}

	return memwrite(SPI_BASE_ADDR+SPI_SSR_ADDR,&data,1);	
}