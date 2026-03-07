@echo off
VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 (echo shell extensions not available - unable to run the script %0 properly &goto :EOF)
ENDLOCAL

set __PROJECT=
set __SCRIPT_NAME=
set __SCRIPT_FILE=
setlocal EnableExtensions EnableDelayedExpansion

set "_SCRIPTS_DIR=%~dp0.."
set _PROJECT_NAME=
set _PROJECT_ARGS=
set _NO_USAGE=
set "_CLASS_NAME=%~1"
:param_loop
shift
if /I "%~1" equ "--no_usage" set "_NO_USAGE=true" &goto :param_loop
if "%~1" neq "" if "%__PROJECT%" equ "" set "__PROJECT=%~1" &goto :param_loop
if "%~1" neq "" set "_PROJECT_ARGS=!_PROJECT_ARGS! %1" &goto :param_loop
if "%~1" neq "" goto :param_loop

if "%__PROJECT%" equ "" (
  rem no project identifier specified
  if "%_NO_USAGE%" equ "" call :Usage
  call :ListMatches
  endlocal
  goto :Exit
)

call "%~dp0\maker_env.bat"
set "_SCRIPTS_SHORTCUTS=%MAKER_BIN%\shortcuts_%_CLASS_NAME%_scripts.dat"
rem set _SCRIPTS_SHORTCUTS
rem if exist "%_SCRIPTS_SHORTCUTS%" del /Q /F "%_SCRIPTS_SHORTCUTS%"


:FindExactMatch
rem (1) see if there exists a script file that exactly matches the given PROJECT name
set "__SCRIPT_NAME=%_CLASS_NAME% %__PROJECT%"
set "__SCRIPT_FILE=%_SCRIPTS_DIR%\%__SCRIPT_NAME%.bat"
if exist "%__SCRIPT_FILE%" (
  endlocal
  echo %__SCRIPT_NAME:_= %
  call "%__SCRIPT_FILE%" %_PROJECT_ARGS%
  goto :Exit
)

:FindSingleMatch
rem (2) see if there exists exactly one script file with given PROJECT as the start of script name
set __SCRIPT_NAME=
set __SCRIPT_FILE=
set _found_matches=0
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_%__PROJECT%*.bat" 2^>nul') do set /a _found_matches=!_found_matches!+1
if "!_found_matches!" neq "1" goto :FindShortcutMatch
rem we found a single script match - so we call this one
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_%__PROJECT%*.bat" 2^>nul') do set "__SCRIPT_FILE=%_SCRIPTS_DIR%\%%~nxf" &set "__SCRIPT_NAME=%%~nf"
if exist "%__SCRIPT_FILE%" (
  endlocal
  echo %__SCRIPT_NAME:_= %
  call "%__SCRIPT_FILE%" %_PROJECT_ARGS%
  goto :Exit
)

:FindShortcutMatch
rem (3) try to match the given PROJECT with the upper case letters of an existing script file aka PROJECT_ID
set __SCRIPT_NAME=
set __SCRIPT_FILE=
rem show available projects matching given project name
call :ListMatches "%__PROJECT%"
rem show all available projects
call :ListMatches ""
rem build shortcuts frommexisting script names and see if there is a match
set "_shortcut=%__PROJECT%"
for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set "_shortcut=!_shortcut:%%a=%%a!"
echo|set /p="search projects matching shortcut '!_shortcut!' "
set _PROJECT_SCRIPT=
set _PNAME=
set _PROJECT_ID=
set __SCRIPT_NAME=
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_*.bat"') do (
  if "!__SCRIPT_NAME!" equ "" (
    set "_PROJECT_=%%~nf"
    set "_PNAME=!_PROJECT_:%_CLASS_NAME%_=!"
    set "_PROJECT_ID=_"
    set "_string=!_PNAME!"
    call :strlen _string _length
    rem echo _string: !_string! ^(!_length!^)
    for /l %%i in (1,1,!_length!) do (  
      set /a _index=%%i-1
      set "_char=%%_string:~!_index!,1%%"
      for /l %%a in (1,1,1) do call set "_charOrig=!_char!"
      for /l %%a in (1,1,1) do call set "_charUpper=!_char!"
      for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set "_charUpper=!_charUpper:%%a=%%a!"
      for %%a in (- _) do call set "_charUpper=!_charUpper:%%a=*!"
      rem echo _index : !_index!
      rem echo _charOrig: !_charOrig!
      rem echo _charUpper: !_charUpper!
      if "!_charOrig!" equ "!_charUpper!" set "_PROJECT_ID=!_PROJECT_ID!!_charOrig!"
    )
    echo|set /p="."
    if /i "!_PROJECT_ID:~1!" equ "%__PROJECT%" set "__SCRIPT_NAME=%%~nf" &set "_PROJECT_SCRIPT=%%~nxf"
    rem echo.!_PROJECT_ID:~1!#%%~nf>>"%_SCRIPTS_SHORTCUTS%"
  )
)
echo.
set "__SCRIPT_FILE=%_SCRIPTS_DIR%\%__SCRIPT_NAME%.bat"
if exist "%__SCRIPT_FILE%" (
  endlocal
  echo %__SCRIPT_NAME:_= %
  call "%__SCRIPT_FILE%" %_PROJECT_ARGS%
  goto :Exit
)

rem (4) no matches for given __PROJECT found
endlocal
echo no matching project found
echo.
:Exit
set __PROJECT=
set __SCRIPT_NAME=
set __SCRIPT_FILE=
goto :EOF


:Usage
echo USAGE:  %_CLASS_NAME% ^<project_name^> [version]
echo.
goto :EOF


:ListMatches
set "_project=%~1"
set "_pattern=%_CLASS_NAME%_!_project!*.bat"
set _found_matches=
if "!_project!" neq "" for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\!_pattern!" 2^>nul') do set _found_matches=true
if "!_project!" neq "" if "!_found_matches!" equ "" (goto :EOF)
if "!_found_matches!" neq "" (
  echo matching projects for '!_project!':
) else (
  set "_pattern=%_CLASS_NAME%_*.bat"
  echo available projects:
)
for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\!_pattern!" 2^>nul') do (
  set "_project_script_name=%%~nb"
  set "_project_name=!_project_script_name:%_CLASS_NAME%_=!"
  echo  %_CLASS_NAME% !_project_name!
)
goto :EOF


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