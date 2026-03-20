@echo off
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem https://stackoverflow.com/questions/11916823/batch-limitation-maximum-recursion-while-browsing-menus
rem SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set "REPOS_SCRIPT=%~dpnx0"
set "REPOS_NAME=%~n0"
set "REPOS_START_DIR=%cd%"

set REPOS_COMPACT=
set REPOS_VERBOSE=
set REPOS_DIFF=
set REPOS_FAST=

set REPOS_DIR=
set REPOS_STATUS=
set REPOS_PULL=
set REPOS_LIST_REMOTES=--remotes
set REPOS_LIST_BRANCHES=
set REPOS_CHECKOUT_BRANCHES=
:param_loop
if /I "%~1" equ "--help"    (goto :Usage)
if /I "%~1" equ "-h"        (goto :Usage)
if /I "%~1" equ "-?"        (goto :Usage)
if /I "%~1" equ "--dir"     (if "%~2" equ "" (echo ERROR: missing ^<path^> parameter&goto :Usage) &set "REPOS_DIR=%~2" &shift &shift &goto :param_loop)
if /I "%~1" equ "-d"        (if "%~2" equ "" (echo ERROR: missing ^<path^> parameter&goto :Usage) &set "REPOS_DIR=%~2" &shift &shift &goto :param_loop)
if /I "%~1" equ "--pull"    (set "REPOS_PULL=--pull" &shift &goto :param_loop)
if /I "%~1" equ "-p"        (set "REPOS_PULL=--pull" &shift &goto :param_loop)
if /I "%~1" equ "--status"  (set "REPOS_STATUS=--status" &shift &goto :param_loop)
if /I "%~1" equ "-s"        (set "REPOS_STATUS=--status" &shift &goto :param_loop)
if /I "%~1" equ "--compact" (set "REPOS_COMPACT=--compact" &shift &goto :param_loop)
if /I "%~1" equ "-c"        (set "REPOS_COMPACT=--compact" &shift &goto :param_loop)
if /I "%~1" equ "--verbose" (set "REPOS_VERBOSE=--verbose" &shift &goto :param_loop)
if /I "%~1" equ "-v"        (set "REPOS_VERBOSE=--verbose" &shift &goto :param_loop)
if /I "%~1" equ "--fast"    (set "REPOS_FAST=--fast" &shift &goto :param_loop)
if /I "%~1" equ "-f"        (set "REPOS_FAST=--fast" &shift &goto :param_loop)
if /I "%~1" equ "--diff"    (set "REPOS_DIFF=--diff" &shift &goto :param_loop)
if /I "%~1" equ "-diff"     (set "REPOS_DIFF=--diff" &shift &goto :param_loop)
if /I "%~1" equ "-di"       (set "REPOS_DIFF=--diff" &shift &goto :param_loop)
if /I "%~1" equ "--list_branches"     (set "REPOS_LIST_BRANCHES=--list_branches" &shift &goto :param_loop)
if /I "%~1" equ "-lb"                 (set "REPOS_LIST_BRANCHES=--list_branches" &shift &goto :param_loop)
if /I "%~1" equ "--checkout_branches" (set "REPOS_CHECKOUT_BRANCHES=--checkout_branches" &shift &goto :param_loop)
if /I "%~1" equ "-cb"                 (set "REPOS_CHECKOUT_BRANCHES=--checkout_branches" &shift &goto :param_loop)
if "%~1" neq "" if "%REPOS_DIR%" equ "" (set "REPOS_DIR=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo warning: unexpected argument '%~1'&shift &goto :param_loop)
if "%REPOS_DIR%" equ "" set "REPOS_DIR=%cd%"
pushd "%REPOS_DIR%"
set "REPOS_DIR=%cd%"
popd

if "%REPOS_VERBOSE%" neq "" for /f "tokens=1,* delims==" %%s in ('set REPOS_') do @echo.%%s="%%t"
if "%REPOS_DIFF%" neq "" goto :Diff

:MainBegin
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
if "%REPOS_VERBOSE%" neq "" echo on
pushd "%REPOS_DIR%"
rem stopwatch-start
for /f "tokens=2 delims=:" %%i in ('echo.^|date') do if "!_DATE_!" equ "" set "_DATE_=%%~i"
if "%_DATE_:~0,1%" equ " " set "_DATE_=%_DATE_:~1%"
if "%_DATE_:~-1%" equ " " set "_DATE_=%_DATE_:~0,-1%"
set "REPOS_DATE_START=%_DATE_%"
for /f "tokens=2,3,4 delims=:" %%i in ('echo.^|time') do if "%%j" neq "" set "_TIME_=%%i:%%j:%%k"
set "REPOS_TIME_START=%_TIME_: =%"

rem count git repos and analyse maximum path length for most compact dump
echo|set /p="*** Git repositories *** "
set REPOS_COUNT=0
set REPOS_MAXLENGTH_ABS=0
set REPOS_MAXLENGTH_REL=0
if "%REPOS_FAST%" equ "" (
  for /f %%d in ('dir /s /AD /b') do if /i "%%~xd" equ ".git" (
    if "%REPOS_VERBOSE%" neq "" echo "%%~dpnd" 
    echo|set /p="."
    set /a REPOS_COUNT=!REPOS_COUNT!+1
    set "_string=%%~dpnd"
    call :strlen _string _strlen
    if !_strlen! gtr !REPOS_MAXLENGTH_ABS! set REPOS_MAXLENGTH_ABS=!_strlen!
    set "_string=!_string:%REPOS_DIR%=.!"
    if "%REPOS_VERBOSE%" neq "" echo "!_string!"
    call :strlen _string _strlen
    if !_strlen! gtr !REPOS_MAXLENGTH_REL! set REPOS_MAXLENGTH_REL=!_strlen!
  )
) else (
  set REPOS_COUNT=99
  set REPOS_MAXLENGTH_ABS=70
  set REPOS_MAXLENGTH_REL=51
) 
echo.
if "%REPOS_VERBOSE%" neq "" set REPOS_COUNT
if "%REPOS_VERBOSE%" neq "" set REPOS_MAXLENGTH
if %REPOS_COUNT% equ 0 echo no git repositories found &goto MainBEnd
if "%REPOS_COMPACT%" neq "" echo."%REPOS_DIR%":
if %REPOS_COUNT% equ 1 (s
  set REPOS_MAXLENGTH_ABS=-2
  set REPOS_MAXLENGTH_REL=-2
)
for /f %%d in ('dir /s /AD /b') do if /i "%%~xd" equ ".git" call :Dump_Git_Repo "%%~dpnd" "%REPOS_COUNT%" "%REPOS_MAXLENGTH_ABS%" "%REPOS_MAXLENGTH_REL%"

:MainBEnd
rem stopwatch-stop
for /f "tokens=2 delims=:" %%i in ('echo.^|date') do if "!_DATE_!" equ "" set "_DATE_=%%~i"
if "%_DATE_:~0,1%" equ " " set "_DATE_=%_DATE_:~1%"
if "%_DATE_:~-1%" equ " " set "_DATE_=%_DATE_:~0,-1%"
set "REPOS_DATE_STOP=%_DATE_%"
for /f "tokens=2,3,4 delims=:" %%i in ('echo.^|time') do if "%%j" neq "" set "_TIME_=%%i:%%j:%%k"
set "REPOS_TIME_STOP=%_TIME_: =%"
if %REPOS_COUNT% gtr 1 (
  echo %REPOS_DATE_START%: %REPOS_TIME_START%...%REPOS_TIME_STOP%
) else (
  if "%REPOS_VERBOSE%" neq "" echo %REPOS_TIME_START%...%REPOS_TIME_STOP%
)
popd
endlocal

:Exit
set REPOS_START_DIR=
set REPOS_SCRIPT=
set REPOS_NAME=
set REPOS_DIR=
set REPOS_PULL=
set REPOS_LIST_REMOTES=
set REPOS_LIST_BRANCHES=
set REPOS_CHECKOUT_BRANCHES=
set REPOS_STATUS=
set REPOS_COMPACT=
set REPOS_VERBOSE=
set REPOS_DIFF=
set REPOS_FAST=
goto :EOF



:Diff
echo *** %REPOS_NAME% compare vs. han_scripts version ***
echo diff "%REPOS_SCRIPT%" "%HANSCRIPT_ROOT%\git_repos.bat"
if "%HANSCRIPT_ROOT%" equ "" echo ERROR: compare of '%REPOS_NAME%' against han_scripts version not possible - HANSCRIPT_ROOT not defined &goto :Exit
if not exist "%HANSCRIPT_ROOT%\git_repos.bat" echo ERROR: compare of '%REPOS_NAME%' against han_scripts version not possible - han_scripts version does not exist &goto :Exit
call diff "%REPOS_SCRIPT%" "%HANSCRIPT_ROOT%\git_repos.bat"
goto :Exit

:Usage
echo.
echo USAGE:
echo %REPOS_NAME% [[--dir^|-d] ^<path^>]  [--verbose^|-v] [--compact^|-c] [--fast^|-f] [--status^|-s] [--pull^|-p]
echo %REPOS_NAME% [[--dir^|-d] ^<path^>]  [--list_branches^|-lb]
echo %REPOS_NAME% [[--dir^|-d] ^<path^>]  [--checkout_branches^|-cb]
echo %REPOS_NAME% [--diff^|-diff^|-di]
echo %REPOS_NAME% [--help^|-h^|-?]
echo.
goto :Exit


:List_Git_Repos_in_Dir
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem VERIFY OTHER 2>nul &SETLOCAL ENABLEEXTENSIONS &IF ERRORLEVEL 1 (echo CMD extensions not available & goto :EOF)
SETLOCAL ENABLEEXTENSIONS
if exist "%~1\.git" (call :Dump_Git_Repo "%~1" "%REPOS_COUNT%" "%REPOS_MAXLENGTH_ABS%" "%REPOS_MAXLENGTH_REL%")
for /D %%d in (%~1\*) do call :List_Git_Repos_in_Dir "%%~d"
ENDLOCAL
goto :EOF


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
set "_DG_PREFIX="
set "_DG_SUFFIX=  "
pushd "%_DG_REPO_DIR%"
if "%REPOS_COMPACT%" equ "" goto :Dump_Git_Repo_start
rem adapt to compact presentation
set "_DG_REPO_DIR=%~1"
if "%_DG_REPO_DIR:~-1%" equ "\" set "_DG_REPO_DIR=%_DG_REPO_DIR:~0,-1%"
set /A _DG_COLUMNS=%_DG_REPO_MAX_REL%+2
set "_DG_PREFIX="
set "_DG_SUFFIX= "
set "_string=%REPOS_DIR%"
call :strlen _string _DG_BASE_DIR_STRING_LENGTH
set "_DG_REPO_DIR=.!_DG_REPO_DIR:~%_DG_BASE_DIR_STRING_LENGTH%!"

:Dump_Git_Repo_start
rem since we echo the string with quotes and with prefic spaces, we simulate the effective string in following echo
set "_string=%_DG_PREFIX%-%_DG_REPO_DIR%-"
call :strlen _string _DG_STRING_LENGTH
rem since we use _STRING_LENGTH as the start value for the range, we have add 1 for correct counting
set /A _DG_STRING_LENGTH=!_DG_STRING_LENGTH!+1
set "_DG_RIGHT_PADDING=%_DG_SUFFIX%"
for /L %%i in (!_DG_STRING_LENGTH!,1,!_DG_COLUMNS!) do set "_DG_RIGHT_PADDING=!_DG_RIGHT_PADDING! "
set "_DG_FULL_PADDING=%_DG_SUFFIX%"
for /L %%i in (1,1,!_DG_COLUMNS!) do set "_DG_FULL_PADDING=!_DG_FULL_PADDING! "
rem debugging
if "%REPOS_VERBOSE%" neq "" for /f "tokens=1,* delims==" %%s in ('set _DG_') do @echo.%%s="%%t"
rem repo listing and actions
if "%REPOS_LIST_REMOTES%"      neq "" for /f "tokens=2,3" %%i in ('call git remote -v') do @if /I "%%j" equ "(push)" echo.!_DG_PREFIX!"%_DG_REPO_DIR%"!_DG_RIGHT_PADDING!^(%%i^)
if "%REPOS_LIST_BRANCHES%"     neq "" echo.!_DG_FULL_PADDING!BRANCHES:
if "%REPOS_LIST_BRANCHES%"     neq "" for /f "tokens=*" %%i in ('call git branch -a') do echo.!_DG_FULL_PADDING!  %%i
if "%REPOS_CHECKOUT_BRANCHES%" neq "" echo.!_DG_FULL_PADDING!CHECKOUT-BRANCHES:
if "%REPOS_CHECKOUT_BRANCHES%" neq "" (
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
      if "%REPOS_VERBOSE%" neq "" echo. debug: "!_DG_BRANCH_NAME!" ^('%%~b' '%%~c'^)
      set "_DG_BRANCH_NAME=!_DG_BRANCH_NAME:origin/=!"
      if "%REPOS_VERBOSE%" neq "" echo. debug: "!_DG_BRANCH_NAME!"
      echo.!_DG_FULL_PADDING!^(!_DG_COUNT!^) '!_DG_BRANCH_NAME!'
      for /f "tokens=*" %%i in ('call git switch "!_DG_BRANCH_NAME!" 2^>^&1') do echo.!_DG_FULL_PADDING!  %%i
      for /f "tokens=*" %%i in ('call git pull  2^>^&1') do echo.!_DG_FULL_PADDING! - %%i
    )
  )
  rem 3) restore the old local checkout
  if "%REPOS_VERBOSE%" neq "" echo debug: git switch "!_DG_CHECKED_OUT_BRANCH!"
  for /f "tokens=*" %%i in ('call git switch "!_DG_CHECKED_OUT_BRANCH!" 1^>nul 2^>^&1') do echo.!_DG_FULL_PADDING!  %%i
  rem 4) now list the local checked out branches
  echo.!_DG_FULL_PADDING!BRANCHES:
  for /f "tokens=*" %%i in ('call git branch') do echo.!_DG_FULL_PADDING!  %%i
)
if "%REPOS_STATUS%" neq "" echo.!_DG_FULL_PADDING!STATUS:
if "%REPOS_STATUS%" neq "" for /f "tokens=*" %%i in ('call git status 2^>^&1') do echo.!_DG_FULL_PADDING!  %%i
if "%REPOS_STATUS%" neq "" for /f "tokens=*" %%i in ('call git fetch 2^>^&1')  do echo.!_DG_FULL_PADDING!  %%i
if "%REPOS_PULL%"   neq "" echo.!_DG_FULL_PADDING!PULL:
if "%REPOS_PULL%"   neq "" for /f "tokens=*" %%i in ('call git pull 2^>^&1')   do echo.!_DG_FULL_PADDING!  %%i
if "%REPOS_STATUS%%REPOS_PULL%%REPOS_LIST_BRANCHES%%REPOS_CHECKOUT_BRANCHES%" neq "" echo.
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