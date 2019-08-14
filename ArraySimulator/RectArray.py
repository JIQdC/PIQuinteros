##Funciones para array rectangular
##José Quinteros
##Teleco IB
##12/08/2019

#Declaración de clase y funciones de aplicación de un array rectangular de NxM elementos.

import numpy as np

class rectArray:
    def __init__(self):
        self.N=int
        self.M=int
        self.pos=np.ndarray
        self.d=float

    def createArray(self,d,N,M):
        ##esta función ubica los elementos del array de forma rectangular,
        ##separados una distancia d, cargando las coordenadas de cada
        ##elemento en self.pos[i,j].

        #almaceno la separación entre sensores
        self.d=d

        #inicializo el array 2D
        self.pos=np.empty([N,M])

        #chequeo paridad para definir posiciones de los sensores de un lado
        #y otro de los ejes
        if (N%2)==0:
            startx=-N/2
            endx=N/2
        else:
            startx=-int(N/2)
            endx=int(N/2)+1
        if (M%2)==0:
            starty=-N/2
            endy=N/2
        else:
            starty=-int(N/2)
            endy=int(N/2)+1

        #ubico sucesivamente cada uno de los elementos en el array
        for i in range(startx,endx):
            for j in range(starty,endy):
                self.pos[i,j]=[i*d,j*d]

    def calcTimeDelay(self):
        ##esta función calcula el tiempo de viaje desde un punto fuente muy lejano
        ##hasta cada uno de los sensores del array. Retorna un array ordenado en el
        ##que se listan todos los retardos del array, tomando el menor (el más cercano
        ##al punto fuente) como referencia.
        