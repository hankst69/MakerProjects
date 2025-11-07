@echo off
call "%~dp0core\maker_env.bat" %*
set "CHOCO_DIR=%MAKER_BIN%\.choco"

call "%~dp0core\generic_validate.bat" "CHOCO" "choco --version" "call choco --version" %* >"%CHOCO_DIR%\.validate.txt"
@if %ERRORLEVEL% equ 0 type "%_CHOCO_BIN%\.validate.txt" & goto :EOF

rem set "ChocolateyInstall=C:\ProgramData\chocolatey"
rem set "ChocolateyInstall=%LOCALAPPDATA%\chocolatey"
set "ChocolateyInstall=%CHOCO_DIR%"

call powershell -noprofile -command "$InstallDir='%CHOCO_DIR%'; $env:ChocolateyInstall='$InstallDir';"


