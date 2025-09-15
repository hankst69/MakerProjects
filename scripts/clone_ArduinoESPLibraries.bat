@rem https://github.com/arduino/library-registry/blob/main/FAQ.md#how-can-i-add-a-library-to-library-manager

@echo off
call "%~dp0\maker_env.bat"


rem https://github.com/T-vK/ESP32-BLE-Keyboard.git  https://github.com/hankst69/ESP32-BLE-Keyboard.git
rem https://github.com/T-vK/ESP32-BLE-Mouse.git
rem https://github.com/T-vK/ESP32-BLE-Gamepad.git
rem https://github.com/sobrinho/ESP32-BLE-Abs-Mouse.git

set "_ARDUINO_LIBRARIES_DIR=%MAKER_ROOT%\ArduinoSketches\libraries"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_LIBRARIES_DIR%\ESP32-BLE-Keyboard" "https://github.com/hankst69/ESP32-BLE-Keyboard.git"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_LIBRARIES_DIR%\ESP32-BLE-Mouse" "https://github.com/T-vK/ESP32-BLE-Mouse.git"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_LIBRARIES_DIR%\ESP32-BLE-Gamepad" "https://github.com/lemmingDev/ESP32-BLE-Gamepad.git"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_LIBRARIES_DIR%\ESP32-BLE-Abs-Mouse" "https://github.com/sobrinho/ESP32-BLE-Abs-Mouse.git"

cd /d "%_ARDUINO_LIBRARIES_DIR%"