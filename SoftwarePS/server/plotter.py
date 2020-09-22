import numpy as np
import sys
from matplotlib import pyplot as plt

filename = sys.argv[1]
clk_divider = int(sys.argv[2]) + 1
f_sample = 65e6/clk_divider
t_sample = 1/f_sample

t=np.loadtxt(filename,delimiter=",",skiprows=0,usecols=[0])
data=np.loadtxt(filename,delimiter=",",skiprows=0,usecols=[1])

t=t*t_sample

data=2*data/16383 - 1

plt.figure(1)
#plt.plot(t*1e6,data,color='black')
plt.scatter(t*1e6,data,color='red',marker='.')
plt.grid()
plt.xlabel('Tiempo (us)')
##plt.xlim(0,30)
plt.ylabel('Dato (V)')
plt.title('Datos capturados')

dif = np.zeros(np.size(data))

for i in range(1,np.size(data)):
    dif[i-1] = data[i]- data[i-1]

plt.figure(2)
#plt.plot(t*1e6,dif)
plt.scatter(t*1e6,dif)
plt.grid()
plt.xlabel('Tiempo (us)')
plt.ylabel('Diferencia (V)')
plt.title('Diferencia entre muestras consecutivas')

plt.show()