'''
Emulation, acquisition and data processing system for sensor matrices
José Quinteros del Castillo
Instituto Balseiro
---
Plotter for captured data

Version: 2020-11-11
Comments:
'''

import numpy as np
import sys
from matplotlib import pyplot as plt
from matplotlib.ticker import StrMethodFormatter

filename = sys.argv[1]
clk_divider = int(sys.argv[2]) + 1
downsampler_rate = 1
f_sample = 65e6/(clk_divider*downsampler_rate)
t_sample = 1/f_sample
v_fullscale = 2  # Vpp
channel_number = 16
x_samples = 1
chop_init_samples = 2

ch_names = ["A1", "A2", "B1", "B2", "C1", "C2", "D1",
            "D2", "E1", "E2", "F1", "F2", "G1", "G2", "H1", "H2"]

# load time values
t = np.loadtxt(filename, delimiter=",", skiprows=0, usecols=[0])
t = t*t_sample
t = t[chop_init_samples:]

# load data values
data = []
for i in range(0, channel_number):
    data.append(np.loadtxt(filename, delimiter=",", skiprows=0, usecols=[i+1]))
    data[i] = v_fullscale*data[i]/16383 - v_fullscale/2
    data[i] = data[i][chop_init_samples:]

# calculate difference between consecutive values
dif = []
for i in range(0, channel_number):
    dif.append(np.zeros(np.size(data[i])))
    for j in range(1, np.size(data[i])):
        dif[i][j-1] = abs(data[i][j] - data[i][j-1])

# compute FFT
freq = np.linspace(-f_sample/2, f_sample/2, num=np.size(t))
Data = []
Phase = []
for i in range(0, channel_number):
    Data.append(np.fft.fftshift(np.fft.fft(data[i]))/np.size(data[i]))
    Phase.append(np.rad2deg(np.unwrap(np.angle(Data[i]))))
    Data[i] = 20*np.log10(np.abs(Data[i]))-10*np.log10(50*1e-3)
    #Data.append(np.abs(np.fft.fftshift(np.fft.fft(data[i]))))
    #Data[i]=Data[i]/np.size(Data[i])

# # SINGLE CHANNEL PLOT
# # plot data values
# fig = plt.figure(1)
# plt.ylabel("Dato")
# if(x_samples):
#     plt.xlabel("Número de muestra")
#     plt.scatter(t/t_sample, data[0], color='red', marker='.')
# else:
#     plt.xlabel("Tiempo (us)")
#     plt.scatter(t*1e6, data[0], color='red', marker='.')
# plt.grid()
# fig.suptitle("Datos capturados")

# # plot difference
# fig2 = plt.figure(2)
# plt.ylabel("Dato")
# if(x_samples):
#     plt.xlabel("Número de muestra")
#     plt.scatter(t/t_sample, dif[0], color='red', marker='.')
# else:
#     plt.xlabel("Tiempo (us)")
#     plt.scatter(t*1e6, dif[0], color='red', marker='.')
# plt.grid()
# fig2.suptitle("Diferencia entre datos consecutivos")

# # plot FFT values
# fig3 = plt.figure(3)
# plt.ylabel("Dato (dB)")
# plt.xlabel("Frecuencia (MHz)")
# plt.plot(freq*1e-6, Data[0], color='red')
# plt.grid()
# fig3.suptitle("FFT de datos capturados")

# plt.show()

# MULTIPLE CHANNEL PLOT
# plot data values
if(x_samples):
    xlabel = "Número de muestra"
else:
    xlabel = "Tiempo (us)"

fig, ax = plt.subplots(4, 4, sharex=True, sharey=True)
i = 0
for j in range(0, 4):
    ax[j, 0].set_ylabel("Dato")
    ax[3, j].set_xlabel(xlabel)
    for k in range(0, 4):
        ax[j, k].set_title(ch_names[i])
        if(x_samples):
            ax[j, k].scatter(t/t_sample, data[i], color='red', marker='.')
        else:
            ax[j, k].scatter(t*1e6, data[i], color='red', marker='.')
        ax[j, k].grid()
        i = i+1
fig.subplots_adjust(wspace=0)
fig.suptitle("Datos capturados")

# plot difference
fig2, ax2 = plt.subplots(4, 4, sharex=True, sharey=True)
i = 0
for j in range(0, 4):
    ax2[j, 0].set_ylabel("Dato")
    ax2[3, j].set_xlabel(xlabel)
    for k in range(0, 4):
        ax2[j, k].set_title(ch_names[i])
        if(x_samples):
            ax2[j, k].scatter(t/t_sample, dif[i], color='red', marker='.')
        else:
            ax2[j, k].scatter(t*1e6, dif[i], color='red', marker='.')
        ax2[j, k].grid()
        i = i+1
fig2.subplots_adjust(wspace=0)
fig2.suptitle("Diferencia entre datos consecutivos")

# plot FFT values
fig3, ax3 = plt.subplots(4, 4, sharex=True, sharey=True)
i = 0
for j in range(0, 4):
    ax3[j, 0].set_ylabel("Dato (dB)")
    ax3[3, j].set_xlabel("Frecuencia (MHz)")
    for k in range(0, 4):
        ax3[j, k].set_title(ch_names[i])
        ax3[j, k].plot(freq*1e-6, Data[i], color='red')
        ax3[j, k].grid()
        i = i+1
fig3.subplots_adjust(wspace=0)
fig3.suptitle("FFT de datos capturados")

# plot FFT phase
fig4, ax4 = plt.subplots(4, 4, sharex=True, sharey=True)
i = 0
for j in range(0, 4):
    ax4[j, 0].set_ylabel("Fase (deg)")
    ax4[3, j].set_xlabel("Frecuencia (MHz)")
    for k in range(0, 4):
        ax4[j, k].set_title(ch_names[i])
        ax4[j, k].plot(freq*1e-6, Phase[i], color='red')
        ax4[j, k].grid()
        i = i+1
fig4.subplots_adjust(wspace=0)
fig4.suptitle("FFT de datos capturados")

plt.show()
