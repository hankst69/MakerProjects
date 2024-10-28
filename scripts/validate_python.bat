@echo off
set "_SCRIPT_ROOT=%~dp0"
set PYTHON_ARCHITECTURE=
set PYTHON_EXE=
set PYTHON_VERSION=
set PYTHON_VERSION_MAJOR=
set PYTHON_VERSION_MINOR=
set PYTHON_VERSION_PATCH=

set _TGT_ARCHITECTURE=
set _TGT_VERSION=
set _TGT_VERSION_COMPARE=
set _PYTHON_NO_WARNINGS=
set _PYTHON_NO_ERRORS=
set _PYTHON_NO_INFO=
:param_loop
if /I "%~1" equ "x86"   (set "_TGT_ARCHITECTURE=x86" &shift &goto :param_loop)
if /I "%~1" equ "x64"   (set "_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "amd64" (set "_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "--no_warnings" (set "_PYTHON_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_PYTHON_NO_ERRORS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_info"     (set "_PYTHON_NO_INFO=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_TGT_VERSION%" equ "" (set "_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo warning: unknown argument '%~1' &shift &goto :param_loop)

if "%_TGT_VERSION%" equ "" goto :validate_python
if /I "%_TGT_VERSION:~0,3%" equ "GEQ" set "_TGT_VERSION_COMPARE=GEQ"
if /I "%_TGT_VERSION:~0,3%" equ "GEQ" set "_TGT_VERSION=%_TGT_VERSION:~3%"
if /I "%_TGT_VERSION:~0,3%" equ "GTR" set "_TGT_VERSION_COMPARE=GTR"
if /I "%_TGT_VERSION:~0,3%" equ "GTR" set "_TGT_VERSION=%_TGT_VERSION:~3%"
if /I "%_TGT_VERSION:~0,3%" equ "LEQ" set "_TGT_VERSION_COMPARE=LEQ"
if /I "%_TGT_VERSION:~0,3%" equ "LEQ" set "_TGT_VERSION=%_TGT_VERSION:~3%"
if /I "%_TGT_VERSION:~0,3%" equ "LSS" set "_TGT_VERSION_COMPARE=LSS"
if /I "%_TGT_VERSION:~0,3%" equ "LSS" set "_TGT_VERSION=%_TGT_VERSION:~3%"

:validate_python
rem test for python available
set _PYTHON_EXE=
for /f "tokens=1,2 delims= " %%i in ('call which python.exe') do set "_PYTHON_EXE=%%~i"
if /I "%_PYTHON_EXE%" EQU "%USERPROFILE%\AppData\Local\Microsoft\WindowsApps\python.exe" goto :test_python_setup_required
set _PYTHON_EXE=
call which python.exe 1>nul 2>nul
if %ERRORLEVEL% EQU 0 goto :test_python_available
if "%_PYTHON_NO_ERRORS%" equ "" echo error: python is not available
exit /b 1

:test_python_setup_required
if "%_PYTHON_NO_ERRORS%" equ "" echo error: python is not available (only windows dummy redirecting to app store)
exit /b 2

:test_python_available
rem python is available -> we detect Python Exe, Version and Architecture
set PYTHON_EXE=
for /f "tokens=1,2 delims= " %%i in ('call which python.exe') do set "PYTHON_EXE=%%~i"
set PYTHON_VERSION=
for /f "tokens=1,2 delims= " %%i in ('call python --version') do set "PYTHON_VERSION=%%j"
set PYTHON_ARCHITECTURE=x86
for /f %%i in ('call python -c "import sys;print(f""{sys.maxsize > 2**32}"")"') do if /I "%%~i" equ "True" set PYTHON_ARCHITECTURE=x64

:split_python_version
call "%_SCRIPT_ROOT%split_version.bat" "%PYTHON_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_python_version_ok
if "%_PYTHON_NO_ERRORS%" equ "" echo error: PYTHON version '%PYTHON_VERSION%' not available or invalid
exit /b 3

:split_python_version_ok
set "PYTHON_VERSION_MAJOR=%VERSION_MAJOR%"
set "PYTHON_VERSION_MINOR=%VERSION_MINOR%"
set "PYTHON_VERSION_PATCH=%VERSION_PATCH%"

:test_python_version
if "%_TGT_VERSION%" equ "" goto :test_python_architecture
call "%_SCRIPT_ROOT%compare_versions.bat" "%PYTHON_VERSION%" "%_TGT_VERSION%" "%_TGT_VERSION_COMPARE%" --no_info
if "%ERRORLEVEL%" equ "0" goto :test_python_architecture
if "%_PYTHON_NO_ERRORS%" equ "" echo error: PYTHON version '%PYTHON_VERSION%' does not match required version '%_TGT_VERSION%'
exit /b 4

:test_python_architecture
if "%_TGT_ARCHITECTURE%" equ "" goto :test_python_success
if /I "%PYTHON_ARCHITECTURE%" equ "%_TGT_ARCHITECTURE%" goto :test_python_success
if "%_PYTHON_NO_ERRORS%" equ "" echo error: PYTHON architecture '%PYTHON_ARCHITECTURE%' does not match required type '%_TGT_ARCHITECTURE%'
exit /b 5

:test_python_success
if "%_PYTHON_NO_INFO%" equ "" echo using: python %PYTHON_VERSION% %PYTHON_ARCHITECTURE%
rem set PYTHON_ARCHITECTURE=
rem set PYTHON_EXE=
rem set PYTHON_VERSION=
rem set PYTHON_VERSION_MAJOR=
rem set PYTHON_VERSION_MINOR=
rem set PYTHON_VERSION_PATCH=
set _TGT_ARCHITECTURE=
set _TGT_VERSION=
set _TGT_VERSION_COMPARE=
set _PYTHON_NO_WARNINGS=
set _PYTHON_NO_ERRORS=
set _PYTHON_NO_INFO=
set _SCRIPT_ROOT=
exit /b 0
