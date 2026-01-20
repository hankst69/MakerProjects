@echo off
call "%~dp0\maker_env.bat"

set "_ARDUINO_SKETCHES_DIR=%MAKER_PROJECTS%\ArduinoSketches"

@rem https://github.com/hankst69/espBode
@rem https://github.com/Hamhackin/espBode
@rem https://github.com/timkoers/espBode
@rem https://github.com/sq6sfo/espBode
set "_AS_espBode_DIR=%_ARDUINO_SKETCHES_DIR%\AWGControl\espBode"
set "_AS_espBode-awg_DIR=%_ARDUINO_SKETCHES_DIR%\AWGControl\espBode-awg"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_AS_espBode_DIR%" "https://github.com/hankst69/espBode.git"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_AS_espBode-awg_DIR%" "https://github.com/hankst69/espBode.git" --switchBranch awgDevices

@rem "https://github.com/hankst69/fygen"
@rem "https://github.com/mattwach/fygen"
rem  set "_AS_fygen_DIR=%_ARDUINO_SKETCHES_DIR%\AWGControl\fygen"
rem call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_AS_fygen_DIR%" "https://github.com/hankst69/fygen.git" --changeDir

@rem https://github.com/hankst69/SimpleCWKeyer.git
rem set "_AS_SimpleCWKeyer_DIR=%_ARDUINO_SKETCHES_DIR%\unoR3\SimpleCWKeyer"
set "_AS_SimpleCWKeyer_DIR=%_ARDUINO_SKETCHES_DIR%\SimpleCWKeyer"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_AS_SimpleCWKeyer_DIR%" "https://github.com/hankst69/SimpleCWKeyer.git"

@rem https://github.com/hankst69/ats-mini.git
set "_AS_ATS-Mini_DIR=%_ARDUINO_SKETCHES_DIR%\ATS-Mini"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_AS_ATS-Mini_DIR%" "https://github.com/hankst69/ats-mini.git"


cd /d "%_ARDUINO_SKETCHES_DIR%"