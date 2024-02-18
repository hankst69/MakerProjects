// Test for minimum program size.

#include <stdio.h>
#include <Wire.h>
#include "SSD1306Ascii.h"
#include "SSD1306AsciiWire.h"
#include "RTClib.h"

// 0X3C+SA0 - 0x3C or 0x3D
#define I2C_ADDRESS 0x3C
// Define proper RST_PIN if required.
#define RST_PIN -1

SSD1306AsciiWire oled;
RTC_DS3231 rtc;
char daysOfTheWeek[7][12] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};


//------------------------------------------------------------------------------
void setup() {
  Wire.begin();
  Wire.setClock(400000L);

#if RST_PIN >= 0
  oled.begin(&Adafruit128x64, I2C_ADDRESS, RST_PIN);
#else // RST_PIN >= 0
  oled.begin(&Adafruit128x64, I2C_ADDRESS);
#endif // RST_PIN >= 0

  oled.setFont(System5x7);
  oled.clear();
  oled.println("Thermometer Clock");

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
    oled.clear();
    oled.println("Thermometer Clock");
    oled.println();

    DateTime now = rtc.now();

    char dateStr[256];
    sprintf(dateStr, "%02d.%02d.%04d\0", now.day(), now.month(), now.year());
    char timeStr[256];
    sprintf(timeStr, "%02d:%02d:%02d\0", now.hour(), now.minute(), now.second());
#
    oled.print(daysOfTheWeek[now.dayOfTheWeek()]);
    oled.println();
    oled.print(dateStr);
    oled.println();
    oled.print(timeStr);
    oled.println();
    oled.println();

    oled.print("Temperature: ");
    oled.print(rtc.getTemperature());
    oled.println(" C");
/*
    oled.print(" since midnight 1/1/1970 = ");
    oled.print(now.unixtime());
    oled.print("s = ");
    oled.print(now.unixtime() / 86400L);
    oled.println("d");

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
    oled.println();
    delay(5000);
}