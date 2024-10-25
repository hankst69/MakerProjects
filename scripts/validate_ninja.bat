@echo off

rem validate ninja
set NINJA_VERSION=

rem test for ninja available
call which ninja.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_ninja_success
echo error: NINJA is not available
exit /b 1

:test_ninja_success
for /f "tokens=1,* delims= " %%i in ('call ninja --version') do set "NINJA_VERSION=%%i"
echo using: ninja %NINJA_VERSION%
exit /b 0