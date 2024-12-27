@call "%~dp0core\generic_validate.bat" "CHOCO" "choco --version" "call choco --version" %*

@echo off
call "%~dp0core\maker_env.bat" %*
set "_CHOCO_BIN=%MAKER_BIN%\.choco"
if exist "%ChocolateyInstall%\choco.exe" set "_CHOCO_BIN=%ChocolateyInstall%"

