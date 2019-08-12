import numpy as np 

#constantes
c=299792458 #velocidad de la luz
MHz=1E6

#parámetros iniciales
f=32*MHz                #frecuencia de la onda propagante
theta=np.radians(30)    #ángulo en radianes
vp=0.72*c               #velocidad de propagación (como fracción de c)
N=8                     #cantidad de sensores
d=0.5*c/f               #separación entre sensores (como fracción de long de onda en aire)

#diferencia de tiempo de vuelo en aire
tau=d*np.sin(theta)/c

#parámetros del cable
wavelength=vp/f         #longitud de onda en el cable
li=10*wavelength        #longitud inicial (base de todos los tramos de cable)
dl=vp*tau               #equivalente en longitud de cable para el tiempo de vuelo en aire

#ahora sumamos los N tramos de cable, cada uno agregando un dl
L=0                     #longitud de cable total
for n in range(1,N):
    L=li+n*dl

print("Longitud total de cable: ",L,"m")