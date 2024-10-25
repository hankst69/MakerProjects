@echo off
set "_MAKER_ROOT=%~dp0.."

rem validate msvs
set MSVS_VERSION=
set MSVS_TARGET_ARCHITECTURE=

if "%VSCMD_VER:~0,2%" equ "16" (set "MSVS_VERSION=2019" &goto :test_msvs_version_ok)
if "%VSCMD_VER:~0,2%" equ "17" (set "MSVS_VERSION=2022" &goto :test_msvs_version_ok)
echo error: MSVS not available
exit /b 1

:test_msvs_version_ok
set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"

rem set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"
rem if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%PYTHON_ARCHITECTURE%" goto :test_msvs_success
rem echo error: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but PYTHON requires %PYTHON_ARCHITECTURE%
rem exit /b 2

:test_msvs_success
echo using: msvs %MSVS_VERSION% (VS%VSCMD_VER:~0,2%) for %MSVS_TARGET_ARCHITECTURE%
rem set MSVS_VERSION=
rem set MSVS_TARGET_ARCHITECTURE=
exit /b 0
