@echo off
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem https://stackoverflow.com/questions/11916823/batch-limitation-maximum-recursion-while-browsing-menus
rem SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set REPOS_DIR=
set REPOS_PULL=
set REPOS_STATUS=
set REPOS_VERBOSE=
set REPOS_COMPACT=
:param_loop
if /I "%~1" equ "--dir"     (set "REPOS_DIR=%~2" &shift &shift &goto :param_loop)
if /I "%~1" equ "-d"        (set "REPOS_DIR=%~2" &shift &shift &goto :param_loop)
if /I "%~1" equ "--pull"    (set "REPOS_PULL=--pull" &shift &goto :param_loop)
if /I "%~1" equ "-p"        (set "REPOS_PULL=--pull" &shift &goto :param_loop)
if /I "%~1" equ "--status"  (set "REPOS_STATUS=--status" &shift &goto :param_loop)
if /I "%~1" equ "-s"        (set "REPOS_STATUS=--status" &shift &goto :param_loop)
if /I "%~1" equ "--compact" (set "REPOS_COMPACT=--compact" &shift &goto :param_loop)
if /I "%~1" equ "-c"        (set "REPOS_COMPACT=--compact" &shift &goto :param_loop)
if /I "%~1" equ "--verbose" (set "REPOS_VERBOSE=--verbose" &shift &goto :param_loop)
if /I "%~1" equ "-v"        (set "REPOS_VERBOSE=--verbose" &shift &goto :param_loop)
if "%~1" neq "" if "%REPOS_DIR%" equ "" (set "REPOS_DIR=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo warning: unexpected argument '%~1'&shift &goto :param_loop)
if "%REPOS_DIR%" equ "" set "REPOS_DIR=%cd%"
pushd "%REPOS_DIR%"
set "REPOS_DIR=%cd%"
popd
if "%REPOS_VERBOSE%" neq "" for /f "tokens=1,* delims==" %%s in ('set REPOS_') do @echo.%%s="%%t"
echo.*** Git repositories list ***
echo."%REPOS_DIR%":
call :List_Git_Repos_in_Dir "%REPOS_DIR%"
set REPOS_DIR=
set REPOS_PULL=
set REPOS_STATUS=
set REPOS_COMPACT=
set REPOS_VERBOSE=
goto :EOF

:List_Git_Repos_in_Dir
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem VERIFY OTHER 2>nul &SETLOCAL ENABLEEXTENSIONS &IF ERRORLEVEL 1 (echo CMD extensions not available & goto :EOF)
SETLOCAL ENABLEEXTENSIONS
if exist "%~1\.git" (call :Dump_Git_Repo "%~1")
for /D %%d in (%~1\*) do if exist "%%~d\.git" (call :Dump_Git_Repo "%%~d") else (call :List_Git_Repos_in_Dir "%%~d")
ENDLOCAL
goto :EOF

:Dump_Git_Repo
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
rem VERIFY OTHER 2>nul &SETLOCAL ENABLEDELAYEDEXPANSION &IF ERRORLEVEL 1 (echo CMD extensions not available & goto :EOF)
SETLOCAL ENABLEDELAYEDEXPANSION
set "_DG_REPO_DIR=%~dpnx1"
set _DG_COLUMNS=70
set "_DG_PREFIX= "
set "_DG_SUFFIX=  "
pushd "%_DG_REPO_DIR%"
if "%REPOS_COMPACT%" equ "" goto :Dump_Git_Repo_start
rem adapt to compact presentation
set "_DG_REPO_DIR=%~1" 
set _DG_COLUMNS=50
set "_DG_PREFIX="
set "_DG_SUFFIX= "
>"%TEMP%\strlen.tmp" echo."%REPOS_DIR%"
set _DG_BASE_DIR_STRING_LENGTH=0
for %%? in (%TEMP%\strlen.tmp) do (set /A _DG_BASE_DIR_STRING_LENGTH=%%~z? - 4)
set "_DG_REPO_DIR=.!_DG_REPO_DIR:~%_DG_BASE_DIR_STRING_LENGTH%!"
:Dump_Git_Repo_start
rem since we echo the string with quotes and with prefic spaces, we simulate the effective string in following echo
>"%TEMP%\strlen.tmp" echo."%_DG_PREFIX%-%_DG_REPO_DIR%-"
set _DG_STRING_LENGTH=0
for %%? in (%TEMP%\strlen.tmp) do (set /A _DG_STRING_LENGTH=%%~z? - 4)
rem set /A _DG_STRING_LENGTH=!_DG_STRING_LENGTH!+2
rem since we use _STRING_LENGTH as the start value for the range, we have add 1 for correct counting
set /A _DG_STRING_LENGTH=!_DG_STRING_LENGTH!+1
set "_DG_RIGHT_PADDING=%_DG_SUFFIX%"
for /L %%i in (!_DG_STRING_LENGTH!,1,!_DG_COLUMNS!) do set "_DG_RIGHT_PADDING=!_DG_RIGHT_PADDING! "
set "_DG_FULL_PADDING=%_DG_SUFFIX%"
for /L %%i in (1,1,!_DG_COLUMNS!) do set "_DG_FULL_PADDING=!_DG_FULL_PADDING! "
rem debugging
if "%REPOS_VERBOSE%" neq "" for /f "tokens=1,* delims==" %%s in ('set _DG_') do @echo.%%s="%%t"
rem repo listing and actions
for /f "tokens=2,3" %%i in ('call git remote -v') do @if /I "%%j" equ "(push)" echo.!_DG_PREFIX!"%_DG_REPO_DIR%"!_DG_RIGHT_PADDING!^(%%i^)
if "%REPOS_STATUS%" neq "" echo.!_DG_FULL_PADDING!STATUS:
if "%REPOS_STATUS%" neq "" for /f "tokens=*" %%i in ('call git status') do echo.!_DG_FULL_PADDING!- %%i
if "%REPOS_PULL%"   neq "" echo.!_DG_FULL_PADDING!PULL:
if "%REPOS_PULL%"   neq "" for /f "tokens=*" %%i in ('call git pull')   do echo.!_DG_FULL_PADDING!- %%i
if "%REPOS_STATUS%%REPOS_PULL%" neq "" echo.
popd
rem fix: ******  B A T C H   R E C U R S I O N  exceeds STACK limits ******
ENDLOCAL
goto :EOF