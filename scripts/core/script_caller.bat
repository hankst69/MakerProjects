@echo off
set "_SCRIPTS_DIR=%~dp0.."
set "_CLASS_NAME=%~1"

if "%~2" equ "" (
  SETLOCAL ENABLEEXTENSIONS
  SETLOCAL ENABLEDELAYEDEXPANSION
  echo USAGE:  %_CLASS_NAME% ^<project_name^> [version]
  echo available projects:
  for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_*.bat"') do (
    set "_PROJECT_SCRIPT=%%~nb"
    set "_PROJECT_NAME=!_PROJECT_SCRIPT:%_CLASS_NAME%_=!"
    echo  %_CLASS_NAME% !_PROJECT_NAME!
    set _PROJECT_SCRIPT=
    set _PROJECT_NAME=
  )
  goto :Exit
)

shift
set "_PROJECT_NAME=%~1"
set  _PROJECT_ARGS=
:param_loop
shift
if "%~1" neq "" set "_PROJECT_ARGS=%_PROJECT_ARGS% %1"
if "%~1" neq "" goto :param_loop

if not exist "%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%.bat" (
  echo error: unknown project '%_PROJECT_NAME%' ^("%_CLASS_NAME%_%_PROJECT_NAME%.bat" does not exist^)
  goto :Exit
)

call "%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%.bat" %_PROJECT_ARGS%

:Exit
set _SCRIPTS_DIR=
set _CLASS_NAME=
set _PROJECT_NAME=
set _PROJECT_ARGS=
