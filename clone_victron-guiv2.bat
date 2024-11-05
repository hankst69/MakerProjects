@rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2
@echo off
call "%~dp0\maker_env.bat"

set "_VICTRON_DIR=%MAKER_PROJECTS%\Victron"
set "_VICTRON_GUIV2_DIR=%_VICTRON_DIR%\gui-v2"
rem if not exist "%_VICTRON_DIR%" mkdir "%_VICTRON_DIR%"

call "%MAKER_SCRIPTS%\clone_in_folder.bat" "%_VICTRON_GUIV2_DIR%" "https://github.com/victronenergy/gui-v2.git" --changeDir
