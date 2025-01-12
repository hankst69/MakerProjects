//#include <Arduino.h>
//#include <HardwareSerial.h>
#include "RotaryEncoder.h"

/*
#ifndef ROTARYENC_CLK_PIN 
 #pragma error("ROTARYENC_CLK_PIN is undefined")
#endif
#ifndef ROTARYENC_DT_PIN 
 #pragma error("ROTARYENC_DT_PIN is undefined")
#endif
#ifndef ROTARYENC_SW_PIN 
 #pragma error("ROTARYENC_SW_PIN is undefined")
#endif
*/

//------------------------------------------------------------------------------
// RotaryEncoder
int rotaryenc_clk_pin = 0;
int rotaryenc_dt_pin = 0;
int rotaryenc_sw_pin = 0;
int rotaryenc_position_min = -50;
int rotaryenc_position_max = 50;
int rotaryenc_position = 0;
bool rotaryenc_taster = LOW;
int rotaryenc_last_position = 0;
bool rotaryenc_last_taster = LOW;
RotaryEncoderPressedCallback rotaryenc_pressed_callback = NULL;
void* rotaryenc_callback_datacontext = NULL;

void rotaryEncoderResetPosition() {
  rotaryenc_position = 0;
}

int rotaryEncoderGetPosition() {
  return rotaryenc_position;
}

bool rotaryEncoderGetPressed() {
  return rotaryenc_taster;
}

bool rotaryEncoderInit(int clk_pin, int dt_pin, int sw_pin, RotaryEncoderPressedCallback callback, void* callback_datacontext) {
  rotaryenc_clk_pin = clk_pin;
  rotaryenc_dt_pin = dt_pin;
  rotaryenc_sw_pin = sw_pin;
  rotaryenc_pressed_callback = callback;
  rotaryenc_callback_datacontext = callback_datacontext;
  // init IO-pins for RotaryEncoder
  pinMode(clk_pin, INPUT_PULLUP);
  pinMode(dt_pin, INPUT_PULLUP);
  pinMode(sw_pin, INPUT_PULLUP);
  return true;
}

void rotaryEncoderLoop() {
  if (!(rotaryenc_clk_pin && rotaryenc_dt_pin && rotaryenc_sw_pin)) {
	  //Serial.println("error: rotaryEncoderInit() was not called or called with incorrect params");
    return;
  }
  // update RotaryEncoder state
	int n = digitalRead(rotaryenc_clk_pin);
	rotaryenc_taster = !digitalRead(rotaryenc_sw_pin);
	if(rotaryenc_taster != rotaryenc_last_taster) {
    if (rotaryenc_pressed_callback) {
      rotaryenc_pressed_callback(rotaryenc_taster, rotaryenc_callback_datacontext);
    }
	  //Serial.print(rotaryenc_position);
	  //Serial.print("|");
	  //Serial.println(rotaryenc_taster);
	  delay(10);
	  rotaryenc_last_taster = rotaryenc_taster;
	}
	// one tab
	if((rotaryenc_last_position == 0) && (n == HIGH)) {
	  if(digitalRead(rotaryenc_dt_pin) == LOW) {
	    rotaryenc_position++;
      if (rotaryenc_position > rotaryenc_position_max) {
        rotaryenc_position = rotaryenc_position_max;
      }
	  }
	  else {
	    rotaryenc_position--;
      if (rotaryenc_position < rotaryenc_position_min) {
        rotaryenc_position = rotaryenc_position_min;
      }
	  }
	  //Serial.print(rotaryenc_position);
	  //Serial.print("|");
	  //Serial.println(rotaryenc_taster);
	}
	rotaryenc_last_position = n;  
}
