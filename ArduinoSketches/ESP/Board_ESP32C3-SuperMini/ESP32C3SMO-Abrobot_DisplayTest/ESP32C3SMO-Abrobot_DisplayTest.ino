// ESP32-C3-ABrobot-OLED
// https://michiel.vanderwulp.be/domotica/Modules/ESP32-C3-SuperMini-OLED

// https://de.aliexpress.com/item/1005007892774677.html#nav-specification
// Dieser Bildschirm unterscheidet sich von anderen 0,42-Zoll-Bildschirmen.Der Ausgangspunkt des Bildschirms lautet 12864 (13, 14)
// Bitte achten Sie vor dem Kauf darauf, andere 0,42-Zoll-Bildschirme dürfen nicht direkt ersetzen

// https://github.com/nrfconnect/sdk-zephyr/blob/main//boards/shields/abrobot_esp32c3_oled/doc/index.rst
// https://github.com/nrfconnect/sdk-zephyr/tree/main/boards/shields/abrobot_esp32c3_oled
// Abrobot esp32c3 oled only works with sh1106_compatible display driver. It does not support 1306 display driver commands. Its screen resolution is 72x40. Its screen start position is 30, 12.
/* SHIELD_SH1106_72X40
	abrobot_72x40: ssd1306@3c {
		compatible = "sinowealth,sh1106";
		reg = <0x3c>;
		width = <72>;
		height = <40>;
		segment-offset = <30>;
		page-offset = <0>;
		display-offset = <0xC>;
		multiplex-ratio = <0x27>;
		prechargep = <0x22>;
		ready-time-ms = <10>;
		segment-remap;
		com-invdir;
		use-internal-iref;
	};
*/

//#include "Wire.h"
#include "U8g2lib.h"
                                   
//#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SSD1306_72X40_ER_F_HW_I2C
//#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SH1106_72X40_WISE_1_HW_I2C
//#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SH1106_72X40_WISE_2_HW_I2C
#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SH1106_72X40_WISE_F_HW_I2C
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
    //u8g2.drawStr(10, 10, "Hello");
    u8g2.drawStr(0, 30, "Hello OLED");
    u8g2.sendBuffer();
}

void loop() {}
