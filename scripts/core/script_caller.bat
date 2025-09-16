@echo off
set "_SCRIPTS_DIR=%~dp0.."
set "_CLASS_NAME=%~1"
set _PROJECT_NAME=
set _PROJECT_ARGS=
set _NO_USAGE=
:param_loop
shift
if /I "%~1" equ "--no_usage" set "_NO_USAGE=true" &goto :param_loop
if "%~1" neq "" if "%_PROJECT_NAME%" equ "" set "_PROJECT_NAME=%~1" &goto :param_loop
if "%~1" neq "" set "_PROJECT_ARGS=%_PROJECT_ARGS% %1" &goto :param_loop
if "%~1" neq "" goto :param_loop

if exist "%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%.bat" goto :CallScript

if "%_NO_USAGE%" neq "" goto :ListMatches
echo USAGE:  %_CLASS_NAME% ^<project_name^> [version]
echo.

if "%_PROJECT_NAME%" neq "" (
  echo project '%_PROJECT_NAME%' could not be found  &rem ^(script "%_CLASS_NAME%_%_PROJECT_NAME%.bat" does not exist^)
  echo.
)

:ListMatches
if "%_PROJECT_NAME%" equ "" echo available projects:
if "%_PROJECT_NAME%" neq "" echo available '%_PROJECT_NAME%*' projects:
SETLOCAL ENABLEEXTENSIONS
SETLOCAL ENABLEDELAYEDEXPANSION
for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%*.bat"') do (
  set "_PROJECT_SCRIPT=%%~nb"
  set "_PROJECT_NAME=!_PROJECT_SCRIPT:%_CLASS_NAME%_=!"
  echo  %_CLASS_NAME% !_PROJECT_NAME!
  set _PROJECT_SCRIPT=
  set _PROJECT_NAME=
)
goto :Exit

:CallScript
call "%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%.bat" %_PROJECT_ARGS%

:Exit
set _SCRIPTS_DIR=
set _CLASS_NAME=
set _PROJECT_NAME=
set _PROJECT_ARGS=
set _NO_USAGE=
