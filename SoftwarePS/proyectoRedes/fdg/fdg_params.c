#include "fdg_params.h"

static void fdg_parseParam(const char * key, char *value, FdgParams_t *fdgPars)
{
    if(!strcmp(key,"FDG_MODE"))
    {
        if(strstr(value,"sine")!=NULL)
        {
            fdgPars->mode = sine;
            return;
        }
        if(strstr(value,"randConst")!=NULL)
        {
            fdgPars->mode = randConst;
            return;
        }
        if(strstr(value,"countOffset")!=NULL)
        {
            fdgPars->mode = countOffset;
            return;
        }
        if(strstr(value,"noise")!=NULL)
        {
            fdgPars->mode = noise;
            return;
        }
        else
        {
            printf("FDGparseParam: FDG_MODE must be sine, randConst, countOffset or noise.\n");
            exit(1);
        }
    }
    if(!strcmp(key,"FDG_MODE_PAR"))
    {
        sscanf(value,"%hd",&fdgPars->mode_param);
        return;
    }
    if(!strcmp(key,"FDG_UPT_SEC"))
    {
        sscanf(value,"%ld",&fdgPars->update_period.tv_sec);
        return;
    }
    if(!strcmp(key,"FDG_UPT_NSEC"))
    {
        sscanf(value,"%ld",&fdgPars->update_period.tv_nsec);
        return;
    }

    //if key not found, report
    printf("FDGparseParam: invalid key %s detected.\n",key);
    return;
}

static void paramError(const char * msg)
{
    printf("FDGparseParam: %s is not set.\n",msg);
    exit(1);
}


// parse a file to get parameters for FDG. checks if all necessary parameters are set
void FdgParseFile(const char *fname, FdgParams_t *fdgPars)
{
    char *line = NULL;
    size_t linecap = 0;
    ssize_t linelen;
    char * key,* value;

    //clear params
    memset(fdgPars,0,sizeof(FdgParams_t));

    //all fdgPars need to be checked
    fdgPars->update_period.tv_sec = -1;
    fdgPars->update_period.tv_nsec = -1;
    fdgPars->mode = -1;
    fdgPars->mode_param = 0xABCD;

    FILE *in = fopen(fname, "r");
    if(in < 0) error("fopen in FDGparseFile");
    
    while ((linelen = getline(&line, &linecap, in)) > 0)
    {
        if(line[0] == '#' || line[0] == '\n')
             continue;
        key = strtok(line, "=");
        value = strtok(NULL, "=");
        fdg_parseParam(key, value, fdgPars);
    }

    fclose(in);

    //check that required values are set
    if(fdgPars->update_period.tv_sec == -1) paramError("FDG_UPT_SEC");
    if(fdgPars->update_period.tv_nsec == -1) paramError("FDG_UPT_NSEC");
    if(fdgPars->mode == -1) paramError("FDG_MODE");
    if(fdgPars->mode == sine || fdgPars->mode == countOffset)
    {
        if(fdgPars->mode_param == 0xABCD) paramError("FDG_MODE_PARAM");
    }
}