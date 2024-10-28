@rem https://github.com/victronenergy/gui-v2/wiki/How-to-build-venus-gui-v2
@echo off
set "_MAKER_ROOT=%~dp0"
set "_VICTRON_DIR=%_MAKER_ROOT%projects\Victron"
set "_VICTRON_GUIV2_DIR=%_VICTRON_DIR%\gui-v2"
rem if not exist "%_VICTRON_DIR%" mkdir "%_VICTRON_DIR%"

call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_VICTRON_GUIV2_DIR%" "https://github.com/victronenergy/gui-v2.git" --changeDir
