@rem https://github.com/hankst69/han_HAM.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_PROJECTS_HANHAM=%MAKER_PROJECTS%\han_HAM"
set "_HAN_HAM_DIR=%MAKER_PROJECTS_HANHAM%"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HAN_HAM_DIR%" "https://github.com/hankst69/han_HAM.git" --changeDir
