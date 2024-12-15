@echo off
call "%~dp0\maker_env.bat"
call "%MAKER_SCRIPTS%\validate_gperf.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
echo warning: GPERF is not available - trying to build from sources
call "%MAKER_ROOT%\build_gperf.bat" %*
:Exit
"%MAKER_SCRIPTS%\validate_gperf.bat" %*
