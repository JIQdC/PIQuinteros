##Simulador de array utilizando cable coaxil
##José Quinteros
##Teleco IB
##12/08/2019

#Script para obtener las longitudes de cable necesarias para simular el comportamiento
#de un array de sensores que reciben una onda que se propaga en aire.

import numpy as np 

#constantes
c=299792458 #velocidad de la luz
MHz=1E6

#parámetros iniciales
f=150*MHz               #frecuencia de la onda propagante
theta=np.radians(30)    #ángulo en radianes
vp=0.66*c               #velocidad de propagación (como fracción de c)
N=16                    #cantidad de sensores
d=0.5*c/f               #separación entre sensores (como fracción de long de onda en aire)

#diferencia de tiempo de vuelo en aire
tau=d*np.sin(theta)/c

#parámetros del cable
wavelength=vp/f         #longitud de onda en el cable
li=0.2                  #longitud inicial (base de todos los tramos de cable)
dl=vp*tau               #equivalente en longitud de cable para el tiempo de vuelo en aire

#ahora sumamos los N tramos de cable, cada uno agregando un dl
L=0                     #longitud de cable total
for n in range(0,N-1):
    L=L+li+n*dl

print("Longitud de onda en el cable: ",wavelength,"m")
print("Longitud total de cable: ",L,"m")
print("Longitud de retardo en cable: ",dl,"m")