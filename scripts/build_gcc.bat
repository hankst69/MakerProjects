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

rem a) install via unzip from:
rem    https://github.com/brechtsanders/winlibs_mingw/releases/download/14.2.0posix-19.1.1-12.0.0-ucrt-r2/winlibs-x86_64-posix-seh-gcc-14.2.0-mingw-w64ucrt-12.0.0-r2.7z
rem set "_GCC_BIN_DIR=%MAKER_BIN%\mingw"


rem b) install using choco install mingw:
set "_GCC_BIN_DIR=C:\ProgramData\mingw64"
set "_GCC_BIN_BIN_DIR=C:\ProgramData\mingw64\mingw64\bin"
if exist "%_GCC_BIN_BIN_DIR%\gcc.exe" goto :win_GCC_installed
call "%MAKER_BUILD%\ensure_choco.bat"
if %ERRORLEVEL% NEQ 0 (
  echo error: CHOCO is not available
  goto :exit_script
)
call choco install mingw --yes --force
if not exist "%_GCC_BIN_BIN_DIR%\gcc.exe" (
  echo. error: install GCC failed
  goto :exit_script
)
:win_GCC_installed
rem goto :test_GCC_succes


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