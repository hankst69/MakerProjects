@echo off
set "_SCRIPT_ROOT=%~dp0"

rem validate msvs
call "%_SCRIPT_ROOT%\validate_msvs.bat" 1>nul
if "%ERRORLEVEL%" equ "0" goto :_msvs_available
echo error: MSVS not available
exit /b 1

:_msvs_available
call "%_SCRIPT_ROOT%\validate_python.bat" 1>nul
if "%ERRORLEVEL%" equ "0" goto :_python_available
echo error: PYTHON not available
exit /b 2

:_python_available
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%PYTHON_ARCHITECTURE%" goto :_msvs_matches_python

:msvs_differs_python
echo warning: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but PYTHON requires %PYTHON_ARCHITECTURE% - switching MSVS
set _MSVS_TGT_ARCH=x86
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "x64" set "_MSVS_TGT_ARCH=amd64"
call vsdevcmd -arch=%_MSVS_TGT_ARCH%
set _MSVS_TGT_ARCH=

set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%PYTHON_ARCHITECTURE%" goto :_msvs_matches_python
echo error: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but PYTHON requires %PYTHON_ARCHITECTURE%
exit /b 3

:_msvs_matches_python
echo using: msvs %MSVS_VERSION% (VS%VSCMD_VER:~0,2%) for %MSVS_TARGET_ARCHITECTURE%  (matching python %PYTHON_VERSION% %PYTHON_ARCHITECTURE%)
exit /b 0
