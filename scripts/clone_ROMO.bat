@rem http://dhgoeken.com/Romo/RomoHack.htm
@rem https://github.com/Navideck/Romo-Firmware.git
@rem https://github.com/Navideck/Romo.git
@rem https://github.com/Navideck/Scratch2Romo.git
@rem https://github.com/champierre/Romo.git
@rem https://github.com/champierre/Scratch2Romo.git
@rem 
@rem https://medium.com/@laanlabs/how-to-make-a-cheap-arkit-home-robot-3db599377e4f
@rem https://github.com/laanlabs/HomeRobot.git
@echo off
call "%~dp0\maker_env.bat"

set "_ROMO_DIR=%MAKER_PROJECTS%\Romo"

set "_ROMO_FW_DIR=%_ROMO_DIR%\Romo_FW"
set "_ROMO_APP_DIR=%_ROMO_DIR%\Romo_APP"
set "_ROMO_SDK_DIR=%_ROMO_DIR%\Romo_SDK"
set "_ROMO_SCRATCH_DIR=%_ROMO_DIR%\Scratch2Romo"
set "_ROMO_ARKIT_DIR=%_ROMO_DIR%\Romo_ARKit"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ROMO_FW_DIR%" "https://github.com/Navideck/Romo-Firmware.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ROMO_APP_DIR%" "https://github.com/Navideck/Romo.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ROMO_SDK_DIR%" "https://github.com/champierre/Romo.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ROMO_SCRATCH_DIR%" "https://github.com/Navideck/Scratch2Romo.git" %*
rem call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ROMO_SCRATCH_DIR%" "https://github.com/champierre/Scratch2Romo.git" %*
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_ROMO_ARKIT_DIR%" "https://github.com/laanlabs/HomeRobot.git" %*

cd /d "%_ROMO_DIR%"
