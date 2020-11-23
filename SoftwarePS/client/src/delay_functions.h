/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Control functions for input delays and calibration

Version: 2020-11-22
Comments:
*/

#ifndef SRC_DELAY_FUNCTIONS_H_
#define SRC_DELAY_FUNCTIONS_H_

#include "AXI_control.h"
#include "SPI_control.h"

// ADC PIN POSITIONS

//position of each ADC data pin in FPGA banks. 0 for BANK12, 1 for BANK13
static const bool g_adcPinPositions[16] = { 0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1 };

//delay control module register addresses
#define DELAY_BASE_ADDR     0x43C10000

#define DELAY_LOCKED_OFF    (0x0<<2)

#define FRAME_LD_12_OFF     (0x2<<2)
#define FRAME_LD_13_OFF     (0x3<<2)
#define FRAME_IN_12_OFF     (0x4<<2)
#define FRAME_IN_13_OFF     (0x5<<2)
#define FRAME_OUT_12_OFF    (0x6<<2)
#define FRAME_OUT_13_OFF    (0x7<<2)

#define DATA_LD_OFF         (0x20<<2)
#define DATA_IN_OFF         (0x40<<2)
#define DATA_OUT_OFF        (0x60<<2)

//parameters for calibration
#define TAP_MAX 32
#define CAL_DIFF_CHK (0b10101010101010 - 0b01010101010101)
#define CAL_DIFF_WT (0b11111111111111)
#define BAD_SAMPLES_TRESHOLD 2

////INPUT DELAY CONTROL
// changes the input delay of frame pin i (0 for BANK12, 1 for BANK13) to value taps.
int inputDelaySet_frame(uint8_t i, uint8_t taps);

// changes the input delay of adc_ch to value taps
int inputDelaySet_data(uint8_t adc_ch, uint8_t taps);

// computes bad samples acquired when compared to a calibration pattern
int computeBadSamples(uint8_t adc_ch, uint16_t cal_diff);

// prints bad samples matrix for a specified adc_ch, using a testPattern for ADC
int inputDelayTest(adc_testPattern_t testPattern, uint8_t adc_ch);

//sets input delays to optimal values
int inputDelayCalibrate(adc_testPattern_t testPattern);

#endif //SRC_DELAY_FUNCTIONS_H_