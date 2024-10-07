@echo off
rem https://de.wikipedia.org/wiki/Chocolatey
rem https://chocolatey.org/
rem https://github.com/chocolatey/choco.git
set "_CHOCO_DIR=%~dp0Choco"
call "%~dp0scripts\clone_in_folder.bat" "%_CHOCO_DIR%" "https://github.com/chocolatey/choco.git" --changeDir %*
