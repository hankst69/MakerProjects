@echo off
call "%~dp0\maker_env.bat" %*

set "_EMSVS_TGT_ARCHITECTURE=%MAKER_ENV_ARCHITECTURE%"
set "_EMSVS_TGT_VERSION=%MAKER_ENV_VERSION%"
set "_EMSVS_NO_WARNINGS=%MAKER_ENV_NOWARNINGS%"
set "_EMSVS_NO_ERRORS=%MAKER_ENV_NOERROS%"
set "_EMSVS_NO_INFO=%MAKER_ENV_NOINFOS%"

if "%MAKER_ENV_UNKNOWN_ARGS%" neq "" (echo warning: unknown argument/s '%MAKER_ENV_UNKNOWN_ARGS%')
if "%MAKER_ENV_UNKNOWN_SWITHCES%" neq "" (echo warning: unknown switch/es '%MAKER_ENV_UNKNOWN_SWITHCES%')

if "%_EMSVS_TGT_ARCHITECTURE%" equ "amd64" (set "_EMSVS_TGT_ARCHITECTURE=x64")
if "%_EMSVS_TGT_ARCHITECTURE%" neq "" goto :test_msvs
if "%_EMSVS_NO_ERRORS%" equ "" echo error: no target architecture specified in command line arguments
exit /b 1

:test_msvs
rem validate msvs
call "%MAKER_BUILD%\validate_msvs.bat" %_EMSVS_TGT_VERSION% 1>nul
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
if "%_EMSVS_NO_INFO%" equ "" echo using: MSVS %MSVS_VERSION% (VS%VSCMD_VER:~0,2%) for %MSVS_TARGET_ARCHITECTURE%
set _EMSVS_TGT_ARCHITECTURE=
set _EMSVS_TGT_VERSION=
set _EMSVS_NO_WARNINGS=
set _EMSVS_NO_ERRORS=
set _EMSVS_NO_INFO=
exit /b 0
