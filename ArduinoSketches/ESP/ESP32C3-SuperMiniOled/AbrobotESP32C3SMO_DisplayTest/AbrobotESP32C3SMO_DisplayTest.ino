// ESP32-C3-ABrobot-OLED
// https://michiel.vanderwulp.be/domotica/Modules/ESP32-C3-SuperMini-OLED

// https://de.aliexpress.com/item/1005007892774677.html#nav-specification
// Dieser Bildschirm unterscheidet sich von anderen 0,42-Zoll-Bildschirmen.Der Ausgangspunkt des Bildschirms lautet 12864 (13, 14)
// Bitte achten Sie vor dem Kauf darauf, andere 0,42-Zoll-Bildschirme dürfen nicht direkt ersetzen

//#include "Wire.h"
#include "U8g2lib.h"
                                   
#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SSD1306_72X40_ER_F_HW_I2C
#define ESPC3MINIOLED_OLED_ROTATION  U8G2_R0
#define ESPC3MINIOLED_OLED_PIN_RESET U8X8_PIN_NONE
#define ESPC3MINIOLED_OLED_PIN_CLOCK 6
#define ESPC3MINIOLED_OLED_PIN_DATA  5
//U8G2_SSD1306_72X40_ER_F_HW_I2C(const u8g2_cb_t *rotation, uint8_t reset = U8X8_PIN_NONE, uint8_t clock = U8X8_PIN_NONE, uint8_t data = U8X8_PIN_NONE)
//U8G2_SSD1306_72X40_ER_F_HW_I2C u8g2(rotation=U8G2_R0, reset=U8X8_PIN_NONE, clock=6, data=5);
ESPC3MINIOLED_OLED_U8G2TYPE u8g2(ESPC3MINIOLED_OLED_ROTATION, ESPC3MINIOLED_OLED_PIN_RESET, ESPC3MINIOLED_OLED_PIN_CLOCK, ESPC3MINIOLED_OLED_PIN_DATA);

void setup() {
    u8g2.begin();
    u8g2.clearBuffer();
    u8g2.setFont(u8g2_font_6x10_tf);
    u8g2.drawStr(10, 10, "Hello");
    //u8g2.drawStr(0, 30, "Hello OLED");
    u8g2.sendBuffer();
}

void loop() {}
