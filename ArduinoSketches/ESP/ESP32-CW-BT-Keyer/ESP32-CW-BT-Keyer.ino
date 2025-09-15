/**************************************************************************************************************************
CW-BT-Keyer

ESP32 based bridge between dual paddle keyer and iOS App "Morse Sensei" by simulation a bluetooth keyboard

This project could be extended to evolve into an iambic keyer itself outputing audio via bluetooth 3.5mm jack
**************************************************************************************************************************/

#include <BleKeyboard.h>
#include <U8g2lib.h>

/* *** Defines for board "Abrobot ESP32-C3-SuperMini-OLED" ***
   see: https://emalliab.wordpress.com/2025/02/12/esp32-c3-0-42-oled
   remark: Abrobot esp32c3 oled only works with sh1106_compatible display driver. It does not support 1306 display driver commands. Its screen resolution is 72x40. Its screen start position is 30, 12.
   board: "MakerGO ESP32 C3 SuperMini" from board library "esp32 by Espressif Systems"
   board: "ESP32C3 Dev Module" from board library "esp32 by Espressif Systems"
*/ 
#define ESPC3MINIOLED_OLED_U8G2TYPE  U8G2_SH1106_72X40_WISE_F_HW_I2C
#define ESPC3MINIOLED_OLED_ROTATION  U8G2_R0
#define ESPC3MINIOLED_OLED_PIN_RESET U8X8_PIN_NONE
#define ESPC3MINIOLED_OLED_PIN_CLOCK 6
#define ESPC3MINIOLED_OLED_PIN_DATA  5
#define ESPC3MINIOLED_OLED_WIDTH 72
#define ESPC3MINIOLED_OLED_HEIGHT 40
#define ESPC3MINIOLED_LED_PIN 8

// *** Defines for CW-BT-Keyer behaviours ***
#define OLED_FONT u8g2_font_6x10_tf //u8g2_font_5x7_tf 
#define BT_CONNECT_MODULO 4
#define BT_CONNECT_SLEEP  1000
#define CWPADDLE_LEFT_PIN 0
#define CWPADDLE_RIGHT_PIN 1


// struct for interrupt handling and key debouncing
struct Button {
    const uint8_t PIN;
    bool is_pressed;
    unsigned long pressed_time_ms;
    unsigned long released_time_ms;
    unsigned long pressed_count;
    unsigned long released_count;
};


// globals
BleKeyboard bleKeyboard("CW-BT-Keyer");
ESPC3MINIOLED_OLED_U8G2TYPE u8g2(ESPC3MINIOLED_OLED_ROTATION, ESPC3MINIOLED_OLED_PIN_RESET, ESPC3MINIOLED_OLED_PIN_CLOCK, ESPC3MINIOLED_OLED_PIN_DATA);

unsigned long bt_connect_try = 0;
bool bt_connected = false;

Button cw_left_paddle = {CWPADDLE_LEFT_PIN, false, 0, 0, 0, 0};
Button cw_right_paddle = {CWPADDLE_RIGHT_PIN, false, 0, 0, 0, 0};
unsigned long button_jitter_time_ms = 300;

unsigned long cw_pressed_sum = 0;
unsigned long cw_released_sum = 0;
bool cw_left_pressed = false;
bool cw_right_pressed = false;
bool cw_left_is_dit_right_is_dah = true;
#define KEY_SPACE ' ' // define missing definition for SPACE key
unsigned char cw_dit_key = KEY_SPACE;
unsigned char cw_dah_key = KEY_RETURN; //'a';//KEY_RETURN;


void IRAM_ATTR cw_paddle_state_changed(Button *changed) {
  // a button press pulls the pin down to GND -> 0 == is_pressed
  bool is_pressed = digitalRead(changed->PIN) == 0;
  bool was_pressed = changed->is_pressed;

  if (is_pressed && !was_pressed) {
    unsigned long time_ms = millis();
    if (time_ms - changed->pressed_time_ms < button_jitter_time_ms) {
      return;
    }
    changed->pressed_time_ms = time_ms;
    changed->is_pressed = true;
  } else if (!is_pressed && was_pressed) {
    unsigned long time_ms = millis();
    if (time_ms - changed->pressed_time_ms < button_jitter_time_ms) {
      return;
    }
    changed->released_time_ms = time_ms;
    changed->is_pressed = false;
  }

  is_pressed = changed->is_pressed;
  if (is_pressed == was_pressed) {
    return;
  }

  // bleKeyboard.press needs to be done in loop()
  // bool changed_is_left = changed->PIN == CWPADDLE_LEFT_PIN;
  // unsigned char changed_key = changed_is_left 
  //   ? (cw_left_is_dit_right_is_dah ? cw_dit_key : cw_dah_key)
  //   : (cw_left_is_dit_right_is_dah ? cw_dah_key : cw_dit_key);
  if (is_pressed) {
    changed->pressed_count++;
    //digitalWrite(ESPC3MINIOLED_LED_PIN, LOW);
    //bleKeyboard.press(changed_key);
  } else {
    changed->released_count++;
    //digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);
    //bleKeyboard.release(changed_key);
  }
}

void IRAM_ATTR isr_cw_left_changed() {
  cw_paddle_state_changed(&cw_left_paddle);
}
void IRAM_ATTR isr_cw_right_changed() {
  cw_paddle_state_changed(&cw_right_paddle);
}


void setup() {
  // init Serial
  Serial.begin(115200);
  while (!Serial) {
    Serial.println("CW-BT-Keyer");
    delay(50);
  }
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
      Serial.println("bluetooth disconnected");
    }
    bt_connected = false;
    bt_connect_try++;
    u8g2.clearBuffer();
    u8g2.drawStr(4, 3, "CW-BT-Keyer");
    u8g2.drawFrame(0, 0, ESPC3MINIOLED_OLED_WIDTH, 15);
    String bt_info = "BT wait.";
    int bt_cnn_progress = bt_connect_try % BT_CONNECT_MODULO;
    for (int i=0; i<bt_cnn_progress; i++) {bt_info += ".";}
    u8g2.drawStr(0, 20, bt_info.c_str());
    u8g2.sendBuffer();
    bool led_on = bt_connect_try % 2;
    digitalWrite(ESPC3MINIOLED_LED_PIN, led_on ? HIGH : LOW);
    Serial.println("bluetooth waiting to connect");
    delay(BT_CONNECT_SLEEP);
    return;
  }

  // bluetooth is now connected
  if (!bt_connected) {
    // bluetooth was not conected before
    // -> we do this here just once on transition to connected
    bt_connected = true;
    Serial.println("bluetooth connected");
    digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);

    attachInterrupt(cw_left_paddle.PIN, isr_cw_left_changed, CHANGE);
    attachInterrupt(cw_right_paddle.PIN, isr_cw_right_changed, CHANGE);

    u8g2.clearBuffer();
    u8g2.drawStr(4, 3, "CW-BT-Keyer");
    u8g2.drawFrame(0, 0, ESPC3MINIOLED_OLED_WIDTH, 15);
    u8g2.drawStr(0, 20, "BT connected");
    u8g2.sendBuffer();
  }

  unsigned long pressed_sum = cw_left_paddle.pressed_count + cw_right_paddle.pressed_count;
  unsigned long released_sum = cw_left_paddle.released_count + cw_right_paddle.released_count;
  if (pressed_sum < 1) {
    Serial.println("waiting for CW key pressed");
    delay(3000);
    digitalWrite(ESPC3MINIOLED_LED_PIN, LOW);
    delay(50);
    digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);
    return;
  }

  if (pressed_sum > cw_pressed_sum || released_sum > cw_released_sum) {
    cw_pressed_sum = pressed_sum;
    cw_released_sum = released_sum;

    Serial.println("");
    Serial.println("pressed state changed");
    Serial.print("cw_left_paddle  is_pressed     : "); Serial.println(cw_left_paddle.is_pressed);
    Serial.print("cw_right_paddle is_pressed     : "); Serial.println(cw_right_paddle.is_pressed);
    Serial.print("cw_left_paddle  pressed_count  : "); Serial.println(cw_left_paddle.pressed_count);
    Serial.print("cw_left_paddle  released_count : "); Serial.println(cw_left_paddle.released_count);
    Serial.print("cw_right_paddle pressed_count  : "); Serial.println(cw_right_paddle.pressed_count);
    Serial.print("cw_right_paddle released_count : "); Serial.println(cw_right_paddle.released_count);
    Serial.print("cw_left_pressed "); Serial.println(cw_left_pressed);
    Serial.print("cw_right_pressed "); Serial.println(cw_right_pressed);

    if (cw_left_pressed != cw_left_paddle.is_pressed) {
      cw_left_pressed = cw_left_paddle.is_pressed;
      unsigned char key = cw_left_is_dit_right_is_dah ? cw_dit_key : cw_dah_key;
      if (cw_left_pressed) {
        digitalWrite(ESPC3MINIOLED_LED_PIN, LOW);
        bleKeyboard.press(key);
        //bleKeyboard.write(key);
      } else {
        digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);
        bleKeyboard.release(key);
      }
    }
    if (cw_right_pressed != cw_right_paddle.is_pressed) {
      cw_right_pressed = cw_right_paddle.is_pressed;
      unsigned char key = cw_left_is_dit_right_is_dah ? cw_dah_key : cw_dit_key;
      if (cw_right_pressed) {
        digitalWrite(ESPC3MINIOLED_LED_PIN, LOW);
        bleKeyboard.press(key);
        //bleKeyboard.write(key);
      } else {
        digitalWrite(ESPC3MINIOLED_LED_PIN, HIGH);
        bleKeyboard.release(key);
      }
    }

    u8g2.clearBuffer();
    u8g2.drawStr(4, 3, "CW-BT-Keyer");
    u8g2.drawFrame(0, 0, ESPC3MINIOLED_OLED_WIDTH, 15);
    String count_info = "L " + String(cw_left_paddle.pressed_count) + "  R " + String(cw_right_paddle.pressed_count); 
    u8g2.drawStr(0, 20, count_info.c_str());
    u8g2.sendBuffer();
    delay(10);
    return;
  }

  delay(200);
  return;

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
}
