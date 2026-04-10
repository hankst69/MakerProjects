@rem https://github.com/hankst69/han_Dev.git
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_DIR_PROJECTS_HANDEV=%MAKER_DIR_PROJECTS%\han_Dev"
set "_HAN_DEV_DIR=%MAKER_DIR_PROJECTS_HANDEV%"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_HAN_DEV_DIR%" "https://github.com/hankst69/han_Dev.git" --changeDir
