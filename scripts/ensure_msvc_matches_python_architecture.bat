@echo off
set "_SCRIPT_ROOT=%~dp0"
rem set "_MAKER_ROOT=%~dp0.."

rem validate msvs
call "%_SCRIPT_ROOT%\validate_msvs.bat" 1>nul
if "%ERRORLEVEL%" equ "0" goto :test_msvs_version_ok
echo error: MSVS not available
exit /b 1

:test_msvs_version_ok
call "%_SCRIPT_ROOT%\validate_python.bat" 1>nul
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%PYTHON_ARCHITECTURE%" goto :test_msvs_success

echo warning: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but PYTHON requires %PYTHON_ARCHITECTURE% - switching MSVS
set _MSVS_TGT_ARCH=x86
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "x64" set "_MSVS_TGT_ARCH=amd64"
call vsdevcmd -arch=%_MSVS_TGT_ARCH%
set _MSVS_TGT_ARCH=

set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%PYTHON_ARCHITECTURE%" goto :test_msvs_success
echo error: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but PYTHON requires %PYTHON_ARCHITECTURE%
exit /b 2

:test_msvs_success
echo using: msvs %MSVS_VERSION% (VS%VSCMD_VER:~0,2%) for %MSVS_TARGET_ARCHITECTURE%  (matching python %PYTHON_VERSION% %PYTHON_ARCHITECTURE%)
exit /b 0


goto :EOF
set _MSVS_VER=
if "%VSCMD_VER:~0,2%" equ "16" (set "_MSVS_VER=2019" &goto :test_msvs_version_ok)
if "%VSCMD_VER:~0,2%" equ "17" (set "_MSVS_VER=2022" &goto :test_msvs_version_ok)
echo error: MSVS not available
goto :EOF
:test_msvs_version_ok
set _MSVS_TGT=x86
if /I "%VSCMD_ARG_TGT_ARCH%" equ "x64" (set "_MSVS_TGT=amd64" &goto :test_msvs_success)
echo warning: MSVS uses wrong target architecture %_MSVS_TGT% - switching to 'amd64'
call vsdevcmd -arch=amd64
if /I "%VSCMD_ARG_TGT_ARCH%" equ "x64" (set "_MSVS_TGT=amd64" &goto :test_msvs_success)
echo error: MSVS uses wrong target architecture %_MSVS_TGT%
:test_msvs_success
echo using: msvs %_MSVS_VER% (VS%VSCMD_VER:~0,2%) for %_MSVS_TGT%
set _MSVS_VER=
set _MSVS_TGT=

