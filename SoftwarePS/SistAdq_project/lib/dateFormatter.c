/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Date formatter

Version: 2020-10-24
Comments:
*/

#include "dateFormatter.h"

// takes argument t (seconds since Epoch) and returns a string with format YYYYMMDD_HHMMSS for year, month, day, hour, minutes and seconds expressed in user local time
char* dateFormatter(const time_t* t)
{
    char* date = malloc(DATE_FORMAT_LENGTH*sizeof(char));
    memset(date, 0, DATE_FORMAT_LENGTH*sizeof(char));

    struct tm* locTime = localtime(t);

    sprintf(date, "%.4d%.2d%.2d_%.2d%.2d%.2d", locTime->tm_year+1900, locTime->tm_mon+1, locTime->tm_mday, locTime->tm_hour, locTime->tm_min, locTime->tm_sec);

    return date;
}