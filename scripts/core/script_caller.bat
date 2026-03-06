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

if "%_PROJECT_NAME%" neq "" goto :FindAndCallScript

:NoMatchingProject
rem no project identifier specified
if "%_NO_USAGE%" equ "" call :Usage
call :ListMatches
goto :Exit


:FindAndCallScript
rem try to match the given project name with an existing script file based on full project name
set "_SCRIPT_FILE=%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%.bat"
if exist "%_SCRIPT_FILE%" echo %_CLASS_NAME% %_PROJECT_NAME%
if exist "%_SCRIPT_FILE%" call "%_SCRIPT_FILE%" %_PROJECT_ARGS%
if exist "%_SCRIPT_FILE%" goto :Exit

rem try to match the given project name with an existing script file based on project name as the start of script name
rem this requires to have only 1 match
set _SCRIPT_NAME=
setlocal EnableExtensions
setlocal EnableDelayedExpansion
set _found_matches=0
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%*.bat" 2^>nul') do set /a _found_matches=!_found_matches!+1
rem echo !_found_matches!
if "!_found_matches!" neq "1" goto :FindShortcutMatch
rem we found a single script match - so we call this one
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_%_PROJECT_NAME%*.bat" 2^>nul') do set "_SCRIPT_FILE=%_SCRIPTS_DIR%\%%~nxf" &set "_SCRIPT_NAME=%%~nf"
if exist "%_SCRIPT_FILE%" (
  endlocal
  endlocal
  echo %_SCRIPT_NAME:_= %
  call "%_SCRIPT_FILE%" %_PROJECT_ARGS%
  goto :Exit
)

:FindShortcutMatch
rem show available projects matching given project name
call :ListMatches "%_PROJECT_NAME%"

rem try to match the given project name with the upper case letters of an existing script file#
call :ListMatches ""
set "_shortcut=%_PROJECT_NAME%"
for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set "_shortcut=!_shortcut:%%a=%%a!"
echo|set /p="search projects matching shortcut '!_shortcut!' "
set _PROJECT_SCRIPT=
set _PNAME=
set _PROJECT_ID=
set _SCRIPT_NAME=
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%_CLASS_NAME%_*.bat"') do (
  if "!_SCRIPT_NAME!" equ "" (
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
    if /i "!_PROJECT_ID:~1!" equ "%_PROJECT_NAME%" set "_SCRIPT_NAME=%%~nf"
    if /i "!_PROJECT_ID:~1!" equ "%_PROJECT_NAME%" set "_PROJECT_SCRIPT=%%~nxf"
  )
)
echo.
if "%_SCRIPT_NAME%" neq "" (
  echo %_SCRIPT_NAME:_= %
  endlocal
  endlocal
  call "%_SCRIPTS_DIR%\%_PROJECT_SCRIPT%" %_PROJECT_ARGS%
  goto :Exit
)
endlocal
endlocal
echo no matching project found
echo.
goto :Exit

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
setlocal EnableExtensions
setlocal EnableDelayedExpansion
set "_project=%~1"
set "_pattern=%_CLASS_NAME%_!_project!*.bat"
set _found_matches=
if "!_project!" neq "" for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\!_pattern!" 2^>nul') do set _found_matches=true
if "!_project!" neq "" if "!_found_matches!" equ "" (endlocal &goto :EOF)
if "!_found_matches!" neq "" (
  echo matching projects for '!_project!':
) else (
  set "_pattern=%_CLASS_NAME%_*.bat"
  echo available projects:
)
for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\!_pattern!" 2^>nul') do (
  set "_PSCRIPT=%%~nb"
  set "_PNAME=!_PSCRIPT:%_CLASS_NAME%_=!"
  echo  %_CLASS_NAME% !_PNAME!
)
endlocal
endlocal
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