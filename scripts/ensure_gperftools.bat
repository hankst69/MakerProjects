@echo off
call "%~dp0\maker_env.bat"
call "%MAKER_SCRIPTS%\validate_gperftools.bat" %* 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
echo warning: GPERFTOOLS is not available - trying to build from sources
call "%MAKER_ROOT%\build_gperftools.bat" %*
:Exit
call "%MAKER_SCRIPTS%\validate_gperftools.bat" %*
