@echo off
call "%~dp0\maker_env.bat"
set "SCRIPT_NAME=%~n0"

if "%~1" equ "" (
  SETLOCAL ENABLEEXTENSIONS
  SETLOCAL ENABLEDELAYEDEXPANSION
  echo USAGE:  %SCRIPT_NAME% ^<project_name^> [version]
  echo available projects:
  for /f "tokens=*" %%b in ('dir /b "%MAKER_SCRIPTS%\%SCRIPT_NAME%_*.bat"') do (
    set "_BUILD_SCRIPT=%%~nb"
    set "_BUILD_SCRIPT=!_BUILD_SCRIPT:%SCRIPT_NAME%_=!"
    echo  %SCRIPT_NAME% !_BUILD_SCRIPT!
  )
  set SCRIPT_NAME=
  goto :EOF
)

set "SCRIPT_PROJ=%~1"
set SCRIPT_ARGS=
:param_loop
shift
if "%~1" neq "" set "SCRIPT_ARGS=%SCRIPT_ARGS% %1"
if "%~1" neq "" goto :param_loop

if not exist "%MAKER_SCRIPTS%\%SCRIPT_NAME%_%SCRIPT_PROJ%.bat" (
  echo error: unknown project '%SCRIPT_PROJ%' ^("%SCRIPT_NAME%_%SCRIPT_PROJ%.bat" does not exist^)
  goto :Exit
)

call "%MAKER_SCRIPTS%\%SCRIPT_NAME%_%SCRIPT_PROJ%.bat" %SCRIPT_ARGS%

:Exit
set SCRIPT_NAME=
set SCRIPT_PROJ=
set SCRIPT_ARGS=
