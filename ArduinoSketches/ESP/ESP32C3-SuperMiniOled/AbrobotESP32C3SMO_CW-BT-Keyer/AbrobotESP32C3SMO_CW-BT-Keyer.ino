// Abrobot ESP32-C3-SuperMini-OLED
// https://github.com/nrfconnect/sdk-zephyr/blob/main//boards/shields/abrobot_esp32c3_oled/doc/index.rst
// https://github.com/nrfconnect/sdk-zephyr/tree/main/boards/shields/abrobot_esp32c3_oled
// Abrobot esp32c3 oled only works with sh1106_compatible display driver. It does not support 1306 display driver commands. Its screen resolution is 72x40. Its screen start position is 30, 12.

#include <BleKeyboard.h>
#include <U8g2lib.h>

#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SH1106_72X40_WISE_F_HW_I2C
#define ESPC3MINIOLED_OLED_ROTATION  U8G2_R0
#define ESPC3MINIOLED_OLED_PIN_RESET U8X8_PIN_NONE
#define ESPC3MINIOLED_OLED_PIN_CLOCK 6
#define ESPC3MINIOLED_OLED_PIN_DATA  5
#define ESPC3MINIOLED_LED_PIN 8

#define OLED_WIDTH 72
#define OLED_HEIGHT 40
#define OLED_FONT u8g2_font_6x10_tf //u8x8_font_inb33_3x6_n 

#define BT_CONNECT_MODULO 4
#define BT_CONNECT_SLEEP  500

#define CWPADDLE_LEFT_PIN 0
#define CWPADDLE_RIGHT_PIN 1


struct Button {
    const uint8_t PIN;
    bool is_pressed;
    unsigned long last_pressed_time_ms;
    unsigned long last_released_time_ms;
    unsigned long pressed_count;
};


BleKeyboard bleKeyboard("CW-BT-Keyer");
ESPC3MINIOLED_OLED_U8G2TYPE u8g2(ESPC3MINIOLED_OLED_ROTATION, ESPC3MINIOLED_OLED_PIN_RESET, ESPC3MINIOLED_OLED_PIN_CLOCK, ESPC3MINIOLED_OLED_PIN_DATA);

//unsigned long last_loop_time_ms = 0;
//#define KEY_SPACE ' ' // define missing definition for SPACE key

unsigned long bt_connect_try = 0;
bool bt_connected = false;

Button cw_left_paddle = {CWPADDLE_LEFT_PIN, false, 0, 0, 0};
Button cw_right_paddle = {CWPADDLE_RIGHT_PIN, false, 0, 0, 0};
unsigned long button_jitter_time_ms = 250;

bool cw_left_is_dit_dit_right_is_dah = true;
unsigned char cw_dit_key = 'i';//KEY_SPACE;
unsigned char cw_dah_key = 'a';//KEY_RETURN;


void IRAM_ATTR cw_paddle_state_changed(Button *changed, Button *other, bool pressed) {
  unsigned long time_ms = millis();
  unsigned long last_time_ms = pressed ? changed->last_pressed_time_ms : changed->last_released_time_ms;
  if (last_time_ms == 0 || time_ms - last_time_ms > button_jitter_time_ms) {
    bool changed_was_pressed = changed->is_pressed; 
    changed->is_pressed = pressed;
    if (pressed) { 
      changed->last_pressed_time_ms = time_ms; 
    } else {
      changed->last_released_time_ms = time_ms;
    }

    if (changed_was_pressed != changed->is_pressed) {
      if (pressed) {
        changed->pressed_count++;
      }
      //button_state_changed = true;

      // maybe do this in loop() instead in isr()
      bool changed_is_left = changed->PIN == CWPADDLE_LEFT_PIN;
      unsigned char changed_key = changed_is_left &&  cw_left_is_dit_dit_right_is_dah ? cw_dit_key : cw_dah_key;
      if (changed_was_pressed) {
        bleKeyboard.release(changed_key);
        digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);
      } else {
        bleKeyboard.press(changed_key);
        digitalWrite(ESPC3MINIOLED_LED_PIN, LOW);
      }
    }
  }
}

void IRAM_ATTR isr_cw_left_pressed() {
  cw_paddle_state_changed(&cw_left_paddle, &cw_right_paddle, true);
}
void IRAM_ATTR isr_cw_left_released() {
  cw_paddle_state_changed(&cw_left_paddle, &cw_right_paddle, false);
}
void IRAM_ATTR isr_cw_right_pressed() {
  cw_paddle_state_changed(&cw_right_paddle, &cw_left_paddle, true);
}
void IRAM_ATTR isr_cw_right_released() {
  cw_paddle_state_changed(&cw_right_paddle, &cw_left_paddle, false);
}


void setup() {
  // init Serial
  //Serial.begin(115200);

  // init BT driver
  bleKeyboard.begin();	

  // init OLED driver
  u8g2.begin();
  u8g2.setFont(OLED_FONT);
  u8g2.setFontPosTop();

  // init PINS for I/O
  pinMode(ESPC3MINIOLED_LED_PIN, OUTPUT);

  pinMode(cw_left_paddle.PIN, INPUT_PULLUP); //configure pin as an input and enable the internal pull-up resistor
  pinMode(cw_right_paddle.PIN, INPUT_PULLUP);
}


void loop() {
  // check if we are alreday connected as a BT-HID device
  if(!bleKeyboard.isConnected()) {
    // no -> continue waiting for conection + give feedback
    if (bt_connected) {
      // if we were connected before, we detach interrupt routines
      detachInterrupt(cw_left_paddle.PIN);
      detachInterrupt(cw_right_paddle.PIN);
    }
    bt_connected = false;
    bt_connect_try++;
    u8g2.clearBuffer();
    //u8g2.setFont(OLED_FONT);
    u8g2.drawStr(3, 3, "CW-BT-Keyer");
    u8g2.drawFrame(0, 0, OLED_WIDTH, 15);
    String bt_info = "BT wait.";
    int bt_cnn_progress = bt_connect_try % BT_CONNECT_MODULO;
    for (int i=0; i<bt_cnn_progress; i++) {bt_info += ".";}
    u8g2.drawStr(0, 20, bt_info.c_str());
    u8g2.sendBuffer();
    bool led_on = bt_connect_try % 2;
    digitalWrite(ESPC3MINIOLED_LED_PIN, led_on ? HIGH : LOW);
    delay(1000);
    return;
  }

  // bluetooth is now connected
  if (!bt_connected) {
    // bluetooth was not conected before
    // -> we do this here just once on transition to connected
    bt_connected = true;
    //digitalWrite(ESPC3MINIOLED_LED_PIN, LOW);
    digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);
    attachInterrupt(cw_left_paddle.PIN, isr_cw_left_pressed, FALLING); // register pressed interrupt service routine
    attachInterrupt(cw_left_paddle.PIN, isr_cw_left_released, RISING); // register released interrupt service routine
    attachInterrupt(cw_right_paddle.PIN, isr_cw_left_pressed, FALLING);
    attachInterrupt(cw_right_paddle.PIN, isr_cw_left_released, RISING);

    u8g2.clearBuffer();
    //u8g2.setFont(OLED_FONT);
    u8g2.drawStr(3, 3, "CW-BT-Keyer");
    u8g2.drawFrame(0, 0, OLED_WIDTH, 15);
    u8g2.drawStr(0, 20, "BT connected");
    u8g2.sendBuffer();
  }

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

  //Serial.println("Waiting 5 seconds...");
  delay(5000);	
}
