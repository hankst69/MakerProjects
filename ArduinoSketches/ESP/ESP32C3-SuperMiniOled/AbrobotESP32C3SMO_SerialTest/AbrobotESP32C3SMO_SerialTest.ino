/*
Abrobot ESP32-C3-SuperMini-OLED
https://github.com/nrfconnect/sdk-zephyr/blob/main//boards/shields/abrobot_esp32c3_oled/doc/index.rst
https://github.com/nrfconnect/sdk-zephyr/tree/main/boards/shields/abrobot_esp32c3_oled
Abrobot esp32c3 oled only works with sh1106_compatible display driver. It does not support 1306 display driver commands. Its screen resolution is 72x40. Its screen start position is 30, 12.

Board: "MakerGO ESP32 C3 SuperMini" from board library "esp32 by Espressif Systems"
Board: "ESP32C3 Dev Module" from board library "esp32 by Espressif Systems"
*/

#include <U8g2lib.h>
#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SH1106_72X40_WISE_F_HW_I2C
#define ESPC3MINIOLED_OLED_ROTATION  U8G2_R0
#define ESPC3MINIOLED_OLED_PIN_RESET U8X8_PIN_NONE
#define ESPC3MINIOLED_OLED_PIN_CLOCK 6
#define ESPC3MINIOLED_OLED_PIN_DATA  5
#define ESPC3MINIOLED_OLED_WIDTH 72
#define ESPC3MINIOLED_OLED_HEIGHT 40
#define ESPC3MINIOLED_LED_PIN 8

#define OLED_FONT u8g2_font_6x10_tf //u8g2_font_5x7_tf 

ESPC3MINIOLED_OLED_U8G2TYPE u8g2(ESPC3MINIOLED_OLED_ROTATION, ESPC3MINIOLED_OLED_PIN_RESET, ESPC3MINIOLED_OLED_PIN_CLOCK, ESPC3MINIOLED_OLED_PIN_DATA);

void setup() {
  Serial.begin(115200);
  for (int i=0; i<10; i++) {
    Serial.println("SerialTest");
  }

  // init OLED driver
  u8g2.begin();
  u8g2.setFont(OLED_FONT);
  u8g2.setFontPosTop();
  u8g2.drawRFrame(0, 0, ESPC3MINIOLED_OLED_WIDTH, ESPC3MINIOLED_OLED_HEIGHT, 5);
  u8g2.drawStr(5, 15, "SerialTest");
  u8g2.sendBuffer(); 

  // init LED I/O PIN
  pinMode(ESPC3MINIOLED_LED_PIN, OUTPUT);
}


void loop() {
  delay(5000);
  Serial.println("Serial output...");
  digitalWrite(ESPC3MINIOLED_LED_PIN, !digitalRead(ESPC3MINIOLED_LED_PIN));
}
