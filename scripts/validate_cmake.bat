@echo off
rem set "_MAKER_ROOT=%~dp0.."

rem validate cmake
set CMAKE_VERSION=

rem test for cmake available
call which cmake.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_cmake_success
echo error: CMAKE is not available
exit /b 1

:test_cmake_success
set CMAKE_VERSION=
for /f "tokens=1-3 delims= " %%i in ('call cmake --version') do if /I "%%j" EQU "version" set "CMAKE_VERSION=%%k"
echo using: cmake %CMAKE_VERSION%
exit /b 0