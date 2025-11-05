@echo off

pushd "%~dp0..\.."
set "MAKER_ROOT=%cd%"
popd
rem strip "\" suffix:
if "%MAKER_ROOT:~-1%" equ "\" set "MAKER_ROOT=%MAKER_ROOT:~0,-1%"

set "MAKER_BIN=%MAKER_ROOT%\.tools"
set "MAKER_BUILD=%MAKER_ROOT%\scripts"
set "MAKER_SCRIPTS=%MAKER_ROOT%\scripts\core"
set "MAKER_TOOLS=%MAKER_ROOT%\tools"
set "MAKER_PROJECTS=%MAKER_ROOT%\projects"
set "MAKER_PROJECTS_DOTNET=%MAKER_PROJECTS%\.Net"
set "MAKER_PROJECTS_WEB=%MAKER_PROJECTS%\Web"

if not exist "%MAKER_BIN%" mkdir "%MAKER_BIN%"
echo @echo MAKER_ENV_ACTIVE>"%MAKER_BIN%\maker_env_test.bat"
call maker_env_test.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%MAKER_BIN%"

rem if "%~1" equ "" goto :exit
if /I "%~1" equ "--keep" shift &goto :param_loop
set MAKER_ENV_NOERROS=
set MAKER_ENV_NOWARNINGS=
set MAKER_ENV_NOINFOS=
set MAKER_ENV_VERBOSE=
set MAKER_ENV_SILENT=
set MAKER_ENV_REBUILD=
set MAKER_ENV_HELP=
set MAKER_ENV_VERSION=
set MAKER_ENV_ARCHITECTURE=
set MAKER_ENV_BUILDTYPE=
set MAKER_ENV_UNKNOWN_SWITCHES=
set MAKER_ENV_UNKNOWN_ARGS=
set MAKER_ENV_ALL_ARGS=
for /L %%i in (1,1,10) do set MAKER_ENV_UNKNOWN_ARG_%%i=&set MAKER_ENV_UNKNOWN_SWITCH_%%i=
:param_loop
set "__ARG_RAW__=%1"
set "__ARG__=%~1"
if "%__ARG__%" equ "" goto :param_loop_exit
shift
rem handle known switches:
if /I "%__ARG__%" equ "--"             (goto :param_loop)
if /I "%__ARG__%" equ "--no_errors"    (set "MAKER_ENV_NOERROS=--no_errors" &goto :param_loop)
if /I "%__ARG__%" equ "-ne"            (set "MAKER_ENV_NOERROS=--no_errors" &goto :param_loop)
if /I "%__ARG__%" equ "--no_warnings"  (set "MAKER_ENV_NOWARNINGS=--no_warnings" &goto :param_loop)
if /I "%__ARG__%" equ "-nw"            (set "MAKER_ENV_NOWARNINGS=--no_warnings" &goto :param_loop)
if /I "%__ARG__%" equ "--no_info"      (set "MAKER_ENV_NOINFOS=--no_info" &goto :param_loop)
if /I "%__ARG__%" equ "-ni"            (set "MAKER_ENV_NOINFOS=--no_info" &goto :param_loop)
if /I "%__ARG__%" equ "--verbose"      (set "MAKER_ENV_VERBOSE=--verbose" &goto :param_loop)
if /I "%__ARG__%" equ "-v"             (set "MAKER_ENV_VERBOSE=--verbose" &goto :param_loop)
if /I "%__ARG__%" equ "--silent"       (set "MAKER_ENV_SILENT=--silent"  &goto :param_loop)
if /I "%__ARG__%" equ "-s"             (set "MAKER_ENV_SILENT=--silent"  &goto :param_loop)
if /I "%__ARG__%" equ "--rebuild"      (set "MAKER_ENV_REBUILD=--rebuild" &goto :param_loop)
if /I "%__ARG__%" equ "-r"             (set "MAKER_ENV_REBUILD=--rebuild" &goto :param_loop)
if /I "%__ARG__%" equ "--help"         (set "MAKER_ENV_HELP=--help" &goto :param_loop)
if /I "%__ARG__%" equ "-h"             (set "MAKER_ENV_HELP=--help" &goto :param_loop)
if /I "%__ARG__%" equ "-?"             (set "MAKER_ENV_HELP=--help" &goto :param_loop)
rem handle unknown switches:
if /I "%__ARG__:~0,1%" equ "-" (set "MAKER_ENV_UNKNOWN_SWITCHES=%MAKER_ENV_UNKNOWN_SWITCHES% %__ARG_RAW__%" &goto :param_loop)
if /I "%__ARG__:~0,1!" equ "-" (set "MAKER_ENV_UNKNOWN_SWITCHES=%MAKER_ENV_UNKNOWN_SWITCHES% %__ARG_RAW__%" &goto :param_loop)
rem handle known named args:
if /I "%__ARG__%" equ equ "Debug"      (set "MAKER_ENV_BUILDTYPE=Debug"      &goto :param_loop)
if /I "%__ARG__%" equ equ "Release"    (set "MAKER_ENV_BUILDTYPE=Release"    &goto :param_loop)
if /I "%__ARG__%" equ equ "MinSizeRel" (set "MAKER_ENV_BUILDTYPE=MinSizeRel" &goto :param_loop)
if /I "%__ARG__%" equ "x86"            (set "MAKER_ENV_ARCHITECTURE=x86"     &goto :param_loop)
if /I "%__ARG__%" equ "x64"            (set "MAKER_ENV_ARCHITECTURE=x64"     &goto :param_loop)
if /I "%__ARG__%" equ "amd64"          (set "MAKER_ENV_ARCHITECTURE=amd64"   &goto :param_loop)
rem handle known free args:
if /I "%__ARG__%" neq "" if "%MAKER_ENV_VERSION%" equ "" (set "MAKER_ENV_VERSION=%__ARG__%" &goto :param_loop)
rem handle unknown args:
if /I "%__ARG__%" neq "" (set "MAKER_ENV_UNKNOWN_ARGS=%MAKER_ENV_UNKNOWN_ARGS% %__ARG_RAW__%" &goto :param_loop)
:param_loop_exit
set __ARG__=
set __ARG_RAW__=

set "MAKER_ENV_ALL_ARGS=%MAKER_ENV_VERSION% %MAKER_ENV_UNKNOWN_ARGS% %MAKER_ENV_BUILDTYPE% %MAKER_ENV_ARCHITECTURE%"

rem split unknonw args and switches
:split_unknown_args
if "%MAKER_ENV_UNKNOWN_ARGS%" equ "" goto :split_unknown_switches
SETLOCAL ENABLEDELAYEDEXPANSION
echo @echo off>"%TEMP%\_split_free_args.bat"
set _MAKER_ENV_ARG_ASSIGNED=
for %%j in (%MAKER_ENV_UNKNOWN_ARGS%) do set _MAKER_ENV_ARG_ASSIGNED=&for /L %%i in (1,1,10) do if "!_MAKER_ENV_ARG_ASSIGNED!" equ "" if "!MAKER_ENV_UNKNOWN_ARG_%%i!" equ "" set "MAKER_ENV_UNKNOWN_ARG_%%i=%%~j" &set _MAKER_ENV_ARG_ASSIGNED=done &echo set "MAKER_ENV_UNKNOWN_ARG_%%i=%%~j">>"%TEMP%\_split_free_args.bat"
rem if "%MAKER_ENV_VERBOSE%" neq "" set MAKER_ENV_UNKNOWN_ARG
ENDLOCAL
call "%TEMP%\_split_free_args.bat"
del "%TEMP%\_split_free_args.bat"
:split_unknown_switches
if "%MAKER_ENV_UNKNOWN_SWITCHES%" equ "" goto :exit
SETLOCAL ENABLEDELAYEDEXPANSION
set _MAKER_ENV_ARG_ASSIGNED=
for %%j in (%MAKER_ENV_UNKNOWN_SWITCHES%) do set _MAKER_ENV_ARG_ASSIGNED=&for /L %%i in (1,1,10) do if "!_MAKER_ENV_ARG_ASSIGNED!" equ "" if "!MAKER_ENV_UNKNOWN_SWITCH_%%i!" equ "" set "MAKER_ENV_UNKNOWN_SWITCH_%%i=%%~j" &set _MAKER_ENV_ARG_ASSIGNED=done &echo set "MAKER_ENV_UNKNOWN_SWITCH_%%i=%%~j">>"%TEMP%\_split_free_args.bat"
rem if "%MAKER_ENV_VERBOSE%" neq "" set MAKER_ENV_UNKNOWN_SWITCH
ENDLOCAL
call "%TEMP%\_split_free_args.bat"
del "%TEMP%\_split_free_args.bat"

:exit
call "%MAKER_SCRIPTS%\set_version_env.bat" "MAKER_ENV" "%MAKER_ENV_VERSION%"
rem list env:
if "%MAKER_ENV_VERBOSE%" neq "" set MAKER_
rem show help:
if "%MAKER_ENV_HELP%" neq "" (
  echo.
  echo MAKER_ENV [switches] [version] [build_type] [architecture] [free_args] [free_switches]
  echo switches:
  echo   --no_errors   ^| -ne
  echo   --no_warnings ^| -nw
  echo   --no_info     ^| -ni
  echo   --verbose     ^| -v
  echo   --silent      ^| -s
  echo   --rebuild     ^| -r
  echo   --help        ^| -h ^| -?
  echo version:
  echo   any-version-nr
  echo build_type:
  echo   Debug ^| Release ^| MinSizeRel
  echo architecture:
  echo   x86 ^| x64 ^| amd64
)
