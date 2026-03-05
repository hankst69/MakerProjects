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

if "%_PROJECT_NAME%" neq "" goto :CallScript

if "%_NO_USAGE%" equ "" call :Usage

if "%_PROJECT_NAME%" neq "" (
  echo project '%_PROJECT_NAME%' could not be found  &rem ^(script "%_CLASS_NAME%_%_PROJECT_NAME%.bat" does not exist^)
  echo.
)
call :ListMatches

:Exit
set _SCRIPTS_DIR=
set _CLASS_NAME=
set _PROJECT_NAME=
set _PROJECT_ARGS=
set _NO_USAGE=
goto :EOF

:Usage
echo USAGE:  %_CLASS_NAME% ^<project_name^> [version]
echo.
goto :EOF

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
goto :EOF


:CallScript
if "%_PROJECT_NAME%" equ "" (
  echo error: project name is undefined
  call :Usage
  goto :Exit
)

rem try to match the given project name with an existing script file
set "_SCRIPT_FILE=%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%.bat"
if exist "%_SCRIPT_FILE%" call "%_SCRIPT_FILE%" %_PROJECT_ARGS%
if exist "%_SCRIPT_FILE%" goto :Exit

rem try to match the given project name with the upper case letters of an existing script file#
SETLOCAL ENABLEEXTENSIONS
setlocal EnableDelayedExpansion
set _PROJECT_SCRIPT=
set _PNAME=
set _PROJECT_ID=
for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_*.bat"') do (
  set "_PROJECT_SCRIPT=%%~nxb"
  set "_PROJECT_=%%~nb"
  set "_PNAME=!_PROJECT_:%_CLASS_NAME%_=!"
  set "_PROJECT_ID=_"
  set "_string=!_PNAME!"
  call :strlen _string _length
  rem echo _string: !_string! ^(!_length!^)
  echo matching '!_string!' with '%_PROJECT_NAME%'
  for /l %%i in (1,1,!_length!) do (  
    set /a _index=%%i-1
    set "_char=%%_string:~!_index!,1%%"
    for /l %%a in (1,1,1) do call set "_charOrig=!_char!"
    for /l %%a in (1,1,1) do call set "_charUpper=!_char!"
    for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set "_charUpper=!_charUpper:%%a=%%a!"
    rem echo _index : !_index!
    rem echo _charOrig: !_charOrig!
    rem echo _charUpper: !_charUpper!
    rem if "!_charOrig!" equ "!_charUpper!" echo adding !_charOrig!
    if "!_charOrig!" equ "!_charUpper!" set "_PROJECT_ID=!_PROJECT_ID!!_charOrig!"
  )
  if /i "!_PROJECT_ID:~1!" equ "%_PROJECT_NAME%" echo "%_SCRIPTS_DIR%\!_PROJECT_SCRIPT!" %_PROJECT_ARGS%
  if /i "!_PROJECT_ID:~1!" equ "%_PROJECT_NAME%" call "%_SCRIPTS_DIR%\!_PROJECT_SCRIPT!" %_PROJECT_ARGS%
  if /i "!_PROJECT_ID:~1!" equ "%_PROJECT_NAME%" goto :Exit
)
call :Usage
goto :Exit

goto :eof
:strlen  StrVar  [RtnVar]
  setlocal EnableDelayedExpansion
  set "s=#!%~1!"
  set "len=0"
  for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%N,1!" neq "" (
      set /a "len+=%%N"
      set "s=!s:~%%N!"
    )
  )
  endlocal&if "%~2" neq "" (set %~2=%len%) else echo %len%
exit /b