@rem https://github.com/hankst69/espBode
@rem https://github.com/Hamhackin/espBode
@rem https://github.com/timkoers/espBode
@rem https://github.com/sq6sfo/espBode
@echo off
call "%~dp0\maker_env.bat"

set "_ESP_BODE_DIR=%MAKER_DIR_PROJECTS%\AWGControl\espBode"
set "_ESP_BODE_AWG_DIR=%MAKER_DIR_PROJECTS%\AWGControl\espBode-awg"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_ESP_BODE_DIR%" "https://github.com/hankst69/espBode.git" --changeDir
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_ESP_BODE_AWG_DIR%" "https://github.com/hankst69/espBode.git" --changeDir --switchBranch awgDevices
