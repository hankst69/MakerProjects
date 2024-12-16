@echo off
set "CLASS_NAME=%~1"
set "BUILD_SCRIPTS=%~dp0.."

if "%~2" equ "" (
  SETLOCAL ENABLEEXTENSIONS
  SETLOCAL ENABLEDELAYEDEXPANSION
  echo USAGE:  %CLASS_NAME% ^<project_name^> [version]
  echo available projects:
  for /f "tokens=*" %%b in ('dir /b "%BUILD_SCRIPTS%\%CLASS_NAME%_*.bat"') do (
    set "_BUILD_SCRIPT=%%~nb"
    set "_BUILD_SCRIPT=!_BUILD_SCRIPT:%CLASS_NAME%_=!"
    echo  %CLASS_NAME% !_BUILD_SCRIPT!
    set _BUILD_SCRIPT=
  )
  goto :Exit
)

shift
set "PROJ_NAME=%~1"
set PROJ_ARGS=
:param_loop
shift
if "%~1" neq "" set "PROJ_ARGS=%PROJ_ARGS% %1"
if "%~1" neq "" goto :param_loop

if not exist "%BUILD_SCRIPTS%\%CLASS_NAME%_%PROJ_NAME%.bat" (
  echo error: unknown project '%PROJ_NAME%' ^("%CLASS_NAME%_%PROJ_NAME%.bat" does not exist^)
  goto :Exit
)

call "%BUILD_SCRIPTS%\%CLASS_NAME%_%PROJ_NAME%.bat" %PROJ_ARGS%

:Exit
set BUILD_SCRIPTS=
set CLASS_NAME=
set PROJ_NAME=
set PROJ_ARGS=
