@rem https://github.com/hankst69/han_Dev.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_PROJECTS_HANDEV=%MAKER_PROJECTS%\hanDev"
set "_HANDEV_PROJECTS_DIR=%MAKER_PROJECTS_HANDEV%"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HANDEV_PROJECTS_DIR%" "https://github.com/hankst69/hanDev.git" --changeDir
