/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Preprocessing stages control functions

Version: 2020-10-24
Comments:
*/

#ifndef PREPROC_FUNCTIONS_H_
#define PREPROC_FUNCTIONS_H_

#include "AXI_control.h"

//downsampling control module register addresses
#define DOWNSMPL_BASE_ADDR  0x43c20000
#define TRESH_LD_OFF        (0x00<<2)
#define TRESH_VAL_OFF       (0x01<<2)

//downsampling treshold register size
#define DOWNSMPL_TRESH_REG_SIZE 10

//set downsampling threshold to value val
int downsampling_set(const uint16_t val);

#endif //PREPROC_FUNCTIONS_H_