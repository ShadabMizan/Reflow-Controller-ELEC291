import serial
print(serial.__file__)

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import sys, time, math

def data_gen():
    t0 = time.time()     # Get start time

    while True:
        # Decode the UART data and strip away \r\n
        line = ser.readline().decode('utf-8').strip()    
        if not line:
            continue
       
        # (t, C)
        val = float(line)
        t = time.time() - t0
        yield t, val

xdata = []
ydata_raw = []
ydata_filt = []

# Low pass filter: y[n] = y[n-1] + alpha * (x[n] - y[n-1])
class LPF:
    def __init__(self, alpha):
        self.alpha = alpha
        self.y = None   # filter value

    def update(self, x):
        if self.y is None:
            self.y = x  # initialize on first sample
        else:
            self.y += self.alpha * (x - self.y)
        return self.y

lpf = LPF(0.1)

def run(data):
    t, y = data
    
    xdata.append(t)
    ydata_raw.append(y)
    ydata_filt.append(lpf.update(y))

    # Scrolling if more than 600s
    if t > 600.0:
        ax.set_xlim(t - 600, t)
    
    line_raw.set_data(xdata, ydata_raw)
    line_filt.set_data(xdata, ydata_filt)

    return line_raw, line_filt

def on_close_figure(event):
    sys.exit(0)

# configure the serial port
ser = serial.Serial(
    port='COM10',
    baudrate=9600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_TWO,
    bytesize=serial.EIGHTBITS
)
ser.isOpen()

fig = plt.figure()
fig.canvas.mpl_connect('close_event', on_close_figure)
ax = fig.add_subplot(111)
line_raw, = ax.plot([], [], lw=1, label="Raw")
line_filt, = ax.plot([], [], lw=2, label="Filtered")

ax.set_ylim(0, 300)
ax.set_ylabel("Temperature (°C)")
ax.set_xlim(0, 600)
ax.set_xlabel("Time (s)")
ax.grid()
ax.legend()

ani = animation.FuncAnimation(
    fig, 
    run, 
    data_gen, 
    blit=False, 
    interval=10, 
    repeat=False
)

plt.show()