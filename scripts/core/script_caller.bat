@echo off
VERIFY OTHER 2>nul
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 (echo shell extensions not available - unable to run the script %0 properly &goto :EOF)
ENDLOCAL

set __CLASS_NAME=
set __PROJECT=
set __PROJECT_ARGS=
set __SCRIPT_NAME=
set __SCRIPT_FILE=
set __NO_USAGE=
setlocal EnableExtensions EnableDelayedExpansion
rem set __PROJECT=.
rem set __PROJECT_ARGS=
rem set __SCRIPT_NAME=.
rem set __SCRIPT_FILE=.
rem set __NO_USAGE=

set "_SCRIPTS_DIR=%~dp0.."
set "__CLASS_NAME=%~1"
:param_loop
shift
if /I "%~1" equ "--no_usage" set "__NO_USAGE=true" &goto :param_loop
if "%~1" neq "" if "%__PROJECT%" equ "" set "__PROJECT=%~1" &goto :param_loop
if "%~1" neq "" set "__PROJECT_ARGS=%__PROJECT_ARGS% %1" &goto :param_loop
if "%~1" neq "" goto :param_loop

if "%__PROJECT%" equ "" (
  rem no project identifier specified
  if "%__NO_USAGE%" equ "" call :Usage
  call :ListMatches
  endlocal
  goto :Exit
)


:RefreshShortcutIndex
set "_SCRIPTS_SHORTCUTS_FILE=%_SCRIPTS_DIR%\shortcuts_%__CLASS_NAME%_scripts.dat"
call :InvalidateShortcutsIndex "%__CLASS_NAME%" "%_SCRIPTS_DIR%" "%_SCRIPTS_SHORTCUTS_FILE%"
if not exist "%_SCRIPTS_SHORTCUTS_FILE%" call :UpdateShortcutsIndex "%__CLASS_NAME%" "%_SCRIPTS_DIR%" "%_SCRIPTS_SHORTCUTS_FILE%"


:FindExactMatch
rem (1) see if there exists a script file that exactly matches the given PROJECT name
set "__SCRIPT_NAME=%__CLASS_NAME%_%__PROJECT%"
set "__SCRIPT_FILE=%_SCRIPTS_DIR%\%__SCRIPT_NAME%.bat"
for /f "tokens=*" %%f in ('dir /b "%__SCRIPT_FILE%" 2^>nul') do set "__SCRIPT_NAME=%%~nf"
rem if exist "%__SCRIPT_FILE%" goto :StartScript
if exist "%__SCRIPT_FILE%" (
  echo %__CLASS_NAME% !__SCRIPT_NAME:%__CLASS_NAME%_=!
  endlocal
  call "%__SCRIPT_FILE%" %__PROJECT_ARGS%
  goto :Exit
)


:FindSingleMatch
rem (2) see if there exists exactly one script file with given PROJECT as the start of script name
set __SCRIPT_NAME=
set __SCRIPT_FILE=
set _found_matches=0
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%__CLASS_NAME%_%__PROJECT%*.bat" 2^>nul') do set /a _found_matches=!_found_matches!+1
if !_found_matches! gtr 1 (
  rem there are matches - show them to the user
  call :ListMatches "%__PROJECT%"
)
if !_found_matches! neq 1 goto :FindShortcutMatch
rem we found a single script match - so we call this one
for /f "tokens=*" %%f in ('dir /b "%_SCRIPTS_DIR%\%__CLASS_NAME%_%__PROJECT%*.bat" 2^>nul') do set "__SCRIPT_FILE=%_SCRIPTS_DIR%\%%~nxf" &set "__SCRIPT_NAME=%%~nf"
rem if exist "%__SCRIPT_FILE%" goto :StartScript
if exist "%__SCRIPT_FILE%" (
  echo %__CLASS_NAME% !__SCRIPT_NAME:%__CLASS_NAME%_=!
  endlocal
  call "%__SCRIPT_FILE%" %__PROJECT_ARGS%
  goto :Exit
)


:FindShortcutMatch
rem (3) try to match the given PROJECT with the upper case letters of an existing script file aka PROJECT_ID
set __SCRIPT_NAME=
set __SCRIPT_FILE=
call :FindShortcut "%__CLASS_NAME%" "%_SCRIPTS_DIR%" "%_SCRIPTS_SHORTCUTS_FILE%" "%__PROJECT%"
rem if exist "%__SCRIPT_FILE%" goto :StartScript
if exist "%__SCRIPT_FILE%" (
  echo %__CLASS_NAME% !__SCRIPT_NAME:%__CLASS_NAME%_=!
  endlocal
  call "%__SCRIPT_FILE%" %__PROJECT_ARGS%
  goto :Exit
)


rem (4) no matches for given __PROJECT found
echo no matching project found
rem show all available projects
call :ListMatches ""
endlocal
goto :Exit

:Exit
rem goto :EOF
set __CLASS_NAME=
set __PROJECT=
set __PROJECT_ARGS=
set __SCRIPT_NAME=
set __SCRIPT_FILE=
set __NO_USAGE=
goto :EOF



:Usage
echo USAGE:  %__CLASS_NAME% ^<project_name^> [version]
echo.
goto :EOF


:FindShortcut
rem validate if index is still valid
rem :FindShortcut "%__CLASS_NAME%" "%_SCRIPTS_DIR%" "%_SCRIPTS_SHORTCUTS_FILE%" "%__PROJECT%"
set "class_name=%~1"
set "scripts_dir=%~2"
set "shortcuts_file=%~3"
set "project=%~4"
set __SCRIPT_NAME=
set __SCRIPT_FILE=
rem if not exist "%shortcuts_file%" goto :EOF
if not exist "%shortcuts_file%" call :UpdateShortcutsIndex "%class_name%" "%scripts_dir%" "%shortcuts_file%"
rem search for match
for /f "tokens=1,2,3 delims=#" %%i in (%shortcuts_file%) do (
  if "%__SCRIPT_NAME%" equ "" ( 
    rem echo. SCRIPT:"%%i" EXT:"%%j" ID:"%%k"
    rem echo. "%project%" equ "%%k"
    if /I "%project%" equ "%%k" (
      set "__SCRIPT_NAME=%%~ni"
      set "__SCRIPT_FILE=%scripts_dir%\%%~ni%%~xj"
      rem set __SCRIPT_
    )
  )
  if "%__SCRIPT_FILE%" neq "" if not exist "%__SCRIPT_FILE%" set __SCRIPT_NAME=
)
goto :EOF


:InvalidateShortcutsIndex
rem validate if index is still valid
rem :InvalidateShortcutsIndex "%__CLASS_NAME%" "%_SCRIPTS_DIR%" "%_SCRIPTS_SHORTCUTS_FILE%"
set "class_name=%~1"
set "scripts_dir=%~2"
set "shortcuts_file=%~3"
set "shortcuts_name=%~nx3"
set _newer_file=
if not exist "%shortcuts_file%" goto :EOF
pushd "%scripts_dir%"
for %%f in (%class_name%_*.bat) do (
  FOR /F %%i IN ('DIR /B /O:D "%%~nxf" "%shortcuts_name%"') DO SET "_newer_file=%%~nxi"
  if /I "!_newer_file!" neq "%shortcuts_name%" (
    echo index "%shortcuts_name%" is outdated ^("!_newer_file!" is newer^)
    del /f /q "%shortcuts_file%"
    popd
    goto :EOF
  )
)
popd
goto :EOF


:UpdateShortcutsIndex
rem build shortcuts from existing script names
rem :UpdateShortcutsIndex "%__CLASS_NAME%" "%_SCRIPTS_DIR%" "%_SCRIPTS_SHORTCUTS_FILE%"
set "class_name=%~1"
set "scripts_dir=%~2"
set "shortcuts_file=%~3"
set _PROJECT=
set _PNAME=
set _PROJECT_ID=
set _SCRIPT_NAME=
rem echo|set /p="updating project %class_name% shortcuts"
echo|set /p="updating project shortcuts"
for /f "tokens=*" %%f in ('dir /b "%scripts_dir%\%class_name%_*.bat"') do (
  set "_PROJECT_=%%~nf"
  set "_PNAME=!_PROJECT_:%class_name%_=!"
  set "_PROJECT_ID=_"
  set "_string=!_PNAME!"
  call :strlen _string _length
  for /l %%i in (1,1,!_length!) do (  
    set /a _index=%%i-1
    set "_char=%%_string:~!_index!,1%%"
    for /l %%a in (1,1,1) do call set "_charOrig=!_char!"
    for /l %%a in (1,1,1) do call set "_charUpper=!_char!"
    for %%a in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do call set "_charUpper=!_charUpper:%%a=%%a!"
    for %%a in (- _ 0 1 2 3 4 5 6 7 8 9) do call set "_charUpper=!_charUpper:%%a=*!"
    if "!_charOrig!" equ "!_charUpper!" set "_PROJECT_ID=!_PROJECT_ID!!_charOrig!"
  )
  echo|set /p="."
  echo.%%~nf#%%~xf##!_PROJECT_ID:~1!#>>"%_SCRIPTS_SHORTCUTS_FILE%"
)
echo.
goto :EOF


:ListMatches
set "_project=%~1"
set "_pattern=%__CLASS_NAME%_!_project!*.bat"
set _found_matches=
if "!_project!" neq "" for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\!_pattern!" 2^>nul') do set _found_matches=true
if "!_project!" neq "" if "!_found_matches!" equ "" (goto :EOF)
if "!_found_matches!" neq "" (
  echo matching projects for '!_project!':
) else (
  set "_pattern=%__CLASS_NAME%_*.bat"
  echo available projects:
)
for /f "tokens=*" %%b in ('dir /b "%_SCRIPTS_DIR%\!_pattern!" 2^>nul') do (
  set "_project_script_name=%%~nb"
  set "_project_name=!_project_script_name:%__CLASS_NAME%_=!"
  echo  %__CLASS_NAME% !_project_name!
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