/*
the code here is based on ESP32 BoardLibrary Ticker/Blinker example

ESP32-C3 SuperMini infos (about built in LEDs) here:
https://forum.arduino.cc/t/using-the-internal-led-of-esp32-c3-super-mini/1281370/3

Board: "ESP32C3 Dev Module" from board library "esp32 by Espressif Systems"

Other matching boards:
"MakerGO ESP32 C3 SuperMini"
*/

#include <Arduino.h>
#include <Ticker.h>

#define LED_PIN 8

Ticker blinker;
Ticker toggler;
Ticker changer;
float blinkerPace = 0.1;       //seconds
const float togglePeriod = 2;  //seconds

void change() {
  blinkerPace = 0.5;
}

void blink() {
  digitalWrite(LED_PIN, !digitalRead(LED_PIN));
}

void toggle() {
  static bool isBlinking = false;
  if (isBlinking) {
    blinker.detach();
    isBlinking = false;
  } else {
    blinker.attach(blinkerPace, blink);
    isBlinking = true;
  }
  digitalWrite(LED_PIN, LOW);  //make sure LED on on after toggling (pin LOW = led ON)
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  toggler.attach(togglePeriod, toggle);
  changer.once(30, change);
}

void loop() {}
