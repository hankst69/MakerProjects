@echo off
rem echo *** GENERIC_ENSURE "%*" ***
set "_GENERIC_ENSURE_STARTDIR=%~dp0"
if "%_GENERIC_ENSURE_STARTDIR:~-1%" equ "\" set "_GENERIC_ENSURE_STARTDIR=%_GENERIC_ENSURE_STARTDIR:~0,-1%"

set "_GENERIC_ENSURE_NAME=%~1"
set _GENERIC_ENSURE_ARGS=
:param_loop
shift
if "%~1" neq "" set "_GENERIC_ENSURE_ARGS=%_GENERIC_ENSURE_ARGS% %1"
if "%~1" neq "" goto :param_loop
call "%_GENERIC_ENSURE_STARTDIR%\maker_env.bat" %_GENERIC_ENSURE_ARGS%
if "%MAKER_ENV_VERBOSE%" neq "" set _GENERIC_ENSURE


:ge_main
set ERRORLEVEL=
call :ge_validate "%_GENERIC_ENSURE_NAME%" "%_GENERIC_ENSURE_ARGS%"
if %ERRORLEVEL% EQU 0 goto :ge_exit
rem echo call :ge_build %*
call :ge_build  "%_GENERIC_ENSURE_NAME%" "%_GENERIC_ENSURE_ARGS%"
if %ERRORLEVEL% EQU 0 goto :ge_exit

exit /b %ERRORLEVEL%
:ge_exit
set _GENERIC_ENSURE_STARTDIR=
set _GENERIC_ENSURE_NAME=
set _GENERIC_ENSURE_ARGS=
goto :EOF


:ge_validate
set "_PROJ_NAME=%~1"
set "_PROJ_ARGS=%~2"
rem echo %ERRORLEVEL%
if "%MAKER_ENV_VERBOSE%" neq "" echo "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS%
rem echo %ERRORLEVEL%
call "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS% 1>nul 2>nul
rem echo %ERRORLEVEL%
if %ERRORLEVEL% EQU 0 call "%MAKER_BUILD%\validate_%_PROJ_NAME%.bat" %_PROJ_ARGS%
rem echo %ERRORLEVEL%
goto :EOF


:ge_build
set "_PROJ_NAME=%~1"
set "_PROJ_ARGS=%~2"
if "%MAKER_ENV_NOWARNINGS%" equ "" echo warning: %_PROJ_NAME% %MAKER_ENV_VERSION% is not available - trying to build from sources
if "%MAKER_ENV_VERBOSE%" neq "" echo "%MAKER_BUILD%\build_%_PROJ_NAME%.bat" %_PROJ_ARGS%
call "%MAKER_BUILD%\build_%_PROJ_NAME%.bat" %_PROJ_ARGS%
rem echo %ERRORLEVEL%
goto :EOF
