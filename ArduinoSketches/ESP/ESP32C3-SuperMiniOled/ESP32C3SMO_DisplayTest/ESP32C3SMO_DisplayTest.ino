#include <u8g2lib.h>
#include <wire.h>

U8G2_SSD1306_72X40_ER_F_HW_I2C u8g2(U8G2_R0, reset=U8X8_PIN_NONE, clock=6, data=5);

void setup() {
    u8g2.begin();
    u8g2.clearBuffer();
    u8g2.setFont(u8g2_font_6x10_tf);
    u8g2.drawStr(0, 30, "Hello OLED");
    u8g2.sendBuffer();
}

void loop() {}
