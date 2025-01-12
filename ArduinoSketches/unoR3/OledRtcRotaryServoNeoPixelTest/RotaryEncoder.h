//#ifndef _ROTARYENCODER_H_
#define _ROTARYENCODER_H_

#if ARDUINO >= 100
  #include <Arduino.h>
#else
  #include <WProgram.h>
  #include <pins_arduino.h>
#endif


// RotaryEncoder definitions:
//#define ROTARYENC_CLK_PIN 2
//#define ROTARYENC_DT_PIN 3
//#define ROTARYENC_SW_PIN 4

//using RotaryEncoderPressedCallback = 
typedef void (*RotaryEncoderPressedCallback) (bool pressed, void *data);

bool rotaryEncoderInit(int clk_pin, int dt_pin, int sw_pin, RotaryEncoderPressedCallback callback = nullptr, void* callback_datacontext = nullptr);
void rotaryEncoderLoop();

void rotaryEncoderResetPosition();
int  rotaryEncoderGetPosition();
bool rotaryEncoderGetPressed();

//#endif //_ROTARYENCODER_H_