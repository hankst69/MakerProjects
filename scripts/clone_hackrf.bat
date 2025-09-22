@rem HackRF+PortaPack - Mayhem
@rem https://github.com/portapack-mayhem/mayhem-firmware
@rem https://github.com/portapack-mayhem/mayhem-mdk
@rem https://github.com/portapack-mayhem/mayhem-freqman-files
@rem https://github.com/portapack-mayhem/MayhemHub
@echo off
call "%~dp0\maker_env.bat"

set "_HACKRF_DIR=%MAKER_PROJECTS%\HackRF"

set "_HACKRF_FIRMWARE_DIR=%_HACKRF_DIR%\mayhem-firmware"
set "_HACKRF_MDK_DIR=%_HACKRF_DIR%\mayhem-mdk"
set "_HACKRF_FREQUMAN_DIR=%_HACKRF_DIR%\mayhem-freqman-files"
set "_HACKRF_HUB_DIR=%_HACKRF_DIR%\MayhemHub"

if /i "%MAKER_ENV_UNKNOWN_SWITCH_1%" equ "--all" goto :CloneAll
if /i "%MAKER_ENV_UNKNOWN_SWITCH_1%" equ "-a" goto :CloneAll

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HACKRF_FIRMWARE_DIR%" "https://github.com/portapack-mayhem/mayhem-firmware.git" %*
echo.
cd /d "%_HACKRF_FIRMWARE_DIR%\firmware\tools"
echo myhem tools for data generation:
echo ^>python generate_world_map.bin.py
echo ^>python make_airlines_db\make_airlines_db.py
goto :EOF

:CloneAll
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HACKRF_FIRMWARE_DIR%" "https://github.com/portapack-mayhem/mayhem-firmware.git" --recurse-submodules %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HACKRF_MDK_DIR%" "https://github.com/portapack-mayhem/mayhem-mdk.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HACKRF_FREQUMAN_DIR%" "https://github.com/portapack-mayhem/mayhem-freqman-files.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HACKRF_HUB_DIR%" "https://github.com/portapack-mayhem/MayhemHub.git" %*
cd /d "%_HACKRF_DIR%"

