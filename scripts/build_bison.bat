@echo off
call "%~dp0\maker_env.bat" %*

if "%MAKER_ENV_VERBOSE%" neq "" echo on

set "_BISON_VERSION=%MAKER_ENV_VERSION%"
set "_BISON_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_BISON_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"

rem apply defaults
if "%_BISON_VERSION%"    equ "" set _BISON_VERSION=2.4.1
if "%_BISON_BUILD_TYPE%" equ "" set _BISON_BUILD_TYPE=Release
set "_BISON_TGT_ARCH=x64"

set "_BISON_DIR=%MAKER_TOOLS%\Bison"
set "_BISON_BIN_DIR=%_BISON_DIR%\bison-%_BISON_VERSION%"

if exist "%_BISON_BIN_DIR%\bin\bison.exe" goto :validate

rem build/install bison:
rem todo: unzip bison into %_BISON_DIR%
rem if not exist "%_BISON_BIN_DIR%" mkdir "%_BISON_BIN_DIR%"
if not exist "%_BISON_BIN_DIR%\bin\bison.exe" goto :Exit

:validate
call "%MAKER_BUILD%\validate_bison.bat" %_BISON_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :Exit
set PATH=%PATH%;"%_BISON_BIN_DIR%\bin"

:Exit
if exist "%_BISON_BIN_DIR%" cd "%_BISON_DIR%"
call "%MAKER_BUILD%\validate_bison.bat" --no_errors
