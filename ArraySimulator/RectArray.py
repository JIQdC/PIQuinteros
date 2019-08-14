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
        ## esta función ubica los elementos del array de forma rectangular,
        ## separados una distancia d, cargando las coordenadas de cada
        ## elemento en self.pos[i,j].

        #almaceno la separación entre sensores y las dimensiones del array
        self.d=d
        self.N=N
        self.M=M

        #inicializo el array 2D
        self.pos=np.zeros([N,M,2])

        #seteo las coordenadas correspondientes, centrando en el origen
        for i in range(0,self.N):
            self.pos[i,:,0]=i*self.d - (N-1)*0.5*d
        for j in range(0,self.M):
            self.pos[:,j,1]=j*self.d - (M-1)*0.5*d        

    def calcTimeDelay(self,theta,phi):
        ## esta función calcula el tiempo de viaje desde un punto fuente muy lejano, con
        ## coordenadas esféricas theta, phi (cambiar a azimut y elevación), hasta cada uno de los sensores
        ## del array. Retorna un array en el que se listan todos los retardos de cada uno
        ## de los elementos, junto con sus posiciones, ordenado por los retardos de menor a mayor.

        #array 2D (retardo, coordenada x, coordenada y) para almacenar el resultado
        timeDelays = np.empty([self.N*self.M,3])

        #considerar que puedo descibir también un plano y tomar distancia punto plano

        #tomo una distancia muy grande como posición radial de la fuente. La medida de comparación
        #que tengo es la separación entre sensores, entonces...
        r=100000*self.d

        #escribo las coordenadas de la fuente en cartesianas
        fx=r*np.sin(theta)*np.cos(phi)
        fy=r*np.sin(theta)*np.sin(phi)
        fz=r*np.cos(phi)

        #velocidad de la luz
        c=299792458

        #tomo la distancia de cada uno de los elementos al punto fuente, y los almaceno en el array junto 
        #con sus posiciones en el array pos[:,:]
        k=0     #índice para el array de retardos
        for i in range(0,self.N):
            for j in range(0,self.M):
                dist=np.sqrt((fx-self.pos[i,j,0])**2+(fy-self.pos[i,j,1])**2+fz**2)   #la distancia se calcula en cartesianas
                timeDelays[k,0]=dist/c                                      #t=d/c
                timeDelays[k,1]=i                                           #seteo índice x
                timeDelays[k,2]=j                                           #seteo índice y
                k=k+1                                                       #aumento índice del array de retardos

        #bajo todo el array de tiempos al menor tiempo
        timeDelays[:,0]=timeDelays[:,0]-np.min(timeDelays[:,0])
        #ordeno por los retardos
        timeDelays[timeDelays[:,0].argsort()]

        #retorno el array de retardos
        return timeDelays