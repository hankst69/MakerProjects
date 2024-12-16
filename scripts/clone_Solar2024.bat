@rem @call "%~dp0scripts\clone_in_folder.bat" "%~dp0projects\Solar2024" "https://github.com/hankst69/Solardach_2024.git" --changeDir
@echo off
call "%~dp0\maker_env.bat"
set "_SOLAR24_DIR=%MAKER_PROJECTS%\Solar2024"
call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_SOLAR24_DIR%" "https://github.com/hankst69/Solardach_2024.git" --changeDir
