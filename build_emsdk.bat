@echo off
set "_MAKER_ROOT=%~dp0"
rem https://emscripten.org/docs/getting_started/downloads.html

set "_EMSDK_DIR=%_MAKER_ROOT%Emsdk"
if not exist "%_EMSDK_DIR%" mkdir "%_EMSDK_DIR%"

rem set _EMSDK_VERSION=1.38.45
rem set _EMSDK_VERSION=3.1.67 (current latest as of 2024/09)
set _EMSDK_VERSION=latest
if "%~1" neq "" set "_EMSDK_VERSION=%~1"

set "_EMSDK_BIN_DIR=%_EMSDK_DIR%\%_EMSDK_VERSION%"
if not exist "%_EMSDK_BIN_DIR%" mkdir "%_EMSDK_BIN_DIR%"

pushd "%_MAKER_ROOT%"
call "%_MAKER_ROOT%\scripts\clone_in_folder.bat" "%_EMSDK_BIN_DIR%" "https://github.com/emscripten-core/emsdk.git"
echo.
popd

rem test python
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_success
echo error: python is not available
goto :EOF
:test_python_success


pushd "%_EMSDK_BIN_DIR%"
if exist "%_EMSDK_BIN_DIR%\upstream\emscripten\emcc.bat" echo EMSDK %_EMSDK_VERSION% INSTALL already done &goto :emsdk_install_done

rem # Fetch the latest version of the emsdk (not needed the first time you clone)
call git pull

rem # Download and install the latest SDK tools.
call emsdk.bat install %_EMSDK_VERSION%

:emsdk_install_done
rem # Make the SDK "active" for the current user. (writes .emscripten file)
call emsdk.bat activate %_EMSDK_VERSION%
popd

set "LLVM_INSTALL_DIR=%_EMSDK_BIN_DIR%\upstream\bin"

cd "%_EMSDK_BIN_DIR%"