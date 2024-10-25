@echo off

rem validate python
set PYTHON_EXE=
set PYTHON_VERSION=
set PYTHON_ARCHITECTURE=

rem test for python available
set _PYTHON_EXE=
for /f "tokens=1,2 delims= " %%i in ('call which python.exe') do set "_PYTHON_EXE=%%~i"
if /I "%_PYTHON_EXE%" EQU "%USERPROFILE%\AppData\Local\Microsoft\WindowsApps\python.exe" goto :test_python_setup_required
set _PYTHON_EXE=
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_available
echo error: python is not available
exit /b 1

:test_python_setup_required
echo error: python is not available (only windows dummy redirecting to app store)
exit /b 2

:test_python_available
rem python is available -> we detect Python Exe, Version and Architecture
set PYTHON_EXE=
for /f "tokens=1,2 delims= " %%i in ('call which python.exe') do set "PYTHON_EXE=%%~i"
set PYTHON_VERSION=
for /f "tokens=1,2 delims= " %%i in ('call python --version') do set "PYTHON_VERSION=%%j"
set PYTHON_ARCHITECTURE=x86
for /f %%i in ('call python -c "import sys;print(f""{sys.maxsize > 2**32}"")"') do if /I "%%~i" equ "True" set PYTHON_ARCHITECTURE=x64
echo using: python %PYTHON_VERSION% %PYTHON_ARCHITECTURE%

:test_python_matches
rem compare python versin and python architecture against requirements

rem todo read cmd args and compare
rem exir /b 3

:test_python_success
exit /b 0
