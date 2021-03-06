##Simulador de array rectangular utilizando cable coaxil
##Jose Quinteros
##Teleco IB
##03/11/2020

#Script para obtener las longitudes de cable necesarias para simular el comportamiento
#de un array rectangular de sensores que reciben una onda que se propaga en aire.

import numpy as np 
from matplotlib import pyplot as plt
from RectArray import rectArray
from mpl_toolkits.mplot3d import Axes3D 

#constantes
c=299792458 #velocidad de la luz
MHz=1E6

#parametros iniciales
f=146*MHz               #frecuencia de la onda propagante
theta=np.radians(30)    #ángulo theta
phi=np.radians(15)      #ángulo phi (referido al eje x)
vp=0.663*c              #velocidad de propagación (como fracción de c)
N=4                     #cantidad de sensores en x
M=4                     #cantidad de sensores en y
d=0.5*c/f               #separación entre sensores (como fracción de long de onda en aire)
#parámetros del cable
wavelength=vp/f         #longitud de onda en el cable
li=0.15                 #longitud inicial (base de todos los tramos de cable)

#array rectangular
array=rectArray()                   #creo un objeto tipo array rectangular
array.createArray(d,N,M)            #cargo sus coordenadas
tau=array.calcTimeDelay(theta,phi)  #calculo los retardos y los almaceno en un vector

""" #opcional: grafico el array para ver que esté bien ubicado
plt.figure(1)
for i in range(0,np.size(array.pos[0,:,0])):
    plt.scatter(array.pos[:,i,0],array.pos[:,i,1])
plt.show(1) """

#ahora sumamos los NxM tramos de cable, cada uno agregando un dl=tau[i,j,0]*vp
L=0                     #longitud de cable total
length = np.zeros(M*N)
delay = np.zeros(M*N)

k=0
for i in range(0,N):
    for j in range(0,M):
        delay[k] = tau[i,j,0]
        length[k] = li+delay[k]*vp
        L=L+length[k]
        print("Cable (",i,",",j,") (",k,"): ",length[k],"m")
        k=k+1

print("Longitud de onda en el cable: ",wavelength,"m")
print("Longitud total de cable: ",L,"m")

#pick a cable as reference. Express all other cable lengths relative to this one.
#print relative time delays
i_ref = 1
j_ref = 1
length_ref=length-length[N*i_ref + j_ref]
delay_ref=delay-delay[N*i_ref + j_ref]
print("\n")
print("Longitudes referidas a cable (%d,%d)" % (i_ref,j_ref))
print("Num\tLong. rel (cm)\tRet. rel. (ns)")
for k in range(0,N*M):
    print("%d\t%.2f \t\t\t%.4f" % (k,length_ref[k]*1e2,delay_ref[k]*1e9))   

# ##gráfico de retardos
# f=plt.figure(2)
# ax1 = f.add_subplot(121,projection='3d')
# #grilla base
# _x = np.arange(np.shape(tau)[0])
# _y = np.arange(np.shape(tau)[1])
# _xx, _yy = np.meshgrid(_x, _y)
# x, y = _xx.ravel(), _yy.ravel()

# #base y tope de las barras
# top=1e9*tau[:,:,0].flatten()
# bottom=np.zeros_like(top)
# #ancho y profundidad de las barras
# width=depth=0.3

# ax1.bar3d(x,y,bottom,width,depth,top,shade=True,color='red')
# ax1.set_xlabel("Eje x")
# ax1.set_ylabel("Eje y")
# ax1.set_zlabel("Retardo [ns]")

# plt.show(2)
