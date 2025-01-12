/*
ESP32-C3-SuperMini-Plus RGB infos (about built in LEDs) here:
https://forum.arduino.cc/t/esp32-s3-onboard-rgb-led/1198754/8

Board: "MakerGO ESP32 C3 SuperMini" from board library "esp32 by Espressif Systems"
*/

#include <Adafruit_NeoPixel.h> 

#define PIN 8 // ESP32-C3-SMV2 built-in RGB led
#define NUMPIXELS 1

Adafruit_NeoPixel pixels (NUMPIXELS, PIN, NEO_GRB + NEO_KHZ800);
#define DELAYVAL 500


void setup () {  
    Serial.begin (115200);

    Serial.printf ("   PIN %i\n", PIN);          
    
    //pinMode(pin, OUTPUT);           

    pixels.begin();

    pixels.clear();

    for(int i=0; i<5; i++) {
      for(int p=0; p<NUMPIXELS; p++) {
        //pixels.setPixelColor(i, pixels.Color (100, 50, 200));
        pixels.setPixelColor(p, pixels.Color (0, 0, 0));
        pixels.show();
        delay(1000);
        pixels.setPixelColor(p, pixels.Color (40, 40, 40));
        pixels.show();
        delay(1000);
      }
    }

    int minr=0; //0
    int maxr=40; //255
    int ming=0; //0
    int maxg=30; //255
    int minb=0; //0
    int maxb=30; //255

    for(int g=ming; g<=maxg; g++) {
      for(int b=minb; b<=maxb; b++) {
        for(int r=minr; r<=maxr; r++) {

          for(int i=0; i<NUMPIXELS; i++) {
            pixels.setPixelColor(i, pixels.Color (r, g, b));
            pixels.show();
            delay(15);
          }

        }
      }
    }

}

void loop () {
}
