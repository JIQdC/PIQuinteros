##Simulador de array rectangular utilizando cable coaxil
##José Quinteros
##Teleco IB
##25/08/2019

#Script para obtener las longitudes de cable necesarias para simular el comportamiento
#de un array rectangular de sensores que reciben una onda que se propaga en aire.

import numpy as np 
from matplotlib import pyplot as plt
from RectArray import rectArray

#constantes
c=299792458 #velocidad de la luz
MHz=1E6

#parámetros iniciales
f=150*MHz               #frecuencia de la onda propagante
theta=np.radians(30)    #ángulo theta
phi=0                   #ángulo phi (referido al eje x)
vp=0.66*c               #velocidad de propagación (como fracción de c)
N=16                        #cantidad de sensores en x
M=1                     #cantidad de sensores en y
d=0.5*c/f               #separación entre sensores (como fracción de long de onda en aire)

#array rectangular
array=rectArray()                   #creo un objeto tipo array rectangular
array.createArray(d,N,M)            #cargo sus coordenadas
tau=array.calcTimeDelay(theta,phi)  #calculo los retardos y los almaceno en un vector

""" #opcional: grafico el array para ver que esté bien ubicado
plt.figure(1)
for i in range(0,np.size(array.pos[0,:,0])):
    plt.scatter(array.pos[:,i,0],array.pos[:,i,1])
plt.show(1) """

#parámetros del cable
wavelength=vp/f         #longitud de onda en el cable
li=0                  #longitud inicial (base de todos los tramos de cable)

#ahora sumamos los NxM tramos de cable, cada uno agregando un dl=tau[n,0]*vp
L=0                     #longitud de cable total
for n in range(0,(N*M)):
    L=L+li+tau[n,0]*vp

print("Longitud de onda en el cable: ",wavelength,"m")
for n in range(1,(N*M)):
    print("Retardo ",n,":",(tau[n-1,0]-tau[n,0])*1E9,"ns")
print("Longitud total de cable: ",L,"m")