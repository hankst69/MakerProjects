@echo off
set "_MAKER_ROOT=%~dp0"
rem https://de.wikipedia.org/wiki/Chocolatey
rem https://chocolatey.org/
rem https://github.com/chocolatey/choco.git

set "_CHOCO_DIR=%~dp0Choco"
if not exist "%_CHOCO_DIR%" mkdir "%_CHOCO_DIR%"

set "_CHOCO_SOURCES_DIR=%_CHOCO_DIR%\Sources\"

call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_CHOCO_SOURCES_DIR%" "https://github.com/chocolatey/choco.git" --changeDir