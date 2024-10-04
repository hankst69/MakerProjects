@echo off
set "_MAKER_ROOT=%~dp0"
rem https://de.wikipedia.org/wiki/Chocolatey
rem https://chocolatey.org/
rem https://github.com/chocolatey/choco.git
set "_CHOCO_DIR=%~dp0Choco"
call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_CHOCO_DIR%" "https://github.com/chocolatey/choco.git" --changeDir
