#https://www.raspberrypi.com/documentation/microcontrollers/micropython.html#where-can-i-find-documentation
#https://docs.micropython.org/en/latest/rp2/quickref.html#general-board-control
#https://docs.micropython.org/en/latest/library/rp2.html

import sys
import machine
print("\n\n")
print("hallo")
sysinfo = sys.implementation
print(f"HW: {sysinfo._machine} {sysinfo._mpy}")
print(f"SW: {sysinfo.name} {sysinfo.version}")
print(f"CPU frequ: {machine.freq()}")


from machine import Pin
import time

ONBOARD_LED_GREEN_PIN = 22    #RP2040 USB onBoard LED connected to GPIO pin 22
ONBOARD_LED_RED_PIN = 23

pin_green = Pin(ONBOARD_LED_GREEN_PIN, Pin.OUT)     # set GPIOX to output
pin_red = Pin(ONBOARD_LED_RED_PIN, Pin.OUT)     # set GPIOX to output

#leds off means to set output to high
pin_green.value(1)
pin_red.value(1)

print("\n2sec")
time.sleep(2)
print("\ngreen on")
pin_green.value(0)
time.sleep(1)
print("\ngreen off")
pin_green.value(1)

print("\n2sec")
time.sleep(2)
print("\nred on")
pin_red.value(0)
time.sleep(1)
print("\nred off")
pin_red.value(1)
