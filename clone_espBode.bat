@rem https://github.com/hankst69/espBode
@rem https://github.com/Hamhackin/espBode
@rem https://github.com/timkoers/espBode
@rem https://github.com/sq6sfo/espBode
@echo off
set "_MAKER_ROOT=%~dp0"

rem set "_ESP_BODE_DIR=%_MAKER_ROOT%espBode"
rem set "_ESP_BODE_DIR=%_MAKER_ROOT%ArduinoSketches\esp01\espBode"
rem set "_ESP_BODE_DIR=%_MAKER_ROOT%projects\mkr\AWGControl\espBode"
rem set "_ESP_BODE_AWG_DIR=%_MAKER_ROOT%projects\mkr\AWGControl\espBode-awg"

set "_ESP_BODE_DIR=%_MAKER_ROOT%projects\AWGControl\espBode"
set "_ESP_BODE_AWG_DIR=%_MAKER_ROOT%projects\AWGControl\espBode-awg"

call "%_MAKER_ROOT%scripts\clone_in_folder.bat" "%_ESP_BODE_DIR%" "https://github.com/hankst69/espBode.git" --changeDir
call "%_MAKER_ROOT%scripts\clone_in_folder.bat" "%_ESP_BODE_AWG_DIR%" "https://github.com/hankst69/espBode.git" --changeDir --switchBranch awgDevices

