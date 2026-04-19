@echo off
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem https://stackoverflow.com/questions/11916823/batch-limitation-maximum-recursion-while-browsing-menus
rem SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set "GITREPOS_SCRIPT=%~dpnx0"
set "GITREPOS_SCRIPT_DIR=%~dp0"
set "GITREPOS_SCRIPT_NAME=%~n0"
set "GITREPOS_START_DIR=%cd%"

set GITREPOS_COMPACT=
set GITREPOS_VERBOSE=
set GITREPOS_DIFF=
set GITREPOS_FAST=

set GITREPOS_DIR=
set GITREPOS_STATUS=
set GITREPOS_PULL=
set GITREPOS_LIST_REMOTES=--remotes
set GITREPOS_LIST_BRANCHES=
set GITREPOS_CHECKOUT_BRANCHES=
:param_loop
if /I "%~1" equ "--help"    (goto :Usage)
if /I "%~1" equ "-h"        (goto :Usage)
if /I "%~1" equ "-?"        (goto :Usage)
if /I "%~1" equ "--dir"     (if "%~2" equ "" (echo ERROR: missing ^<path^> parameter&goto :Usage) &set "GITREPOS_DIR=%~2" &shift &shift &goto :param_loop)
if /I "%~1" equ "-d"        (if "%~2" equ "" (echo ERROR: missing ^<path^> parameter&goto :Usage) &set "GITREPOS_DIR=%~2" &shift &shift &goto :param_loop)
if /I "%~1" equ "--pull"    (set "GITREPOS_PULL=--pull" &shift &goto :param_loop)
if /I "%~1" equ "-p"        (set "GITREPOS_PULL=--pull" &shift &goto :param_loop)
if /I "%~1" equ "--status"  (set "GITREPOS_STATUS=--status" &shift &goto :param_loop)
if /I "%~1" equ "-s"        (set "GITREPOS_STATUS=--status" &shift &goto :param_loop)
if /I "%~1" equ "--compact" (set "GITREPOS_COMPACT=--compact" &shift &goto :param_loop)
if /I "%~1" equ "-c"        (set "GITREPOS_COMPACT=--compact" &shift &goto :param_loop)
if /I "%~1" equ "--verbose" (set "GITREPOS_VERBOSE=--verbose" &shift &goto :param_loop)
if /I "%~1" equ "-v"        (set "GITREPOS_VERBOSE=--verbose" &shift &goto :param_loop)
if /I "%~1" equ "--fast"    (set "GITREPOS_FAST=--fast" &shift &goto :param_loop)
if /I "%~1" equ "-f"        (set "GITREPOS_FAST=--fast" &shift &goto :param_loop)
if /I "%~1" equ "--diff"    (set "GITREPOS_DIFF=--diff" &shift &goto :param_loop)
if /I "%~1" equ "-diff"     (set "GITREPOS_DIFF=--diff" &shift &goto :param_loop)
if /I "%~1" equ "-di"       (set "GITREPOS_DIFF=--diff" &shift &goto :param_loop)
if /I "%~1" equ "--list_branches"     (set "GITREPOS_LIST_BRANCHES=--list_branches" &shift &goto :param_loop)
if /I "%~1" equ "-lb"                 (set "GITREPOS_LIST_BRANCHES=--list_branches" &shift &goto :param_loop)
if /I "%~1" equ "--checkout_branches" (set "GITREPOS_CHECKOUT_BRANCHES=--checkout_branches" &shift &goto :param_loop)
if /I "%~1" equ "-cb"                 (set "GITREPOS_CHECKOUT_BRANCHES=--checkout_branches" &shift &goto :param_loop)
if "%~1" neq "" if "%GITREPOS_DIR%" equ "" (set "GITREPOS_DIR=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo warning: unexpected argument '%~1'&shift &goto :param_loop)
if "%GITREPOS_DIR%" equ "" set "GITREPOS_DIR=%cd%"
pushd "%GITREPOS_DIR%"
set "GITREPOS_DIR=%cd%"
popd

if "%GITREPOS_VERBOSE%" neq "" for /f "tokens=1,* delims==" %%s in ('set GITREPOS_') do @echo.%%s="%%t"
if "%GITREPOS_DIFF%" neq "" goto :Diff
goto :MainBegin



:MainBegin
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
call "%GITREPOS_SCRIPT_DIR%\stop_watch.bat"
set "GITREPOS_DATE_START=%_DATE_%"
set "GITREPOS_TIME_START=%_TIME_%"

rem count git repos and analyse maximum path length for most compact dump
set GITREPOS_COUNT=0
set GITREPOS_MAXLENGTH_ABS=0
set GITREPOS_MAXLENGTH_REL=0
if exist "%GITREPOS_DIR%\.git\*" (
  set GITREPOS_COUNT=1
  for /f %%d in ('dir /AD /b "%GITREPOS_DIR%"') do (
    for /f %%g in ('dir /s /AD /b "%%~d"') do if /i "%%~xg" equ ".git" goto :Analyze
  )
  goto :MainDump
)
:Analyze
if "%GITREPOS_FAST%" neq "" (
  set GITREPOS_COUNT=99
  set GITREPOS_MAXLENGTH_ABS=70
  set GITREPOS_MAXLENGTH_REL=51
  goto :MainDump
) 
echo|set /p="searching git repositories in "%GITREPOS_DIR%" ."
pushd "%GITREPOS_DIR%"
for /f %%d in ('dir /s /AD /b') do if /i "%%~xd" equ ".git" (
  if "%GITREPOS_VERBOSE%" neq "" echo "%%~dpnd" 
  echo|set /p="."
  set /a GITREPOS_COUNT=!GITREPOS_COUNT!+1
  set "_string=%%~dpnd"
  call :strlen _string _strlen
  if !_strlen! gtr !GITREPOS_MAXLENGTH_ABS! set GITREPOS_MAXLENGTH_ABS=!_strlen!
  set "_string=!_string:%GITREPOS_DIR%=.!"
  if "%GITREPOS_VERBOSE%" neq "" echo "!_string!"
  call :strlen _string _strlen
  if !_strlen! gtr !GITREPOS_MAXLENGTH_REL! set GITREPOS_MAXLENGTH_REL=!_strlen!
)
popd
echo.

:MainDump
if "%GITREPOS_VERBOSE%" neq "" set GITREPOS_COUNT
if "%GITREPOS_VERBOSE%" neq "" set GITREPOS_MAXLENGTH
if %GITREPOS_COUNT% equ 0 echo no git repositories found &goto MainBEnd
if %GITREPOS_COUNT% equ 1 (
  set GITREPOS_COMPACT=
  set GITREPOS_MAXLENGTH_ABS=-2
  set GITREPOS_MAXLENGTH_REL=-2
)
if "%GITREPOS_COMPACT%" neq "" echo."%GITREPOS_DIR%":
pushd "%GITREPOS_DIR%"
for /f %%d in ('dir /s /AD /b') do if /i "%%~xd" equ ".git" call :Dump_Git_Repo "%%~dpnd" "%GITREPOS_COUNT%" "%GITREPOS_MAXLENGTH_ABS%" "%GITREPOS_MAXLENGTH_REL%"
popd

:MainBEnd
call "%GITREPOS_SCRIPT_DIR%\stop_watch" "%GITREPOS_TIME_START%"
set "GITREPOS_DATE_STOP=%_DATE_%"
set "GITREPOS_TIME_STOP=%_TIME_%"
if %GITREPOS_COUNT% gtr 1 (
  echo %GITREPOS_DATE_START% %GITREPOS_TIME_START%...%GITREPOS_TIME_STOP% ^(duration %_DIFFT_DUR_SS% sec^)
) else (
  if "%GITREPOS_STATUS%%GITREPOS_PULL%%GITREPOS_LIST_BRANCHES%%GITREPOS_CHECKOUT_BRANCHES%" neq "" echo %GITREPOS_DATE_START% %GITREPOS_TIME_START%...%GITREPOS_TIME_STOP% ^(duration %_DIFFT_DUR_SS% sec^)
)
endlocal

:Exit
set GITREPOS_START_DIR=
set GITREPOS_SCRIPT=
set GITREPOS_SCRIPT_DIR=
set GITREPOS_SCRIPT_NAME=
set GITREPOS_DIR=
set GITREPOS_PULL=
set GITREPOS_LIST_REMOTES=
set GITREPOS_LIST_BRANCHES=
set GITREPOS_CHECKOUT_BRANCHES=
set GITREPOS_STATUS=
set GITREPOS_COMPACT=
set GITREPOS_VERBOSE=
set GITREPOS_DIFF=
set GITREPOS_FAST=
set GITREPOS_COUNT=
set GITREPOS_MAXLENGTH_ABS=
set GITREPOS_MAXLENGTH_REL=
set GITREPOS_DATE_START=
set GITREPOS_TIME_START=
set GITREPOS_DATE_STOP=
set GITREPOS_TIME_STOP=
goto :EOF


:Diff
echo *** %GITREPOS_SCRIPT_NAME% compare vs. han_scripts version ***
echo diff "%GITREPOS_SCRIPT%" "%HANSCRIPT_ROOT%\git_repos.bat"
if "%HANSCRIPT_ROOT%" equ "" echo ERROR: compare of '%GITREPOS_SCRIPT_NAME%' against han_scripts version not possible - HANSCRIPT_ROOT not defined &goto :Exit
if not exist "%HANSCRIPT_ROOT%\git_repos.bat" echo ERROR: compare of '%GITREPOS_SCRIPT_NAME%' against han_scripts version not possible - han_scripts version does not exist &goto :Exit
call diff "%GITREPOS_SCRIPT%" "%HANSCRIPT_ROOT%\git_repos.bat"
goto :Exit


:Usage
echo.
echo USAGE:
echo %GITREPOS_SCRIPT_NAME% [[--dir^|-d] ^<path^>]  [--verbose^|-v] [--compact^|-c] [--fast^|-f] [--status^|-s] [--pull^|-p]
echo %GITREPOS_SCRIPT_NAME% [[--dir^|-d] ^<path^>]  [--list_branches^|-lb]
echo %GITREPOS_SCRIPT_NAME% [[--dir^|-d] ^<path^>]  [--checkout_branches^|-cb]
echo %GITREPOS_SCRIPT_NAME% [--diff^|-diff^|-di]
echo %GITREPOS_SCRIPT_NAME% [--help^|-h^|-?]
echo.
goto :Exit


:::List_Git_GITREPOS_in_Dir
::SETLOCAL ENABLEEXTENSIONS
::if exist "%~1\.git" (call :Dump_Git_Repo "%~1" "%GITREPOS_COUNT%" "%GITREPOS_MAXLENGTH_ABS%" "%GITREPOS_MAXLENGTH_REL%")
::for /D %%d in (%~1\*) do call :List_Git_GITREPOS_in_Dir "%%~d"
::ENDLOCAL
::goto :EOF


:Dump_Git_Repo
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem VERIFY OTHER 2>nul &SETLOCAL ENABLEDELAYEDEXPANSION &IF ERRORLEVEL 1 (echo CMD extensions not available & goto :EOF)
SETLOCAL ENABLEDELAYEDEXPANSION
set "_DG_REPO_DIR=%~dpnx1"
if "%_DG_REPO_DIR:~-1%" equ "\" set "_DG_REPO_DIR=%_DG_REPO_DIR:~0,-1%"
set "_DG_REPO_CNT=%~2"
set "_DG_REPO_MAX_ABS=%~3"
set "_DG_REPO_MAX_REL=%~4"
set /A _DG_COLUMNS=%_DG_REPO_MAX_ABS%+2
pushd "%_DG_REPO_DIR%"
if "%GITREPOS_COMPACT%" equ "" goto :Dump_Git_Repo_start
rem adapt to compact presentation
set "_DG_REPO_DIR=%~1"
if "%_DG_REPO_DIR:~-1%" equ "\" set "_DG_REPO_DIR=%_DG_REPO_DIR:~0,-1%"
set /A _DG_COLUMNS=%_DG_REPO_MAX_REL%+2
set "_string=%GITREPOS_DIR%"
call :strlen _string _DG_BASE_DIR_STRING_LENGTH
set "_DG_REPO_DIR=.!_DG_REPO_DIR:~%_DG_BASE_DIR_STRING_LENGTH%!"

:Dump_Git_Repo_start
rem since we echo the string with quotes and with prefic spaces, we simulate the effective string in following echo
set "_string=-%_DG_REPO_DIR%-"
call :strlen _string _DG_STRING_LENGTH
rem since we use _STRING_LENGTH as the start value for the range, we have add 1 for correct counting
set /A _DG_STRING_LENGTH=!_DG_STRING_LENGTH!+2
set "_DG_RIGHT_PADDING= "
if %_DG_REPO_CNT% gtr 1 for /L %%i in (!_DG_STRING_LENGTH!,1,!_DG_COLUMNS!) do set "_DG_RIGHT_PADDING=!_DG_RIGHT_PADDING! "
set _DG_FULL_PADDING=
if %_DG_REPO_CNT% gtr 1 for /L %%i in (1,1,!_DG_COLUMNS!) do set "_DG_FULL_PADDING=!_DG_FULL_PADDING! "
rem debugging
if "%GITREPOS_VERBOSE%" neq "" for /f "tokens=1,* delims==" %%s in ('set _DG_') do @echo.%%s="%%t"
rem repo listing and actions
if "%GITREPOS_LIST_REMOTES%"      neq "" for /f "tokens=2,3" %%i in ('call git remote -v') do @if /I "%%j" equ "(push)" echo."%_DG_REPO_DIR%"!_DG_RIGHT_PADDING!^(%%i^)
if "%GITREPOS_LIST_BRANCHES%"     neq "" echo.!_DG_FULL_PADDING!BRANCHES:
if "%GITREPOS_LIST_BRANCHES%"     neq "" for /f "tokens=*" %%i in ('call git branch -a') do echo.!_DG_FULL_PADDING!  %%i
if "%GITREPOS_CHECKOUT_BRANCHES%" neq "" echo.!_DG_FULL_PADDING!CHECKOUT-BRANCHES:
if "%GITREPOS_CHECKOUT_BRANCHES%" neq "" (
  rem 1) iterate over local branches and remember checked out branch
  set "_DG_CHECKED_OUT_BRANCH=main"
  for /f "tokens=1,*" %%b in ('call git branch') do (
    if "%%~b" equ "*" set "_DG_CHECKED_OUT_BRANCH=%%~c"
  )
  rem 2) iterate over remote branches and check them out
  set _DG_COUNT=0
  for /f "tokens=1,*" %%b in ('call git branch -r') do (
    if "%%~b" neq "*" if "%%~c" equ "" (
      set /A _DG_COUNT=!_DG_COUNT!+1
      rem the remote origins do not need to be named always 'origin' and there can be multiple ones!
      rem so this here is right now just a simplification for the default case:
      set "_DG_BRANCH_NAME=%%~b"
      if "%GITREPOS_VERBOSE%" neq "" echo. debug: "!_DG_BRANCH_NAME!" ^('%%~b' '%%~c'^)
      set "_DG_BRANCH_NAME=!_DG_BRANCH_NAME:origin/=!"
      if "%GITREPOS_VERBOSE%" neq "" echo. debug: "!_DG_BRANCH_NAME!"
      echo.!_DG_FULL_PADDING!^(!_DG_COUNT!^) '!_DG_BRANCH_NAME!'
      for /f "tokens=*" %%i in ('call git switch "!_DG_BRANCH_NAME!" 2^>^&1') do echo.!_DG_FULL_PADDING!  %%i
      for /f "tokens=*" %%i in ('call git pull  2^>^&1') do echo.!_DG_FULL_PADDING! - %%i
    )
  )
  rem 3) restore the old local checkout
  if "%GITREPOS_VERBOSE%" neq "" echo debug: git switch "!_DG_CHECKED_OUT_BRANCH!"
  for /f "tokens=*" %%i in ('call git switch "!_DG_CHECKED_OUT_BRANCH!" 1^>nul 2^>^&1') do echo.!_DG_FULL_PADDING!  %%i
  rem 4) now list the local checked out branches
  echo.!_DG_FULL_PADDING!BRANCHES:
  for /f "tokens=*" %%i in ('call git branch') do echo.!_DG_FULL_PADDING!  %%i
)
if "%GITREPOS_STATUS%" neq "" echo.!_DG_FULL_PADDING!STATUS:
if "%GITREPOS_STATUS%" neq "" for /f "tokens=*" %%i in ('call git status 2^>^&1') do echo.!_DG_FULL_PADDING!  %%i
if "%GITREPOS_STATUS%" neq "" for /f "tokens=*" %%i in ('call git fetch 2^>^&1')  do echo.!_DG_FULL_PADDING!  %%i
if "%GITREPOS_PULL%"   neq "" echo.!_DG_FULL_PADDING!PULL:
if "%GITREPOS_PULL%"   neq "" for /f "tokens=*" %%i in ('call git pull 2^>^&1')   do echo.!_DG_FULL_PADDING!  %%i
if %_DG_REPO_CNT% gtr 1 if "%GITREPOS_STATUS%%GITREPOS_PULL%%GITREPOS_LIST_BRANCHES%%GITREPOS_CHECKOUT_BRANCHES%" neq "" echo.
popd
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
ENDLOCAL
goto :EOF


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