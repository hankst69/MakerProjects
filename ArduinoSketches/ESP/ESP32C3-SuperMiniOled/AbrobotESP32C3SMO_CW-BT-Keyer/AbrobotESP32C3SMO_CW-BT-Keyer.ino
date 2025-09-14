// Abrobot ESP32-C3-SuperMini-OLED
// https://github.com/nrfconnect/sdk-zephyr/blob/main//boards/shields/abrobot_esp32c3_oled/doc/index.rst
// https://github.com/nrfconnect/sdk-zephyr/tree/main/boards/shields/abrobot_esp32c3_oled
// Abrobot esp32c3 oled only works with sh1106_compatible display driver. It does not support 1306 display driver commands. Its screen resolution is 72x40. Its screen start position is 30, 12.

#include <BleKeyboard.h>
//#include "BleAbsMouse.h"
#include <U8g2lib.h>

#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SH1106_72X40_WISE_F_HW_I2C
#define ESPC3MINIOLED_OLED_ROTATION  U8G2_R0
#define ESPC3MINIOLED_OLED_PIN_RESET U8X8_PIN_NONE
#define ESPC3MINIOLED_OLED_PIN_CLOCK 6
#define ESPC3MINIOLED_OLED_PIN_DATA  5
#define ESPC3MINIOLED_LED_PIN 8

BleKeyboard bleKeyboard("CW-BT-Keyer");
//BleAbsMouse bleAbsMouse;
ESPC3MINIOLED_OLED_U8G2TYPE u8g2(ESPC3MINIOLED_OLED_ROTATION, ESPC3MINIOLED_OLED_PIN_RESET, ESPC3MINIOLED_OLED_PIN_CLOCK, ESPC3MINIOLED_OLED_PIN_DATA);


#define CWPADDLE_LEFT_PIN 3
#define CWPADDLE_RIGHT_PIN 4
#define CWPADDLE_LEFT_PIN 0

#define BT_CONNECT_MODULO 4
#define BT_CONNECT_SLEEP  500
int bt_connect_try = 0;


void setup() {
  // init BT driver
  bleKeyboard.begin();	
  //bleAbsMouse.begin();

  // init OLED driver
  u8g2.begin();

  // init PINS for I/O
  pinMode(ESPC3MINIOLED_LED_PIN, OUTPUT);
  pinMode(CWPADDLE_LEFT_PIN, INPUT_PULLUP); //configure pin as an input and enable the internal pull-up resistor
  pinMode(CWPADDLE_RIGHT_PIN, INPUT_PULLUP); //configure pin as an input and enable the internal pull-up resistor

  digitalWrite(ESPC3MINIOLED_LED_PIN, LOW);
}


void loop() {
  u8g2.clearBuffer();
  u8g2.setFont(u8g2_font_6x10_tf);
  u8g2.drawStr(0, 10, "** CW-Keyer **");

  bt_connect_try = ++bt_connect_try % BT_CONNECT_MODULO;
  int led_on = bt_connect_try % 2;

  if(!bleKeyboard.isConnected()) {
    

  }  

  if(bleKeyboard.isConnected()) {
    digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);
    u8g2.drawStr(0, 30, "BT connected");
	} else {
    u8g2.drawStr(0, 30, "BT...");
	}
  // if(bleAbsMouse.isConnected()) {
  //   u8g2.drawStr(0, 20, "BT-Mouse connected");
	// } else {
  //   u8g2.drawStr(0, 10, "BT-Mouse ...");
	// }



  u8g2.sendBuffer();
  if(!bleKeyboard.isConnected() /*&& !bleAbsMouse.isConnected()*/) {
    delay(1000);
		return;
	}

  if(bleKeyboard.isConnected()) {
    bleKeyboard.print("Hello world");
    delay(1000);
    //Serial.println("Sending Enter key...");
    bleKeyboard.write(KEY_RETURN);
    delay(1000);

    // Serial.println("Sending Play/Pause media key...");
    // bleKeyboard.write(KEY_MEDIA_PLAY_PAUSE);
    // delay(1000);

		// example of pressing multiple keyboard modifiers 
		// Serial.println("Sending Ctrl+Alt+Delete...");
		// bleKeyboard.press(KEY_LEFT_CTRL);
		// bleKeyboard.press(KEY_LEFT_ALT);
		// bleKeyboard.press(KEY_DELETE);
		// delay(100);
		// bleKeyboard.releaseAll();
	}
    
  // if(bleAbsMouse.isConnected()) {
  //   bleAbsMouse.click(5000, 5000);
	// } else {

  //Serial.println("Waiting 5 seconds...");
  delay(5000);	
}
