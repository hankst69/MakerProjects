@echo off
set "_SCRIPT_ROOT=%~dp0"

set _TGT_ARCHITECTURE=
set _TGT_VERSION=
set _NO_WARNINGS=
set _NO_ERRORS=
:param_loop
if /I "%~1" equ "x86"   (set "_TGT_ARCHITECTURE=x86" &shift &goto :param_loop)
if /I "%~1" equ "x64"   (set "_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "amd64" (set "_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "--no_warnings" (set "_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_NO_ERRORS=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_TGT_VERSION%" equ "" (set "_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq ""         (echo warning: unknown argument '%~1' &shift &goto :param_loop)

if "%_TGT_ARCHITECTURE%" neq "" goto :test_msvs
if "%_NO_ERRORS%" equ "" echo error: no target architecture specified in command line arguments
exit /b 3

:test_msvs
rem validate msvs
call "%_SCRIPT_ROOT%\validate_msvs.bat" %_TGT_VERSION% 1>nul
if "%ERRORLEVEL%" equ "0" goto :test_msvs_version_ok
if "%_NO_ERRORS%" equ "" echo error: MSVS not available
exit /b 1

:test_msvs_version_ok
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%_TGT_ARCHITECTURE%" goto :test_msvs_success

:switch_msvs_env
if "%_NO_WARNINGS%" equ "" echo warning: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but PYTHON requires %PYTHON_ARCHITECTURE% - switching MSVS
set _MSVS_TGT_ARCH=x86
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "x64" set "_MSVS_TGT_ARCH=amd64"
call vsdevcmd -arch=%_MSVS_TGT_ARCH%
set _MSVS_TGT_ARCH=
set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"

if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%_TGT_ARCHITECTURE%" goto :test_msvs_success
if "%_NO_ERRORS%" equ "" echo error: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but PYTHON requires %PYTHON_ARCHITECTURE%
exit /b 2

:test_msvs_success
echo using: msvs %MSVS_VERSION% (VS%VSCMD_VER:~0,2%) for %MSVS_TARGET_ARCHITECTURE%
exit /b 0
