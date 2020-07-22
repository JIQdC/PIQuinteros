/*
Funciones para control de AD9249 por interfaz AXI-SPI en CIAA-ACC
José Quinteros del Castillo
Instituto Balseiro

Versión: 2020-06-10
Comentarios:
*/

#ifndef SPI_CONTROL_H_
#define SPI_CONTROL_H_

#include <memory.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>
#include "CIAASistAdq.h"

// valores para SPI tristate
#define SPI_WRITE 0
#define SPI_READ 1

// direcciones de módulo SPI
#define SPI_BASE_ADDR 0x41e00000
#define SPI_SRR_ADDR 0X40
#define SPI_CR_ADDR 0X60
#define SPI_SR_ADDR 0X64
#define SPI_DTR_ADDR 0X68
#define SPI_DRR_ADDR 0X6C
#define SPI_SSR_ADDR 0X70

// parámetros de control en SPI_CR
typedef enum
{
    LSBfirst = (1 << 9),
    MasterTransInhibit = (1 << 8),
    ManualSSelAssertEn = (1 << 7),
    RxFIFOreset = (1 << 6),
    TxFIFOreset = (1 << 5),
    CPHA = (1 << 4),
    CPOL = (1 << 3),
    MasterMode = (1 << 2),
    SPIsystemEn = (1 << 1),
    Loop = (1 << 0)
}SPI_CR_params_t;

// parámetros de control en SPI_SR
typedef struct
{
    bool commandErr;
    bool loopbackErr;
    bool MSBerr;
    bool slaveModeErr;
    bool CPOL_CPHAErr;
    bool slaveModeSel;
    bool MODF;
    bool txFull;
    bool txEmpty;
    bool rxFull;
    bool rxEmpty;
}SPI_SR_t;

// esclavos para seleccionar
typedef enum
{
    adc1,
    adc2,
    none
}SPI_slaves_t;

//función para resetear el módulo SPI
void spi_reset();

//función de configuración de registro SPI_CR
void spi_CR_config(SPI_CR_params_t params, bool value);

//función de lectura de flags de estado de SPI_SR
void spi_SR_get(SPI_SR_t * flags);

//función de escritura por SPI al ADC, teniendo en cuenta su formato de instrucción propio. Recibe como argumento una dirección de 13 bits, y un puntero al primer elemento de un array de n_bytes elementos de 8 bits.
int spi_write(uint16_t address, const uint32_t * data, uint8_t n_bytes);

//función de lectura por SPI al ADC, teniendo en cuenta su formato de instrucción, y la bidireccionalidad de la lectura. Recibe como argumento una dirección de 13 bits, y un puntero al lugar de memoria donde escribirá n_bytes leídos.
int spi_read(uint16_t address, uint32_t * data, uint8_t n_bytes);

//función de selección de esclavo SPI
int spi_ssel(SPI_slaves_t slave);

#endif //SPI_CONTROL_H_