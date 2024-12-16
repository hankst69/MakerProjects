@echo off
call "%~dp0\maker_env.bat"

set _VERSION=
set _REBUILD=
set _BUILD_TYPE=
:param_loop
if "%~1" equ "" goto :param_loop_exit
set "_ARG_=%~1"
if /I "%~1" equ "--rebuild"  (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "-r"         (set "_REBUILD=true" &shift &goto :param_loop)
if /I "%~1" equ "Debug"      (set "_BUILD_TYPE=%~1" &shift &goto :param_loop)
if /I "%~1" equ "Release"    (set "_BUILD_TYPE=%~1" &shift &goto :param_loop)
if /I "%_ARG_:~0,1%" equ "-" (echo unknown switch '%~1' &shift &goto :param_loop)
if /I "!_ARG_:~0,1!" equ "-" (echo unknown switch '%~1' &shift &goto :param_loop)
if "%~1" neq "" if "%_VERSION%" equ "" (set "_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo error: unknown argument '%~1' &shift &goto :param_loop)
:param_loop_exit
set _ARG_=

set "_BISON_VERSION=%_VERSION%"
set "_BISON_BUILD_TYPE=%_BUILD_TYPE%"
rem apply defaults
if "%_BISON_VERSION%" equ "" set _BISON_VERSION=2.4.1
if "%_BISON_BUILD_TYPE%" equ "" set _BISON_BUILD_TYPE=Release
set "_BISON_TGT_ARCH=x64"

set "_BISON_DIR=%MAKER_TOOLS%\Bison"
set "_BISON_BIN_DIR=%_BISON_DIR%\bison-%_BISON_VERSION%"

if exist "%_BISON_BIN_DIR%\bin\bison.exe" goto :validate

rem todo: unzip bison into %_BISON_DIR%
if not exist "%_BISON_BIN_DIR%\bin\bison.exe" goto :Exit

:validate
call "%MAKER_SCRIPTS%\validate_bison.bat" %_BISON_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
set PATH=%PATH%;"%_BISON_BIN_DIR%\bin"

:Exit
cd "%_BISON_DIR%"
call "%MAKER_SCRIPTS%\validate_llvm.bat" --no_errors
