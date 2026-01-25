@echo off
call "%~dp0\maker_env.bat"

@rem https://github.com/hankst69/ArduinoSketches
set "_ARDUINO_SKETCHES_DIR=%MAKER_PROJECTS%\ArduinoSketches"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ARDUINO_SKETCHES_DIR%" "https://github.com/hankst69/ArduinoSketches.git"

call "%_ARDUINO_SKETCHES_DIR%\clone_projects.bat"
call "%_ARDUINO_SKETCHES_DIR%\clone_libraries.bat"

cd /d "%_ARDUINO_SKETCHES_DIR%"
goto :EOF
