/*
Lectura de N muestras con escritura a archivo
José Quinteros del Castillo
Instituto Balseiro

Versión: 2020-03-20
Comentarios: Este programa lee N muestras por la interfaz AXI y las escribe a un archivo.
*/

#include "src/CIAASistAdq.h"

// Programa principal
int main(int argc, char *argv[]) 
{
    uint32_t data;
    char c;
    int n_samples;
    char file_name[60];

	uint32_t * captured_data;
	int i;

	FILE * file;

    // capturo el número de muestras como argumento de la función
	sscanf(argv[1], "%d", &n_samples);
    if(n_samples<=0)
    {
        printf("\nEl número de muestras debe ser mayor o igual a 0.\n");
        return 0;
    }

    //chequeo si el regulador está encendido
    memread(CONTROL_BASE_ADDR+REG_ADDR,&data);
    if(data != 1)
    {
        printf("\nEl regulador está apagado. Continuar? [y/n].\n");
        c =  getchar();
        if(c==89 || c==121) //y Y
        {
            printf("\nContinuando con regulador apagado.\n");
        }
        else
        {
            printf("\nLectura abortada.\n");
            return 0;
        }
    }

    //nombre de archivo
    printf("\nIngrese nombre de archivo: \n");
    scanf("%s",file_name);

    // confirmación y captura
    printf("\nSe capturarán %d muestras al archivo %s. Continuar? [y/n]\n",n_samples,file_name);
    getchar();
	c=getchar();
    if(c==89 || c==121)
        {
            printf("\nCapturando...\n");
			captured_data = (uint32_t * ) malloc(n_samples * sizeof(uint32_t));
			for(i=0;i<n_samples;i++)
			{
				memread(AXI_BASE_ADDR+FIFODATA_ADDR,&(captured_data[i]));
				//printf("\nCapturado dato %d.\n",i);
			}
			printf("\nCaptura finalizada.\n");

			file = fopen(file_name,"w");

			for(i=0;i<n_samples;i++)
			{
				fprintf(file,"%08x\n",captured_data[i]);
			}
			fclose(file);

			printf("\nEscritura de archivo finalizada.\n");

        }
    else
    {
        printf("\nLectura abortada.\n");
        return 0;
    }

	return 0;
}
