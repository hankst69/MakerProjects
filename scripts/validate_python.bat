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


:validate_python_existence_and_verion
call "%~dp0\validate.bat" "PYTHON" "python --version" "for /f ""tokens=1,2 delims= "" %%%%i in ('call python --version') do echo %%%%j" %_TGT_VERSION% --no_info %_PYTHON_NO_WARNINGS% %_PYTHON_NO_ERRORS%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
rem current validate.bat problem:
rem C:\GIT\Maker\scripts>validate_python.bat GTR3.8.9
rem error 8_compare: version compare failed, requirement '3.8.10 GTR 3.8.9' not met
rem error 7_validate: PYTHON version '3.8.10' does not match required version '3.8.9'

:validate_python_exe
set PYTHON_EXE=
for /f "tokens=1,2 delims= " %%i in ('call which python.exe') do set "PYTHON_EXE=%%~i"
if /I "%PYTHON_EXE%" EQU "%USERPROFILE%\AppData\Local\Microsoft\WindowsApps\python.exe" goto :test_python_setup_required
goto :validate_python_exe_ok
:test_python_setup_required
if "%_PYTHON_NO_ERRORS%" equ "" echo error: PYTHON is not available (only windows dummy redirecting to app store)
exit /b 2
:validate_python_exe_ok


:validate_python_architecture
set PYTHON_ARCHITECTURE=x86
for /f %%i in ('call python -c "import sys;print(f""{sys.maxsize > 2**32}"")"') do if /I "%%~i" equ "True" set PYTHON_ARCHITECTURE=x64

if "%_TGT_ARCHITECTURE%" equ "" goto :validate_python_success
if /I "%PYTHON_ARCHITECTURE%" equ "%_TGT_ARCHITECTURE%" goto :validate_python_success
if "%_PYTHON_NO_ERRORS%" equ "" echo error: PYTHON architecture '%PYTHON_ARCHITECTURE%' does not match required type '%_TGT_ARCHITECTURE%'
exit /b 5

:validate_python_success
if "%_PYTHON_NO_INFO%" equ "" echo using: PYTHON %PYTHON_VERSION% %PYTHON_ARCHITECTURE%
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
