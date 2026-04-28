@echo off

pushd "%~dp0..\.."
set "MAKER_ENV_ROOT=%cd%"
popd
rem strip "\" suffix:
if "%MAKER_ENV_ROOT:~-1%" equ "\" set "MAKER_ENV_ROOT=%MAKER_ENV_ROOT:~0,-1%"

set "MAKER_ENV_BIN=%MAKER_ENV_ROOT%\.tools"
set "MAKER_ENV_CORE=%MAKER_ENV_ROOT%\scripts\core"

rem call powershell -command "(Get-CimInstance -ClassName Win32_Processor).NumberOfCores;"
rem call powershell -command "(Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors;"
set MAKER_NUM_PROCESSORS=%NUMBER_OF_PROCESSORS%
set /A MAKER_NUM_CORES=%NUMBER_OF_PROCESSORS%/2
set /A MAKER_NUM_PARALLEL=%NUMBER_OF_PROCESSORS%/6
if %MAKER_NUM_PARALLEL% lss 2 set MAKER_NUM_PARALLEL=1

set "MAKER_DIR_SCRIPTS=%MAKER_ENV_ROOT%\scripts"
set "MAKER_DIR_TOOLS=%MAKER_ENV_ROOT%\tools"
set "MAKER_DIR_PROJECTS=%MAKER_ENV_ROOT%\projects"

set "MAKER_DIR_PROJECTS_DOTNET=%MAKER_DIR_PROJECTS%\.Net"
set "MAKER_DIR_PROJECTS_WEB=%MAKER_DIR_PROJECTS%\Web"

pushd "%MAKER_ENV_ROOT%\.."
set "MAKER_DIR_QT=%cd%\QT"
set "MAKER_DIR_LLVM=%cd%\LLVM"
set "MAKER_DIR_AT=%cd%\AT"
popd

if not exist "%MAKER_ENV_BIN%" mkdir "%MAKER_ENV_BIN%"
echo @echo MAKER_ACTIVE>"%MAKER_ENV_BIN%\MAKER_test.bat"
call MAKER_test.bat 1>nul 2>nul
if %ERRORLEVEL% NEQ 0 set "PATH=%PATH%;%MAKER_ENV_BIN%"

rem if "%~1" equ "" goto :exit
rem if desired: keep existing maker_env values and only overwrite with new commandline args definitions
if /I "%~1" equ "--keep" shift &goto :parse_cmdline_args
:init_with_defaults_and_parse_cmdline_args
set MAKER_MSG_NOERRORS=
set MAKER_MSG_NOWARNINGS=
set MAKER_MSG_NOINFOS=
set MAKER_MSG_VERBOSE=
set MAKER_MSG_SILENT=
set MAKER_REBUILD=
set MAKER_HELP=
set MAKER_VERSION=
set MAKER_BUILD_ARCH=
set MAKER_BUILD_TYPE=
set MAKER_BUILD_MODE=
set MAKER_BUILD_SYSTEM=
set MAKER_BUILD_SYSTEM_SWITCH=
set MAKER_UNKNOWN_SWITCHES=
set MAKER_UNKNOWN_ARGS=
set MAKER_ALL_ARGS=
for /L %%i in (1,1,10) do set MAKER_UNKNOWN_ARG_%%i=&set MAKER_UNKNOWN_SWITCH_%%i=
:parse_cmdline_args
:param_loop
set "__ARG_RAW__=%1"
set "__ARG__=%~1"
if "%__ARG__%" equ "" goto :param_loop_exit
shift
if /I "%__ARG__%" neq "" (set "MAKER_ALL_ARGS=%MAKER_ALL_ARGS% %__ARG_RAW__%")
rem handle known switches:
if /I "%__ARG__%" equ "--no_errors"    (set "MAKER_MSG_NOERRORS=--no_errors" &goto :param_loop)
if /I "%__ARG__%" equ "-ne"            (set "MAKER_MSG_NOERRORS=--no_errors" &goto :param_loop)
if /I "%__ARG__%" equ "--no_warnings"  (set "MAKER_MSG_NOWARNINGS=--no_warnings" &goto :param_loop)
if /I "%__ARG__%" equ "-nw"            (set "MAKER_MSG_NOWARNINGS=--no_warnings" &goto :param_loop)
if /I "%__ARG__%" equ "--no_infos"     (set "MAKER_MSG_NOINFOS=--no_infos" &goto :param_loop)
if /I "%__ARG__%" equ "--no_info"      (set "MAKER_MSG_NOINFOS=--no_infos" &goto :param_loop)
if /I "%__ARG__%" equ "-ni"            (set "MAKER_MSG_NOINFOS=--no_infos" &goto :param_loop)
if /I "%__ARG__%" equ "--verbose"      (set "MAKER_MSG_VERBOSE=--verbose" &goto :param_loop)
if /I "%__ARG__%" equ "-v"             (set "MAKER_MSG_VERBOSE=--verbose" &goto :param_loop)
if /I "%__ARG__%" equ "--silent"       (set "MAKER_MSG_SILENT=--silent"  &goto :param_loop)
if /I "%__ARG__%" equ "-s"             (set "MAKER_MSG_SILENT=--silent"  &goto :param_loop)
if /I "%__ARG__%" equ "--rebuild"      (set "MAKER_REBUILD=--rebuild" &goto :param_loop)
if /I "%__ARG__%" equ "-r"             (set "MAKER_REBUILD=--rebuild" &goto :param_loop)
if /I "%__ARG__%" equ "--help"         (set "MAKER_HELP=--help" &goto :param_loop)
if /I "%__ARG__%" equ "-h"             (set "MAKER_HELP=--help" &goto :param_loop)
if /I "%__ARG__%" equ "-?"             (set "MAKER_HELP=--help" &goto :param_loop)
rem handle known named args:
if /I "%__ARG__%" equ "x86"            (set "MAKER_BUILD_ARCH=x86"        &goto :param_loop)
if /I "%__ARG__%" equ "x64"            (set "MAKER_BUILD_ARCH=x64"        &goto :param_loop)
if /I "%__ARG__%" equ "amd64"          (set "MAKER_BUILD_ARCH=amd64"      &goto :param_loop)
if /I "%__ARG__%" equ "Debug"          (set "MAKER_BUILD_TYPE=debug"      &goto :param_loop)
if /I "%__ARG__%" equ "Release"        (set "MAKER_BUILD_TYPE=release"    &goto :param_loop)
if /I "%__ARG__%" equ "MinSizeRel"     (set "MAKER_BUILD_TYPE=minSizeRel" &goto :param_loop)
if /I "%__ARG__%" equ "Static"         (set "MAKER_BUILD_MODE=static"     &goto :param_loop)
if /I "%__ARG__%" equ "Shared"         (set "MAKER_BUILD_MODE=shared"     &goto :param_loop)
if /I "%__ARG__%" equ "msvs"           (set "MAKER_BUILD_SYSTEM=msvs"     &goto :param_loop)
if /I "%__ARG__%" equ "gnu"            (set "MAKER_BUILD_SYSTEM=gnu"      &goto :param_loop)
if /I "%__ARG__%" equ "gcc"            (set "MAKER_BUILD_SYSTEM=gnu"      &goto :param_loop)
rem support build system given as switch:
if /I "%__ARG__%" equ "--msvs"         (set "MAKER_BUILD_SYSTEM=msvs"     &goto :param_loop)
if /I "%__ARG__%" equ "--gnu"          (set "MAKER_BUILD_SYSTEM=gnu"      &goto :param_loop)
if /I "%__ARG__%" equ "--gcc"          (set "MAKER_BUILD_SYSTEM=gnu"      &goto :param_loop)
rem handle known build config args:
if /I "%__ARG__%" equ "ms86"           (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "ms86d"          (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "ms86m"          (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "ms86ds"         (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "ms86ms"         (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "ms86s"          (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "ms64"           (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "ms64d"          (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "ms64m"          (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "ms64ds"         (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "ms64ms"         (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "ms64s"          (set "MAKER_BUILD_SYSTEM=msvs" &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "gn86"           (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "gn86"           (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "gn86d"          (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "gn86m"          (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "gn86ds"         (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "gn86ms"         (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "gn86s"          (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x86" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "gn64"           (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "gn64d"          (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "gn64m"          (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=shared" &goto :param_loop)
if /I "%__ARG__%" equ "gn64ds"         (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=debug"      &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "gn64ms"         (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=minSizeRel" &set "MAKER_BUILD_MODE=static" &goto :param_loop)
if /I "%__ARG__%" equ "gn64s"          (set "MAKER_BUILD_SYSTEM=gnu"  &set "MAKER_BUILD_ARCH=x64" &set "MAKER_BUILD_TYPE=release"    &set "MAKER_BUILD_MODE=static" &goto :param_loop)
rem handle unknown switches:
if /I "%__ARG__%" equ "--"             (echo empty switch '--' &goto :param_loop)
if /I "%__ARG__%" equ "-"              (echo empty switch '-' &goto :param_loop)
if /I "%__ARG__:~0,1%" equ "-" (set "MAKER_UNKNOWN_SWITCHES=%MAKER_UNKNOWN_SWITCHES% %__ARG_RAW__%" &goto :param_loop)
if /I "!__ARG__:~0,1!" equ "-" (set "MAKER_UNKNOWN_SWITCHES=%MAKER_UNKNOWN_SWITCHES% !__ARG_RAW__!" &goto :param_loop)
rem handle known free args:
if /I "%__ARG__%" neq "" if "%MAKER_VERSION%" equ "" (set "MAKER_VERSION=%__ARG__%" &goto :param_loop)
rem handle unknown args:
if /I "%__ARG__%" neq "" (set "MAKER_UNKNOWN_ARGS=%MAKER_UNKNOWN_ARGS% %__ARG_RAW__%" &goto :param_loop)
:param_loop_exit
set __ARG__=
set __ARG_RAW__=

rem build config postprocessing
if "%MAKER_BUILD_ARCH%"   equ "" set MAKER_BUILD_ARCH=x64
if "%MAKER_BUILD_TYPE%"   equ "" set MAKER_BUILD_TYPE=release
if "%MAKER_BUILD_MODE%"   equ "" set MAKER_BUILD_MODE=shared
if "%MAKER_BUILD_SYSTEM%" equ "" set MAKER_BUILD_SYSTEM=msvs
rem if "%MAKER_BUILD_SYSTEM%" equ "" set MAKER_BUILD_SYSTEM=gnu

set "MAKER_BUILD_INFO=^(%MAKER_BUILD_SYSTEM% %MAKER_BUILD_ARCH% %MAKER_BUILD_TYPE% %MAKER_BUILD_MODE%^)"

set "MAKER_BUILD_CONFIG=%MAKER_BUILD_SYSTEM:~0,2%%MAKER_BUILD_ARCH:~-2%"
if /I "%MAKER_BUILD_TYPE%" neq "release" set "MAKER_BUILD_CONFIG=%MAKER_BUILD_CONFIG%%MAKER_BUILD_TYPE:~0,1%"
rem if /I "%MAKER_BUILD_MODE%" neq "shared"  set "MAKER_BUILD_CONFIG=%MAKER_BUILD_CONFIG%%MAKER_BUILD_MODE:~0,2%"
if /I "%MAKER_BUILD_MODE%" neq "shared"  set "MAKER_BUILD_CONFIG=%MAKER_BUILD_CONFIG%s"

rem if "%MAKER_BUILD_SYSTEM%" neq "" set "MAKER_BUILD_SYSTEM_SWITCH=--%MAKER_BUILD_SYSTEM%"
rem set "MAKER_ALL_ARGS=%MAKER_VERSION% %MAKER_UNKNOWN_ARGS% %MAKER_BUILD_TYPE% %MAKER_BUILD_MODE% %MAKER_BUILD_ARCH% %MAKER_BUILD_SYSTEM%"

rem split unknonw args and switches
:split_unknown_args
if "%MAKER_UNKNOWN_ARGS%" equ "" goto :split_unknown_switches
SETLOCAL ENABLEDELAYEDEXPANSION
echo @echo off>"%TEMP%\_split_free_args.bat"
set _MAKER_ARG_ASSIGNED=
for %%j in (%MAKER_UNKNOWN_ARGS%) do set _MAKER_ARG_ASSIGNED=&for /L %%i in (1,1,10) do if "!_MAKER_ARG_ASSIGNED!" equ "" if "!MAKER_UNKNOWN_ARG_%%i!" equ "" set "MAKER_UNKNOWN_ARG_%%i=%%~j" &set _MAKER_ARG_ASSIGNED=done &echo set "MAKER_UNKNOWN_ARG_%%i=%%~j">>"%TEMP%\_split_free_args.bat"
rem if "%MAKER_MSG_VERBOSE%" neq "" set MAKER_UNKNOWN_ARG
ENDLOCAL
call "%TEMP%\_split_free_args.bat"
del "%TEMP%\_split_free_args.bat"
:split_unknown_switches
if "%MAKER_UNKNOWN_SWITCHES%" equ "" goto :exit
SETLOCAL ENABLEDELAYEDEXPANSION
set _MAKER_ARG_ASSIGNED=
for %%j in (%MAKER_UNKNOWN_SWITCHES%) do set _MAKER_ARG_ASSIGNED=&for /L %%i in (1,1,10) do if "!_MAKER_ARG_ASSIGNED!" equ "" if "!MAKER_UNKNOWN_SWITCH_%%i!" equ "" set "MAKER_UNKNOWN_SWITCH_%%i=%%~j" &set _MAKER_ARG_ASSIGNED=done &echo set "MAKER_UNKNOWN_SWITCH_%%i=%%~j">>"%TEMP%\_split_free_args.bat"
rem if "%MAKER_MSG_VERBOSE%" neq "" set MAKER_UNKNOWN_SWITCH
ENDLOCAL
call "%TEMP%\_split_free_args.bat"
del "%TEMP%\_split_free_args.bat"

:exit
call "%MAKER_ENV_CORE%\set_version_env.bat" "MAKER" "%MAKER_VERSION%"
if "%MAKER_MSG_SILENT%" neq "" goto :EOF
rem list env:
rem if "%MAKER_MSG_VERBOSE%" neq "" (set MAKER_V&set MAKER_R&set MAKER_H&set MAKER_ENV&set MAKER_MSG&set MAKER_BUILD&set MAKER_ALL&set MAKER_UNK)
if "%MAKER_MSG_VERBOSE%" neq "" set MAKER_

rem show help:
if "%MAKER_HELP%" neq "" (
  echo.
  echo MAKER_ENV [switches] [version] [build_type] [build_mode] [architecture] [free_args] [free_switches]
  echo switches:
  echo   --no_errors   ^| -ne
  echo   --no_warnings ^| -nw
  echo   --no_infos    ^| -ni
  echo   --verbose     ^| -v
  echo   --silent      ^| -s
  echo   --rebuild     ^| -r
  echo   --help        ^| -h ^| -?
  echo version:
  echo   any-version-nr
  echo build_type:
  echo   Debug ^| Release ^| MinSizeRel
  echo build_mode:
  echo   Shared ^| Static
  echo architecture:
  echo   x86 ^| x64 ^| amd64
)
