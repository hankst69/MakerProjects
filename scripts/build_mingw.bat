@echo off
call "%~dp0\maker_env.bat" %*
set "_BMGW_START_DIR=%cd%"

rem init with command line arguments
set "_MGW_VERSION=%MAKER_ENV_VERSION%"
set "_MGW_BUILD_TYPE=%MAKER_ENV_BUILDTYPE%"
set "_MGW_TGT_ARCH=%MAKER_ENV_ARCHITECTURE%"

rem apply defaults
rem if "%_MGW_VERSION%"    equ "" set _MGW_VERSION=2.4.1
set _MGW_BUILD_TYPE=Release
set _MGW_TGT_ARCH=x64

rem take shortcut if possible
call "%MAKER_BUILD%\validate_mingw.bat" %_MGW_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on

rem a) install via unzip from:
rem    https://winlibs.com/
rem    https://github.com/brechtsanders/winlibs_mingw/releases/download/14.2.0posix-19.1.1-12.0.0-ucrt-r2/winlibs-x86_64-posix-seh-gcc-14.2.0-mingw-w64ucrt-12.0.0-r2.7z
rem    https://github.com/brechtsanders/winlibs_mingw
rem set "_MGW_BIN_DIR=%MAKER_BIN%\mingw"


rem b) install using choco install mingw:
rem see .choco\lib-bad\mingw\13.2.0\tools\chocolateyinstall.ps1 
rem   -> 'C:\ProgramData\mingw64' (hardcoded path)
rem   -> Install-ChocolateyPath cmdlet issue (this choco cmdlet is missing)
set "_MGW_BIN_DIR=C:\ProgramData\mingw64"
set "_MGW_BIN_BIN_DIR=C:\ProgramData\mingw64\mingw64\bin"
if exist "%_MGW_BIN_BIN_DIR%\gcc.exe" goto :win_MGW_installed
call "%MAKER_BUILD%\ensure_choco.bat"
if %ERRORLEVEL% NEQ 0 (
  echo error: CHOCO is not available
  goto :exit_script
)
call choco install mingw --yes --force
if not exist "%_MGW_BIN_BIN_DIR%\gcc.exe" (
  echo. error: install MinGW failed
  goto :exit_script
)
:win_MGW_installed
rem goto :test_MGW_succes


:test_MGW_succes
call "%MAKER_BUILD%\validate_mingw.bat" %_MGW_VERSION% 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
set "Path=%_MGW_BIN_BIN_DIR%;%Path%"

:exit_script
if "%MAKER_ENV_VERBOSE%" neq "" echo on
cd /d "%_BMGW_START_DIR%"
set _BMGW_START_DIR=
call "%MAKER_BUILD%\validate_mingw.bat" %_MGW_VERSION% %MAKER_ENV_VERBOSE%