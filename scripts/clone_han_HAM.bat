@rem https://github.com/hankst69/han_HAM.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_DIR_PROJECTS_HANHAM=%MAKER_DIR_PROJECTS%\han_HAM"
set "_HAN_HAM_DIR=%MAKER_DIR_PROJECTS_HANHAM%"
set "_HAN_HAM_LIC_DIR=%MAKER_DIR_PROJECTS_HANHAM%\Amateurfunk-Lizenz"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_HAN_HAM_DIR%" "https://github.com/hankst69/han_HAM.git"
call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_HAN_HAM_LIC_DIR%" "https://github.com/hankst69/han_HAM_license.git"

cd /d "%_HAN_HAM_DIR%"