#pragma once

class RotaryEncoder
{
public:
  //RotaryEncoder();
  
  typedef void (*RotaryEncoderPressedCallback) (bool pressed, void *data);
  bool init(int clk_pin, int dt_pin, int sw_pin, RotaryEncoderPressedCallback callback = nullptr, void* callback_datacontext = nullptr);
  void loop();

  void resetPosition();
  int  getPosition();
  bool getPressed();

private:
  int clk_pin = 0;
  int dt_pin = 0;
  int sw_pin = 0;

  int position_min = -50;
  int position_max = 50;
  
  int position = 0;
  bool taster = false;
  
  int last_position = 0;
  bool last_taster = false;
  
  RotaryEncoderPressedCallback pressed_callback = nullptr;
  void* callback_datacontext = nullptr;
};
