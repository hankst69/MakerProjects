@rem @call "%~dp0scripts\clone_in_folder.bat" "%~dp0projects\Solar2024" "https://github.com/hankst69/Solardach_2024.git" --changeDir
@echo off
call "%~dp0\maker_env.bat"

set "MAKER_PROJECTS_HANSOLAR=%MAKER_PROJECTS%\han_Solar"
set "_HAN_SOLAR_DIR=%MAKER_PROJECTS_HANSOLAR%"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_HAN_SOLAR_DIR%" "https://github.com/hankst69/han_Solar.git" --changeDir
