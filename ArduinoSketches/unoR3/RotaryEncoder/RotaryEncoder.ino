#include "RotaryEncoder.h"

// RotaryEncoder definitions:
#define ROTARYENC_CLK_PIN 2
#define ROTARYENC_DT_PIN 3
#define ROTARYENC_SW_PIN 4

// forward declarations
void onRotaryEncoderTasterPressed(bool pressed, void* data);

// globals 
RotaryEncoder rotaryenc;

//------------------------------------------------------------------------------
void setup() {
  // init serial interface for printing debug infos to SerialMonitor
  Serial.begin(9600);

  // init RotaryEncoder
  rotaryenc.init(ROTARYENC_CLK_PIN, ROTARYENC_DT_PIN, ROTARYENC_SW_PIN,
    onRotaryEncoderTasterPressed);
}

//------------------------------------------------------------------------------
void loop() {
  rotaryenc.loop();
  displayUpdateLoop();
}


//------------------------------------------------------------------------------
// APP logic
#define MENU_ThermoClockDisplay 0
#define MENU_RotaryEncoderDisplay 1
#define MENU_ServoTestDisplay 2
#define MENU_MaxEntry 2
int menuEntry = MENU_ThermoClockDisplay;
int menuEntry_last = -1;
bool menuEntry_change_on_rotaryEncoder_pressed = true;
int rotateMenuSelection(int entry) {
  if (!menuEntry_change_on_rotaryEncoder_pressed) {
    return entry;
  }
  entry++;
  if (entry > MENU_MaxEntry) {
    entry = 0;
  }
  return entry;
}

#define DISPLAY_UPDATE_INTERVAL_MILLISECONDS 1000
#define DISPLAY_UPDATE_DELAY_MILLISECONDS 2
int display_update_milliseonds = 0;

void displayUpdateLoop() {
  if (display_update_milliseonds < DISPLAY_UPDATE_INTERVAL_MILLISECONDS) {
    display_update_milliseonds += DISPLAY_UPDATE_DELAY_MILLISECONDS;
    delay(DISPLAY_UPDATE_DELAY_MILLISECONDS);
    return;
  }
  display_update_milliseonds = 0;

  if (menuEntry != menuEntry_last) {
    menuEntry_last = menuEntry;
    rotaryenc.resetPosition();
  }

  switch (menuEntry) {
    case MENU_ThermoClockDisplay:
      updateThermoClockDisplay();
      break;

    case MENU_RotaryEncoderDisplay:
      menuEntry_change_on_rotaryEncoder_pressed = false;
      if (updateRotaryEncoderDisplay()) {
        menuEntry_change_on_rotaryEncoder_pressed = true;
        menuEntry = rotateMenuSelection(menuEntry);
      }
      break;

    case MENU_ServoTestDisplay:
      updateServoTestDisplay();
      break;

    default:
      menuEntry = 0;
  }
}

//------------------------------------------------------------------------------
void onRotaryEncoderTasterPressed(bool pressed, void* data) {
  Serial.print("onRotaryEncoderTasterPressed(");
  Serial.print(pressed);
  Serial.print(",");
  Serial.print((int)data);
  Serial.println(")");
  if (pressed) {
    //int* intPtr = (int*)data;
    //*intPtr = rotateMenuSelection(*intPtr);
    menuEntry = rotateMenuSelection(menuEntry);
    Serial.print("menuEntry = ");
    Serial.println(menuEntry);
  }
}

//------------------------------------------------------------------------------
// RotaryEncoder Test
bool updateRotaryEncoderDisplay() {
  // https://cdn.shopify.com/s/files/1/1509/1638/files/AZ165_B_23-7_EN_B07TKK4QQD_a0148fb6-0b2b-4a59-a903-9ade7ef9fdd0.pdf
  bool pressed = rotaryenc.getPressed(); 
  int pos = rotaryenc.getPosition();

  Serial.println("Rotary Encoder");
  Serial.println();
  Serial.print("position: "); Serial.print(pos);
  Serial.println();
  Serial.print(" pressed: "); Serial.print(pressed);
  Serial.println();
  return pressed && !pos;
}

//------------------------------------------------------------------------------
// ServoTest
void updateServoTestDisplay() {
  // https://docs.arduino.cc/learn/electronics/servo-motors/
  int pos = rotaryenc.getPosition();

  // init serial interface for printing debug infos to SerialMonitor
  Serial.println("Servo Test");
  Serial.println();
  Serial.print("position: "); Serial.print(pos); 
  Serial.println();

  //int val = map(pos, -50, 50, 0, 180);     // scale it to use it with the servo (value between 0 and 180)
  //servo1.write(val);                   // sets the servo position according to the scaled value
  //delay(15);                           // waits for the servo to get ther
}

//------------------------------------------------------------------------------
// ThermoClock
//DateTime lastDisplayUpdate;
void updateThermoClockDisplay() {
 
  Serial.println("Thermometer Clock");
  /*
  char daysOfTheWeek[7][12] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
  char dateStr[256];
  char timeStr[256];

  DateTime now = rtc.now();
  sprintf(dateStr, "%02d.%02d.%04d\0", now.day(), now.month(), now.year());
  sprintf(timeStr, "%02d:%02d:%02d\0", now.hour(), now.minute(), now.second());
  // TimeSpan span = now - lastDisplayUpdate;
  // auto spanSecs = span.seconds(); 
  // //Serial.print(".");
  // if (spanSecs * 1000 < DISPLAY_UPDATE_INTERVAL_MILLISECONDS) {
  //   Serial.println(spanSecs);
  //   delay(100);
  //   return;
  // }
  // lastDisplayUpdate = now;

  oled.home();
  oled.println("Thermometer Clock");
  oled.println();
  oled.println(daysOfTheWeek[now.dayOfTheWeek()]);
  oled.println(dateStr);
  oled.println(timeStr);
  oled.println();
  oled.print("Temperature: ");
  oled.print(rtc.getTemperature());
  oled.println(" C");
  //oled.println();

  Serial.print(" since midnight 1/1/1970 = ");
  Serial.print(now.unixtime());
  Serial.print("s = ");
  Serial.print(now.unixtime() / 86400L);
  Serial.println("d");
  */
/*
  // calculate a date which is 7 days, 12 hours, 30 minutes, 6 seconds into the future
  DateTime future (now + TimeSpan(7,12,30,6));
  Serial.print(" now + 7d + 12h + 30m + 6s: ");
  Serial.print(future.year(), DEC);
  Serial.print('/');
  Serial.print(future.month(), DEC);
  Serial.print('/');
  Serial.print(future.day(), DEC);
  Serial.print(' ');
  Serial.print(future.hour(), DEC);
  Serial.print(':');
  Serial.print(future.minute(), DEC);
  Serial.print(':');
  Serial.print(future.second(), DEC);
  Serial.println();
*/
}
