@rem https://emscripten.org/docs/getting_started/downloads.html
@echo off
set "_MAKER_ROOT=%~dp0"
set "_EMSDK_DIR=%_MAKER_ROOT%tools\Emsdk"

rem set _EMSDK_VERSION=1.38.45
rem set _EMSDK_VERSION=3.1.67 (current latest as of 2024/09)
set _EMSDK_VERSION=latest
if "%~1" neq "" set "_EMSDK_VERSION=%~1"

set "_EMSDK_BIN_DIR=%_EMSDK_DIR%\%_EMSDK_VERSION%"

rem if not exist "%_EMSDK_DIR%" mkdir "%_EMSDK_DIR%"
rem if not exist "%_EMSDK_BIN_DIR%" mkdir "%_EMSDK_BIN_DIR%"

call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_EMSDK_BIN_DIR%" "https://github.com/emscripten-core/emsdk.git" --changeDir

