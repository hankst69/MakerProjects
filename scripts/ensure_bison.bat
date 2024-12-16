@echo off
call "%~dp0\maker_env.bat"
call "%MAKER_SCRIPTS%\validate_bison.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
echo warning: BISON is not available - trying to build from sources
call "%MAKER_ROOT%\build_bison.bat" %*
:Exit
call "%MAKER_SCRIPTS%\validate_bison.bat" %*
