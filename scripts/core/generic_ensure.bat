@echo off
set "__CURRENT_DIR__=%cd%"
set "__START_DIR__=%~dp0"
set "PROJ_NAME=%~1"
set PROJ_ARGS=
:param_loop
shift
if "%~1" neq "" set "PROJ_ARGS=%PROJ_ARGS% %1"
if "%~1" neq "" goto :param_loop
call "%__START_DIR__%\maker_env.bat" %PROJ_ARGS%
set __START_DIR__=

call "%MAKER_BUILD%\validate_%PROJ_NAME%.bat" %PROJ_ARGS% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
echo warning: %PROJ_NAME% is not available - trying to build from sources
if "%MAKER_ENV_VERBOSE%" neq "" echo on
call "%MAKER_BUILD%\build_%PROJ_NAME%.bat" %PROJ_ARGS%
:Exit
if "%MAKER_ENV_VERBOSE%" neq "" echo on
call "%MAKER_BUILD%\validate_%PROJ_NAME%.bat" %PROJ_ARGS%
cd /d "%__CURRENT_DIR__%"
set __CURRENT_DIR__=
