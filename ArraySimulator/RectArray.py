##Funciones para array rectangular
##José Quinteros
##Teleco IB
##08/09/2019

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
        ## esta función calcula el tiempo de viaje desde un plano alejado del origen, que simula un frente de
        ## onda, con normal de dirección en coordenadas esféricas theta, phi (cambiar a azimut y elevación),
        ## hasta cada uno de los sensores del array. Retorna un array 3D en el que se almacenan los valores de 
        ## los retardos de cada uno de los sensores, en la posición de la grilla que les corresponde.

        #array 3D (coordenada x, coordenada y,retardo) para almacenar el resultado
        timeDelays = np.zeros([self.N,self.M,1])

        #pongo el plano a una distancia de 100d del origen (bien lejos, por las dudas)
        r=100*self.d

        #el vector N = (fx, fy, fz) tiene la dirección de la normal del plano, y se corresponde con el vector
        #posición de un punto alejado 100d del origen
        fx=r*np.sin(theta)*np.cos(phi)
        fy=r*np.sin(theta)*np.sin(phi)
        fz=r*np.cos(theta)

        #para expresar el plano como fx x + fy y + fz z + p = 0, necesito p. Como quiero que el plano quede a 
        #100d del origen, pido que el punto (fx, fy, fz) pertenezca al plano. Luego, p = -|N|^2
        norma = np.sqrt(fx**2 + fy**2 + fz**2)
        p = -(norma**2)

        #velocidad de la luz
        c=299792458

        #tomo la distancia de cada uno de los elementos al plano, y los almaceno en el array en la posición
        #que le corresponda en la grilla
        for i in range(0,self.N):
            for j in range(0,self.M):
                dist=np.abs(fx*self.pos[i,j,0]+fy*self.pos[i,j,1]+fz*0+p)/norma        #fórmula de distancia punto plano
                timeDelays[i,j,0]=dist/c                                                 #t=d/c

        #dejo todo el array relativo al menor retardo
        timeDelays[:,:,0]=timeDelays[:,:,0]-np.min(timeDelays[:,:,0])

        #retorno el array de retardos
        return timeDelays