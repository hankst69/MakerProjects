@echo off
call "%~dp0\maker_env.bat" %*
set "_BGCC_START_DIR=%cd%"
rem init with command line arguments
set "_GCC_VERSION=%MAKER_ENV_VERSION%"
set "_GCC_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_GCC_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"

rem apply defaults
rem if "%_GCC_VERSION%"    equ "" set _GCC_VERSION=2.4.1
set _GCC_BUILD_TYPE=Release
set _GCC_TGT_ARCH=x64

rem take shortcut if possible
call "%MAKER_BUILD%\validate_gcc.bat" %_GCC_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on

call "%~dp0\build_mingw.bat" %* --no_info

:test_GCC_succes
call "%MAKER_BUILD%\validate_gcc.bat" %_GCC_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
set "Path=%_GCC_BIN_BIN_DIR%;%Path%"

:exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
cd /d "%_BGCC_START_DIR%"
set _BGCC_START_DIR=
call "%MAKER_BUILD%\validate_gcc.bat" %_GCC_VERSION% %MAKER_ENV_VERBOSE%