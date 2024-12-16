@echo off
set "MAKER_BUILD=%~dp0"
call "%MAKER_BUILD%\validate_gperftools.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
echo warning: GPERFTOOLS is not available - trying to build from sources
call "%MAKER_BUILD%\build_gperftools.bat" %*
:Exit
call "%MAKER_BUILD%\validate_gperftools.bat" %*
