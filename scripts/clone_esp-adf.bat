@echo off
rem https://github.com/espressif/esp-adf.git
rem 
rem esp-adf v2.7 -> esp-idf v5.3

set "_ESP_ADF_VERSION=%MAKER_ENV_VERSION%"
rem apply defaults
rem if "%_EMSDK_VERSION%"  equ "" set _EMSDK_VERSION=1.38.45
rem if "%_EMSDK_VERSION%"  equ "" set "_EMSDK_VERSION=3.1.67" &rem (current latest as of 2024/09)
if "%_EMSDK_VERSION%"  equ "" set _EMSDK_VERSION=latest



rem o obtain ESP-ADF v2.7, it is highly recommended to use the following git commands. Make sure to update the submodules as well (using git submodule update --init --recursive) to ensure the source files work properly.
rem 
rem git clone https://github.com/espressif/esp-adf.git esp-adf-v2.7
rem 
rem cd esp-adf-v2.7
rem
rem git checkout v2.7
rem 
rem git submodule update --init --recursive
goto :EOF

call "%~dp0\maker_env.bat"
set "_ESP_IDF_DIR=%MAKER_TOOLS%\Esp-adf"
set "_ESP_ADF_DIR=%MAKER_TOOLS%\Esp-adf"
rem call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_ESP8266_DIR%" "https://github.com/esp8266/Arduino.git" --changeDir
rem cd /d "%MAKER_TOOLS%"
