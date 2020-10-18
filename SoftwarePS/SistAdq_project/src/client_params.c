/*
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Parameter parsing for data acquisition interface

Version: 2020-09-16
Comments:
*/

#include "AXI_control.h"
#include "client_params.h"

static void cl_parseParam(const char* key, char* value, ClParams_t* clPars)
{
    if (!strcmp(key, "BD_ID"))
    {
        sscanf(value, "%hhd", &clPars->bd_id);
        if ((clPars->bd_id < 0) || (clPars->bd_id > UINT8_MAX))
        {
            printf("ClParseParam: BD_ID out of range.\n");
            exit(1);
        }
        return;
    }

    if (!strcmp(key, "CH_ID"))
    {
        sscanf(value, "%hhd", &clPars->ch_id);
        if ((clPars->ch_id < 0) || (clPars->ch_id > UINT8_MAX))
        {
            printf("ClParseParam: CH_ID out of range.\n");
            exit(1);
        }
        return;
    }

    if (!strcmp(key, "TX_MODE"))
    {
        if (strstr(value, "file")!=NULL)
        {
            clPars->txMode = file;
            return;
        }
        else if (strstr(value, "TCP")!=NULL)
        {
            clPars->txMode = TCP;
            return;
        }
        else if (strstr(value, "UDP")!=NULL)
        {
            clPars->txMode = UDP;
            return;
        }
        else
        {
            printf("ClParseParam: TX_MODE must be file, TCP or UDP.\n");
            exit(1);
        }
    }

    if (!strcmp(key, "SERVER_ADDR"))
    {
        //since strlen gives the length excluding the final 0 byte, serv_addr has one char less than value
        clPars->serv_addr = malloc(strlen(value)*sizeof(char));
        memset(clPars->serv_addr, 0, strlen(value)*sizeof(char));
        //this copies all chars of value but the last one, while maintaining the final 0 byte
        memcpy(clPars->serv_addr, value, strlen(value)*sizeof(char)-1);
        return;
    }

    if (!strcmp(key, "SERVER_PORTNO"))
    {
        sscanf(value, "%d", &clPars->server_portno);
        if ((clPars->server_portno < 0) || (clPars->server_portno > INTMAX_MAX))
        {
            printf("ClParseParam: SERV_PORTNO out of range.\n");
            exit(1);
        }
        return;
    }

    if (!strcmp(key, "CAP_MODE"))
    {
        if (strstr(value, "timeInterval")!=NULL)
        {
            clPars->capMode = timeInterval;
            return;
        }
        else if (strstr(value, "sampleNumber")!=NULL)
        {
            clPars->capMode = sampleNumber;
            return;
        }
        else
        {
            printf("ClParseParam: CAP_MODE must be timeInterval or sampleNumber.\n");
            exit(1);
        }
        return;
    }

    if (!strcmp(key, "SAMPLE_NUM"))
    {
        sscanf(value, "%d", &clPars->n_samples);
        return;
    }

    if (!strcmp(key, "STOP_SEC"))
    {
        sscanf(value, "%ld", &clPars->timerfd_stop_spec.it_value.tv_sec);
        return;
    }

    if (!strcmp(key, "STOP_NSEC"))
    {
        sscanf(value, "%ld", &clPars->timerfd_stop_spec.it_value.tv_nsec);
        return;
    }

    if (!strcmp(key, "TRIG_MODE"))
    {
        if (strstr(value, "timer")!=NULL)
        {
            clPars->trigMode = timer;
            return;
        }
        else if (strstr(value, "manual")!=NULL)
        {
            clPars->trigMode = manual;
            return;
        }
        else if (strstr(value, "noDelay")!=NULL)
        {
            clPars->trigMode = noDelay;
            return;
        }
        else
        {
            printf("ClParseParam: TRIG_MODE must be timer, manual or noDelay.\n");
            exit(1);
        }
    }

    if (!strcmp(key, "START_YEAR"))
    {
        sscanf(value, "%d", &clPars->timerfd_start_br.tm_year);
        return;
    }
    if (!strcmp(key, "START_MONTH"))
    {
        sscanf(value, "%d", &clPars->timerfd_start_br.tm_mon);
        return;
    }
    if (!strcmp(key, "START_DAY"))
    {
        sscanf(value, "%d", &clPars->timerfd_start_br.tm_mday);
        return;
    }
    if (!strcmp(key, "START_HOUR"))
    {
        sscanf(value, "%d", &clPars->timerfd_start_br.tm_hour);
        return;
    }
    if (!strcmp(key, "START_MIN"))
    {
        sscanf(value, "%d", &clPars->timerfd_start_br.tm_min);
        return;
    }
    if (!strcmp(key, "START_SEC"))
    {
        sscanf(value, "%d", &clPars->timerfd_start_br.tm_sec);
        return;
    }

    if (!strcmp(key, "CLK_DIVIDER"))
    {
        sscanf(value, "%hd", &clPars->clk_divider);
        if ((clPars->clk_divider < 0) || (clPars->clk_divider > 7))
        {
            printf("ClParseParam: CLK_DIVIDER out of range.\n");
            exit(1);
        }
        return;
    }

    if (!strcmp(key, "DEBUG_OUTPUT"))
    {
        sscanf(value, "%08hX", &clPars->debug_output);
        if ((clPars->debug_output < 0x0) || (clPars->debug_output > 0xF))
        {
            printf("ClParseParam: DEBUG_OUTPUT out of range.\n");
            exit(1);
        }
        return;
    }

    //if key not valid, print it
    printf("ClParseParam: invalid key %s detected.\n", key);
    return;
}

static void paramError(const char* msg)
{
    printf("ClParseParam: %s is not set.\n", msg);
    exit(1);
}

// parse a file to get parameters for client. checks if all necessary parameters are set
void ClientParseFile(const char* fname, ClParams_t* clPars)
{
    char* line = NULL;
    size_t linecap = 0;
    ssize_t linelen;
    char* key, * value;
    struct tm time_current;

    //clear params
    memset(clPars, 0, sizeof(ClParams_t));

    //set default params for clPars
    clPars->bd_id = 0;
    clPars->ch_id = 0;
    clPars->serv_addr = NULL;       //check if set
    clPars->server_portno = -1;     //check if set
    clPars->txMode = -1;            //check if set
    clPars->capMode = -1;           //check if set
    clPars->trigMode = manual;
    clPars->n_samples = -1;         //check if set
    clPars->clk_divider = -1;        //check if set
    clPars->debug_output = -1;      //check if set     
    //default start date = today
    struct timespec tspec;
    clock_gettime(CLOCK_REALTIME, &tspec);
    localtime_r(&tspec.tv_sec, &time_current);
    clPars->timerfd_start_br = time_current;
    //check start time if trigMode = timer
    clPars->timerfd_start_br.tm_hour = -1;
    clPars->timerfd_start_br.tm_min = -1;
    clPars->timerfd_start_br.tm_sec = -1;
    //check stop time if capMode = timeInterval
    clPars->timerfd_stop_spec.it_value.tv_sec = -1;
    clPars->timerfd_stop_spec.it_value.tv_nsec = -1;

    FILE* in = fopen(fname, "r");
    if (in < 0) error("fopen in ClParseFile");

    while ((linelen = getline(&line, &linecap, in)) > 0)
    {
        if (line[0] == '#' || line[0] == '\n')
            continue;
        key = strtok(line, "=");
        value = strtok(NULL, "=");
        cl_parseParam(key, value, clPars);
    }

    fclose(in);

    //check that required values are set
    if (clPars->txMode == -1) paramError("TX_MODE");
    if (clPars->serv_addr == NULL) paramError("SERV_ADDR");
    if (clPars->server_portno == -1) paramError("SERV_PORTNO");
    if (clPars->capMode == -1) paramError("CAP_MODE");
    if (clPars->debug_output == -1) paramError("DEBUG_OUTPUT");
    if (clPars->clk_divider == -1) paramError("CLK_DIVIDER");
    if (clPars->capMode == sampleNumber && clPars->n_samples == -1) paramError("SAMPLE_NUM");
    if (clPars->trigMode == timer)
    {
        if (mktime(&clPars->timerfd_start_br) < tspec.tv_sec)
        {
            printf("ClParseParam: start time is before now. Program will initiate at once. Continue? (y/n): ");
            if (getchar()=='n')
            {
                exit(1);
            }
        }
        if (clPars->timerfd_start_br.tm_hour == -1) paramError("START_HOUR");
        if (clPars->timerfd_start_br.tm_min == -1) paramError("START_MIN");
        if (clPars->timerfd_start_br.tm_sec == -1) paramError("START_SEC");
    }
    if (clPars->capMode == timeInterval)
    {
        if (clPars->timerfd_stop_spec.it_value.tv_sec == -1) paramError("STOP_SEC");
        if (clPars->timerfd_stop_spec.it_value.tv_nsec == -1) paramError("STOP_NSEC");
    }

}
