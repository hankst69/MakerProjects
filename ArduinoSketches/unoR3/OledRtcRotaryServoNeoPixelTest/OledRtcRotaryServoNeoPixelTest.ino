#include <stdio.h>
#include <Wire.h>
#include <SSD1306Ascii.h>
#include <SSD1306AsciiWire.h>
#include <RTClib.h>
#include <Servo.h>
#include "RotaryEncoder.h"

// OLED I2C definitions:
#define OLED_I2C_ADDRESS 0x3C // 0X3C+SA0 - 0x3C or 0x3D
#define OLED_RST_PIN -1 // Define proper RST_PIN if required.
//#define OLED_TYPE Adafruit128x32
#define OLED_TYPE Adafruit128x64

// Servo definitions:
#define SERVO_OUT_PIN 9

// RotaryEncoder definitions:
#define ROTARYENC_CLK_PIN 2
#define ROTARYENC_DT_PIN 3
#define ROTARYENC_SW_PIN 4

// globals 
SSD1306AsciiWire oled;
RTC_DS3231 rtc;
Servo servo1;

//void updateThermoClockDisplay();
//void updateRotaryEncoderDisplay();
//void updateServoTestDisplay();

//------------------------------------------------------------------------------
void setup() {
  // init serial interface for printing debug infos to SerialMonitor
  Serial.begin(9600);

  // init RotaryEncoder
  rotaryEncoderInit(ROTARYENC_CLK_PIN, ROTARYENC_DT_PIN, ROTARYENC_SW_PIN,
    onRotaryEncoderTasterPressed);

  // init Servo control
  servo1.attach(SERVO_OUT_PIN);
  
  // init I2C interface
  Wire.begin();
  Wire.setClock(400000L);

  // init OLED device
#if OLED_RST_PIN >= 0
  oled.begin(&OLED_TYPE, OLED_I2C_ADDRESS, OLED_RST_PIN);
#else
  oled.begin(&OLED_TYPE, OLED_I2C_ADDRESS);
#endif
  oled.setFont(System5x7);
  oled.clear();

  // init RTC device
  if (!rtc.begin()) {
    oled.println("Couldn't find RTC");
    while (1) delay(10);
  }
  if (rtc.lostPower()) {
    oled.println("RTC lost power, let's set the time!");
    // When time needs to be set on a new device, or after a power loss, the
    // following line sets the RTC to the date & time this sketch was compiled
    rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
    // This line sets the RTC with an explicit date & time, for example to set
    // January 21, 2014 at 3am you would call:
    // rtc.adjust(DateTime(2014, 1, 21, 3, 0, 0));
  }
  // When time needs to be re-set on a previously configured device, the
  // following line sets the RTC to the date & time this sketch was compiled
  // rtc.adjust(DateTime(F(__DATE__), F(__TIME__)));
  // This line sets the RTC with an explicit date & time, for example to set
  // January 21, 2014 at 3am you would call:
  // rtc.adjust(DateTime(2014, 1, 21, 3, 0, 0));
}

//------------------------------------------------------------------------------
void loop() {
	rotaryEncoderLoop();
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

#define DISPLAY_UPDATE_INTERVAL_MILLISECONDS 500
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
    oled.clear();
    rotaryEncoderResetPosition();
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
  bool pressed = rotaryEncoderGetPressed(); 
  int pos = rotaryEncoderGetPosition();

  oled.home();
  oled.println("Rotary Encoder");
  oled.println();
  oled.print("position: "); oled.print(pos); oled.clearToEOL();
  oled.println();
  oled.print(" pressed: "); oled.print(pressed); oled.clearToEOL();
  oled.println();
  return pressed && !pos;
}

//------------------------------------------------------------------------------
// ServoTest
void updateServoTestDisplay() {
  // https://docs.arduino.cc/learn/electronics/servo-motors/
  int pos = rotaryEncoderGetPosition();

  oled.home();
  oled.println("Servo Test");
  oled.println();
  oled.print("position: "); oled.print(pos); oled.clearToEOL();
  oled.println();

  int val = map(pos, -50, 50, 0, 180);     // scale it to use it with the servo (value between 0 and 180)
  servo1.write(val);                   // sets the servo position according to the scaled value
  delay(15);                           // waits for the servo to get ther
}

//------------------------------------------------------------------------------
// ThermoClock
//DateTime lastDisplayUpdate;
void updateThermoClockDisplay() {
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


//------------------------------------------------------------------------------
// RotaryEncoder
int rotaryenc_position_min = -50;
int rotaryenc_position_max = 50;
int rotaryenc_position = 0;
bool rotaryenc_taster = LOW;
int rotaryenc_last_position = 0;
bool rotaryenc_last_taster = LOW;
RotaryEncoderPressedCallback rotaryenc_pressed_callback = nullptr;
void* rotaryenc_callback_datacontext = nullptr;

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
  rotaryenc_pressed_callback = callback;
  rotaryenc_callback_datacontext = callback_datacontext;
  // init IO-pins for RotaryEncoder
  pinMode(clk_pin, INPUT_PULLUP);
  pinMode(dt_pin, INPUT_PULLUP);
  pinMode(sw_pin, INPUT_PULLUP);
  return true;
}

void rotaryEncoderLoop() {
  // update RotaryEncoder state
	int n = digitalRead(ROTARYENC_CLK_PIN);
	rotaryenc_taster = !digitalRead(ROTARYENC_SW_PIN);
	if(rotaryenc_taster != rotaryenc_last_taster) {
    if (rotaryenc_pressed_callback) {
      rotaryenc_pressed_callback(rotaryenc_taster, rotaryenc_callback_datacontext);
    }
	  Serial.print(rotaryenc_position);
	  Serial.print("|");
	  Serial.println(rotaryenc_taster);
	  delay(10);
	  rotaryenc_last_taster = rotaryenc_taster;
	}
	// one tab
	if((rotaryenc_last_position == 0) && (n == HIGH)) {
	  if(digitalRead(ROTARYENC_DT_PIN) == LOW) {
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
	  Serial.print(rotaryenc_position);
	  Serial.print("|");
	  Serial.println(rotaryenc_taster);
	}
	rotaryenc_last_position = n;  
}
