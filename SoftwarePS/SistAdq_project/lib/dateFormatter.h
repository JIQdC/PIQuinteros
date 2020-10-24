/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Date formatter

Version: 2020-10-24
Comments:
*/

#ifndef DATE_FORMATTER_H_
#define DATE_FORMATTER_H_

#include <time.h>
#include <memory.h>
#include <stdio.h>
#include <stdlib.h>

#define DATE_FORMAT_LENGTH 15

// takes argument t (seconds since Epoch) and returns a string with format YYYYMMDD_HHMMSS for year, month, day, hour, minutes and seconds expressed in user local time
char* dateFormatter(const time_t* t);

#endif //DATE_FORMATTER_H_