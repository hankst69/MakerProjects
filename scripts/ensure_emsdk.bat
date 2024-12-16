@echo off
set "MAKER_BUILD=%~dp0"
call "%MAKER_BUILD%\validate_emsdk.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
echo warning: EMSDK is not available - trying to build from sources
call "%MAKER_BUILD%\build_emsdk.bat" %*
:Exit
call "%MAKER_BUILD%\validate_emsdk.bat" %*
