@echo off
call "%~dp0\maker_env.bat" %*
set PYTHON_EXE=
set PYTHON_VERSION=
set PYTHON_ARCHITECTURE=

call "%MAKER_BUILD%\validate_python.bat" %MAKER_ENV_VERSION% 1>nul
if "%ERRORLEVEL%" equ "0" goto :test_python_success

set "_PY_DIR=%USERPROFILE%\AppData\Local\Programs\Python\Python313"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python313"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python\Python313"
if not exist "%_PY_DIR%\python.exe" goto :python_312
call "%MAKER_SCRIPTS%\compare_versions.bat" 3.13 %MAKER_ENV_VERSION% --no_errors --no_info
if %ERRORLEVEL% equ 0 goto :test_python
:python_312
set "_PY_DIR=%USERPROFILE%\AppData\Local\Programs\Python\Python312"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python312"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python\Python312"
if not exist "%_PY_DIR%\python.exe" goto :python_311
call "%MAKER_SCRIPTS%\compare_versions.bat" 3.12 %MAKER_ENV_VERSION% --no_errors --no_info
if %ERRORLEVEL% equ 0 goto :test_python
:python_311
set "_PY_DIR=%USERPROFILE%\AppData\Local\Programs\Python\Python311"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python311"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python\Python311"
if not exist "%_PY_DIR%\python.exe" goto :python_310
call "%MAKER_SCRIPTS%\compare_versions.bat" 3.11 %MAKER_ENV_VERSION% --no_errors --no_info
if %ERRORLEVEL% equ 0 goto :test_python
:python_310
set "_PY_DIR=%USERPROFILE%\AppData\Local\Programs\Python\Python310"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python310"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python\Python310"
if not exist "%_PY_DIR%\python.exe" goto :python_39
call "%MAKER_SCRIPTS%\compare_versions.bat" 3.10 %MAKER_ENV_VERSION% --no_errors --no_info
if %ERRORLEVEL% equ 0 goto :test_python
:python_39
set "_PY_DIR=%USERPROFILE%\AppData\Local\Programs\Python\Python39"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python39"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python\Python39"
if not exist "%_PY_DIR%\python.exe" goto :python_38
call "%MAKER_SCRIPTS%\compare_versions.bat" 3.9 %MAKER_ENV_VERSION% --no_errors --no_info
if %ERRORLEVEL% equ 0 goto :test_python
:python_38
set "_PY_DIR=%USERPROFILE%\AppData\Local\Programs\Python\Python38"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python38"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python\Python38"
if not exist "%_PY_DIR%\python.exe" goto :python_37
call "%MAKER_SCRIPTS%\compare_versions.bat" 3.8 %MAKER_ENV_VERSION% --no_errors --no_info
if %ERRORLEVEL% equ 0 goto :test_python
:python_37
set "_PY_DIR=%USERPROFILE%\AppData\Local\Programs\Python\Python37"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python37"
if not exist "%_PY_DIR%\python.exe" set "_PY_DIR=C:\Python\Python37"
call "%MAKER_SCRIPTS%\compare_versions.bat" 3.7 %MAKER_ENV_VERSION% --no_errors --no_info
if %ERRORLEVEL% equ 0 goto :test_python
set "_PY_DIR=C:\ProgramData\Anaconda3"


:test_python
if not exist "%_PY_DIR%\python.exe" goto :test_python_failed
set "PATH=%_PY_DIR%\Scripts;%_PY_DIR%;%PATH%"
call "%MAKER_BUILD%\validate_python.bat" %MAKER_ENV_VERSION% 1>nul
if %ERRORLEVEL% equ 0 goto :test_python_success
:test_python_failed
echo error: python %MAKER_ENV_VERSION% not available
exit /b 2

:test_python_success
if "%_PYTHON_NO_INFO%" equ "" echo using: python %PYTHON_VERSION%
exit /b 0
