@rem https://github.com/esp8266/Arduino.git
@rem https://github.com/espressif/arduino-esp32
@echo off
call "%~dp0\maker_env.bat"

set "_ARDUINO_ESP8266_DIR=%MAKER_TOOLS%\ArduinoESP8266"
set "_ARDUINO_ESP32_DIR=%MAKER_TOOLS%\ArduinoESP32"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_ESP8266_DIR%" "https://github.com/esp8266/Arduino.git" --changeDir
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_ESP32_DIR%" "https://github.com/espressif/arduino-esp32" --changeDir
rem cd /d "%MAKER_TOOLS%"
