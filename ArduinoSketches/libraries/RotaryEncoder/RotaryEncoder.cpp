#include "RotaryEncoder.h"

// for definition of: pinMode(), digitalRead(), INPUT_PULLUP, LOW, HIGH
#if ARDUINO >= 100
  #include <Arduino.h>
#else
  #include <WProgram.h>
  #include <pins_arduino.h>
#endif
/*
#ifndef LOW
  #define LOW  0x0
#endif
#ifndef HIGH
  #define HIGH 0x1
#endif
*/

//RotaryEncoder::RotaryEncoder() {}

bool RotaryEncoder::init(int clk_pin, int dt_pin, int sw_pin, RotaryEncoderPressedCallback callback, void* callback_datacontext) {
  this->clk_pin = clk_pin;
  this->dt_pin = dt_pin;
  this->sw_pin = sw_pin;
  this->pressed_callback = callback;
  this->callback_datacontext = callback_datacontext;
  // init IO-pins for RotaryEncoder
  pinMode(clk_pin, INPUT_PULLUP);
  pinMode(dt_pin, INPUT_PULLUP);
  pinMode(sw_pin, INPUT_PULLUP);
  return true;
}

//------------------------------------------------------------------------------
// RotaryEncoder

void RotaryEncoder::resetPosition() {
  this->position = 0;
}

int RotaryEncoder::getPosition() {
  return this->position;
}

bool RotaryEncoder::getPressed() {
  return this->taster;
}


void RotaryEncoder::loop() {
  if (!(this->clk_pin && this->dt_pin && this->sw_pin)) {
	  //Serial.println("error: rotaryEncoderInit() was not called or called with incorrect params");
    return;
  }
  // update RotaryEncoder state
	int n = digitalRead(this->clk_pin);
	this->taster = !digitalRead(this->sw_pin);
	if(this->taster != this->last_taster) {
    if (this->pressed_callback) {
      this->pressed_callback(this->taster, this->callback_datacontext);
    }
    //Serial.print(this->position);
	  //Serial.print("|");
	  //Serial.println(taster_);
	  delay(10);
	  this->last_taster = this->taster;
	}
	// one tab
	if((this->last_position == 0) && (n == HIGH)) {
	  if(digitalRead(this->dt_pin) == LOW) {
	    this->position++;
      if (this->position > this->position_max) {
        this->position = this->position_max;
      }
	  }
	  else {
	    this->position--;
      if (this->position < this->position_min) {
        this->position = this->position_min;
      }
	  }
	  //Serial.print(position_);
	  //Serial.print("|");
	  //Serial.println(taster_);
	}
	this->last_position = n;  
}
