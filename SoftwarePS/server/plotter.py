'''
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Plotter for captured data

Version: 2020-10-24
Comments:
'''

import numpy as np
import sys
from matplotlib import pyplot as plt
from matplotlib.ticker import StrMethodFormatter

filename = sys.argv[1]
clk_divider = int(sys.argv[2]) + 1
f_sample = 65e6/clk_divider
t_sample = 1/f_sample

ch_names = ["A1", "A2", "B1", "B2", "C1", "C2", "D1",
            "D2", "E1", "E2", "F1", "F2", "G1", "G2", "H1", "H2"]

# load time values
t = np.loadtxt(filename, delimiter=",", skiprows=0, usecols=[0])
t = t*t_sample

# load data values
data = []
for i in range(0, 16):
    data.append(np.loadtxt(filename, delimiter=",", skiprows=0, usecols=[i+1]))
    #data[i] = 2*data[i]/16383 - 1

# plot data values
fig, ax = plt.subplots(4, 4, sharex=True, sharey=True)
i = 0
for j in range(0, 4):
    ax[j, 0].set_ylabel("Dato")
    ax[3, j].set_xlabel("Tiempo (us)")
    for k in range(0, 4):
        ax[j, k].set_title(ch_names[i])
        ax[j, k].scatter(t*1e6, data[i], color='red', marker='.')
        ax[j, k].grid()
        i = i+1
fig.subplots_adjust(wspace=0)
fig.suptitle("Datos capturados")

# calculate difference between consecutive values
dif = []
for i in range(0, 16):
    dif.append(np.zeros(np.size(data[i])))
    for j in range(1, np.size(data[i])):
        dif[i][j-1] = abs(data[i][j] - data[i][j-1])

# plot difference
fig2, ax2 = plt.subplots(4, 4, sharex=True, sharey=True)
i = 0
for j in range(0, 4):
    ax2[j, 0].set_ylabel("Dato")
    ax2[3, j].set_xlabel("Tiempo (us)")
    for k in range(0, 4):
        ax2[j, k].set_title(ch_names[i])
        ax2[j, k].scatter(t*1e6, dif[i], color='red', marker='.')
        ax2[j, k].grid()
        i = i+1
fig2.subplots_adjust(wspace=0)
fig2.suptitle("Diferencia entre datos consecutivos")

plt.show()
