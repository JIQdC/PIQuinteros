/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
AD9249 SPI control interface using AXI Quad SPI in CIAA-ACC

Version: 2020-11-11
Comments:
*/

#include "SPI_control.h"

// resets SPI module
void spi_reset()
{
    uint32_t data = 0xA;
    memwrite(SPI_BASE_ADDR+SPI_SRR_OFF, &data, 1);
}

// configures SPI_CR register. params and value are two arrays of specified size
void spi_CR_config(SPI_CR_params_t* params, bool* value, uint8_t size)
{
    uint8_t i;

    uint32_t cr_data = 0;

    for (i = 0; i<size; i++)
    {
        if (value[i])
        {
            cr_data = cr_data | params[i];
        }
    }

    //escribo el registro modificado de nuevo en su lugar
    memwrite(SPI_BASE_ADDR + SPI_CR_OFF, &cr_data, 1);
}

// writes an instruction to the ADC, complying with its instruction formats. address is a 13 bit argument, and data is an array of size n_bytes
int spi_write(uint16_t address, const uint32_t* data, uint8_t n_bytes)
{
    if (n_bytes<=0)
    {
        printf("\nSPI write: el número de bytes a escribir debe ser positivo.\n");
        return 1;
    }

    if (address>0x1fff) //dirección de más de 13 bits
    {
        printf("\nSPI write: La dirección de escritura no puede ser de más de 13 bits.\n");
        return 1;
    }

    //transmito los bytes en grupos de a 3
    int i;
    uint16_t instruction;
    uint32_t instructionMSByte, instructionLSByte;
    uint8_t w1w0;

    for (i = 0; i<n_bytes; i++)
    {
        if ((i%3)==0)
        {
            //al inicio de cada grupo de 3 bytes, transmito la instrucción

            // configuro los bits de cantidad de bytes a transmitir en este grupo
            w1w0 = 0;
            if ((i+3)<n_bytes)
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
            memwrite(SPI_BASE_ADDR+SPI_DTR_OFF, &instructionMSByte, 1);
            memwrite(SPI_BASE_ADDR+SPI_DTR_OFF, &instructionLSByte, 1);
        }
        //transmito el byte i
        memwrite(SPI_BASE_ADDR+SPI_DTR_OFF, &(data[i]), 1);
    }

    return 0;
}

// selects active slave
int spi_ssel(SPI_slaves_t slave)
{
    uint32_t data;

    switch (slave)
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

    return memwrite(SPI_BASE_ADDR+SPI_SSR_OFF, &data, 1);
}

//default configuration for AXI-SPI module
void spi_defaultConfig()
{
    //reset
    spi_reset();

    //configure relevant parameters
    SPI_CR_params_t params[4] = { ManualSSelAssertEn, SPIsystemEn, MasterMode, MasterTransInhibit };
    bool value[4] = { 0, 1, 1, 0 };
    spi_CR_config(params, value, 4);

    usleep(10);

    printf("AXI Quad SPI configured as follows:\n");
    printf("\tManualSSelAssertEn %d\n", value[0]);
    printf("\tSPIsystemEn %d\n", value[1]);
    printf("\tMasterMode %d\n", value[2]);
    printf("\tMasterTransInhibit %d\n", value[3]);
    printf("\n");
}

//default configuration for ADC via SPI
void adc_defaultConfig()
{
    //configure both ADCs equally
    SPI_slaves_t slaves[2] = { adc1, adc2 };

    int i;
    uint32_t wr_data;

    for (i = 0; i<2; i++)
    {
        spi_ssel(slaves[i]);

        //100 ohm termination resistance
        wr_data = 0x20;
        spi_write(ADC_OUTPUTADJUST, &wr_data, 1);

        //clock divider is disabled
        wr_data = 0;
        spi_write(ADC_CLOCKDIVIDE, &wr_data, 1);

        //output from analog inputs
        wr_data = 0;
        spi_write(ADC_TESTMODE, &wr_data, 1);

        //output mode: twos complement
        wr_data = 1;
        spi_write(ADC_OUTPUTMODE, &wr_data, 1);

        //V_Ref is set to 2Vpp
        wr_data = 4;
        spi_write(ADC_VREF, &wr_data, 1);

    }

    usleep(10);

    printf("ADC default configuration:\n");
    printf("\t100 Ohm output driver termination\n");
    printf("\tClock divider 0\n");
    printf("\tTest pattern 0\n");
    printf("\tOutput mode offset binary\n");
    printf("\tVref 2 Vpp\n");
    printf("\n");
}

//sets clock divider to value divide
void adc_clkDividerSet(uint8_t divide)
{

    if (divide < 0 || divide > 7)
    {
        printf("adc_clkDividerSet: divide must be in range 0-7.\n");
        exit(1);
    }
    //configure both ADCs equally
    SPI_slaves_t slaves[2] = { adc1, adc2 };

    int i;
    uint32_t wr_data = divide;

    for (i = 0; i<2; i++)
    {
        spi_ssel(slaves[i]);

        //clock divider
        spi_write(ADC_CLOCKDIVIDE, &wr_data, 1);
    }

    usleep(10);
}

//sets test pattern to specified testPattern
void adc_testPattern(adc_testPattern_t testPattern)
{
    int i;
    uint32_t wr_data = testPattern;

    //configure both ADCs equally
    SPI_slaves_t slaves[2] = { adc1, adc2 };

    for (i = 0; i<2; i++)
    {
        spi_ssel(slaves[i]);

        //output test pattern
        spi_write(ADC_TESTMODE, &wr_data, 1);
    }

    usleep(10);
}

//configures ADC user test pattern to alternate between word1 and word2
void adc_userTestPattern(uint16_t word1, uint16_t word2)
{
    if (word1 > ((1<<14)-1) || word2 > ((1<<14)-1))
    {
        printf("adc_userTestPattern: words out of range.\n");
        exit(1);
    }

    uint32_t wr_data = 0;
    int i;

    //configure both ADCs equally
    SPI_slaves_t slaves[2] = { adc1, adc2 };

    for (i = 0; i<2; i++)
    {
        spi_ssel(slaves[i]);

        //write user words to registers, separating in MSB and LSB
        wr_data = (word1 & MSB_MASK) >> 8;
        spi_write(ADC_W1_MSB, &wr_data, 1);
        wr_data = (word1 & LSB_MASK);
        spi_write(ADC_W1_LSB, &wr_data, 1);
        wr_data = (word2 & MSB_MASK) >> 8;
        spi_write(ADC_W2_MSB, &wr_data, 1);
        wr_data = (word2 & LSB_MASK);
        spi_write(ADC_W2_LSB, &wr_data, 1);

        //output test pattern set to user, with alternate enabled
        wr_data = 8 + (1<<6);
        spi_write(ADC_TESTMODE, &wr_data, 1);
    }

    usleep(10);
}