#https://www.raspberrypi.com/documentation/microcontrollers/micropython.html#where-can-i-find-documentation
#https://docs.micropython.org/en/latest/rp2/quickref.html#general-board-control

#https://docs.micropython.org/en/latest/library/rp2.html
#import rp2
#rp2.asm_pio(*, out_init=None, set_init=None, sideset_init=None, side_pindir=False, in_shiftdir=PIO.SHIFT_LEFT, out_shiftdir=PIO.SHIFT_LEFT, autopush=False, autopull=False, push_thresh=32, pull_thresh=32, fifo_join=PIO.JOIN_NONE)

import sys
import machine
print("\n\n")
print("hallo")
sysinfo = sys.implementation
print(f"HW: {sysinfo._machine} {sysinfo._mpy}")
print(f"SW: {sysinfo.name} {sysinfo.version}")
print(f"CPU frequ: {machine.freq()}")


from machine import Pin
from neopixel import NeoPixel
import time

colors = {
  "green": [0, 150, 0],
  "red": [150, 0, 0],
  "blue":[0, 0, 150],
  "yellow": [150, 150, 0],
  "white": [255, 255, 255]
}

NeoRGB_PIN = 22    #RP2040 USB onBoard LED connected to GPIO pin 22
NeoRGB_PIXELS = 1

pin = Pin(NeoRGB_PIN)     # set GPIOX to output to drive NeoPixels
np = NeoPixel(pin, NeoRGB_PIXELS)  # create NeoPixel driver on GPIO0 for Y pixels
print()
for name in colors.keys():
  time.sleep(1)
  print(f"{name} = {colors[name]}")
  np[0] = (colors[name][0], colors[name][1], colors[name][2])
  np.write()              # write data to all pixels

'''
pin = Pin(NeoRGB_PIN, Pin.OUT)     # set GPIOX to output to drive NeoPixels
time.sleep(1)
pin.value(1)
time.sleep(1)
np = NeoPixel(pin, NeoRGB_PIXELS, NEO_GRB + NEO_KHZ800)  # create NeoPixel driver on GPIO0 for Y pixels
time.sleep(2)
color = colors["red"]
print(color)
np[0] = (color[0], color[1], color[2])
np.write()              # write data to all pixels


pin = Pin(NeoRGB_PIN, Pin.OUT)     # set GPIOX to output to drive NeoPixels
np = NeoPixel(pin, NeoRGB_PIXELS)  # create NeoPixel driver on GPIO0 for Y pixels
np[0] = (255, 255, 255) # set the first pixel to white
np.write()              # write data to all pixels
r, g, b = np[0]         # get first pixel colour
'''