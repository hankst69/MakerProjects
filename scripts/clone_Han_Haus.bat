@echo off
call "%~dp0\maker_env.bat"

set "MAKER_DIR_PROJECTS_HANHAUS=%MAKER_DIR_PROJECTS%\han_Haus"
set "_HAN_HAUS_DIR=%MAKER_DIR_PROJECTS_HANHAUS%"

call "%MAKER_ENV_CORE%\clone_in_folder.bat" "%_HAN_HAUS_DIR%" "https://github.com/hankst69/han_Haus.git" --changeDir
