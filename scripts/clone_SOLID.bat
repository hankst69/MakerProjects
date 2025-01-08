@rem "https://github.com/hankst69/SOLID"
@echo off
call "%~dp0\maker_env.bat"

rem set "_SOLID_DIR=%MAKER_PROJECTS%\CSharp\SOLID"
rem set "_SOLID_DIR=%MAKER_PROJECTS%\cs\SOLID"
set "_SOLID_DIR=%MAKER_PROJECTS%\Net\SOLID"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_SOLID_DIR%" "https://github.com/hankst69/SOLID.git" --changeDir
