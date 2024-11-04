@echo off
set "_EMSVS_SCRIPTS_DIR=%~dp0"

set _EMSVS_TGT_ARCHITECTURE=
set _EMSVS_TGT_VERSION=
set _EMSVS_NO_WARNINGS=
set _EMSVS_NO_ERRORS=
set _EMSVS_NO_INFO=
:param_loop
if /I "%~1" equ "x86"   (set "_EMSVS_TGT_ARCHITECTURE=x86" &shift &goto :param_loop)
if /I "%~1" equ "x64"   (set "_EMSVS_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "amd64" (set "_EMSVS_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "--no_warnings" (set "_EMSVS_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_EMSVS_NO_ERRORS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_info"     (set "_EMSVS_NO_INFO=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_TGT_VERSION%" equ "" (set "_EMSVS_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq ""         (echo warning: unknown argument '%~1' &shift &goto :param_loop)

if "%_EMSVS_TGT_ARCHITECTURE%" neq "" goto :test_msvs
if "%_EMSVS_NO_ERRORS%" equ "" echo error: no target architecture specified in command line arguments
exit /b 1

:test_msvs
rem validate msvs
call "%_EMSVS_SCRIPTS_DIR%\validate_msvs.bat" %_EMSVS_TGT_VERSION% 1>nul
if "%ERRORLEVEL%" equ "0" goto :test_EMSVS_version_ok
if "%_EMSVS_NO_ERRORS%" equ "" echo error: MSVS %_EMSVS_TGT_VERSION% not available
exit /b 2

:test_EMSVS_version_ok
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%_EMSVS_TGT_ARCHITECTURE%" goto :test_EMSVS_success

:switch_EMSVS_env
if "%_EMSVS_NO_WARNINGS%" equ "" echo warning: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but requirement is %_EMSVS_TGT_ARCHITECTURE% - switching MSVS
set _EMSVS_TGT_ARCH=x86
if /I "%_EMSVS_TGT_ARCHITECTURE%" equ "x64" set "_EMSVS_TGT_ARCH=amd64"
call vsdevcmd -arch=%_EMSVS_TGT_ARCH%
set _EMSVS_TGT_ARCH=
set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"

if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%_EMSVS_TGT_ARCHITECTURE%" goto :test_EMSVS_success
if "%_NO_ERRORS%" equ "" echo error: MSVS uses target architecture %MSVS_TARGET_ARCHITECTURE% but requirement is %_EMSVS_TGT_ARCHITECTURE%
exit /b 3

:test_EMSVS_success
if "%_EMSVS_NO_INFO%" equ "" echo using: msvs %MSVS_VERSION% (VS%VSCMD_VER:~0,2%) for %MSVS_TARGET_ARCHITECTURE%
set _EMSVS_SCRIPTS_DIR=
set _EMSVS_TGT_ARCHITECTURE=
set _EMSVS_TGT_VERSION=
set _EMSVS_NO_WARNINGS=
set _EMSVS_NO_ERRORS=
set _EMSVS_NO_INFO=
exit /b 0
