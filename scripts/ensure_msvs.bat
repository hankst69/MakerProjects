@echo off
call "%~dp0\maker_env.bat" %*

set "_EMSVS_TGT_ARCHITECTURE=%MAKER_ENV_ARCHITECTURE%"
set "_EMSVS_TGT_VERSION=%MAKER_ENV_VERSION_COMPARE%%MAKER_ENV_VERSION%"
set "_EMSVS_NO_WARNINGS=%MAKER_ENV_NOWARNINGS%"
set "_EMSVS_NO_ERRORS=%MAKER_ENV_NOERRORS%"
set "_EMSVS_NO_INFO=%MAKER_ENV_NOINFOS%"

if "%MAKER_ENV_UNKNOWN_ARGS%" neq "" (echo warning: unknown argument/s '%MAKER_ENV_UNKNOWN_ARGS%')
if "%MAKER_ENV_UNKNOWN_SWITHCES%" neq "" (echo warning: unknown switch/es '%MAKER_ENV_UNKNOWN_SWITHCES%')

if "%_EMSVS_TGT_ARCHITECTURE%" equ "amd64" (set "_EMSVS_TGT_ARCHITECTURE=x64")
if "%_EMSVS_TGT_ARCHITECTURE%" neq "" goto :test_msvs
rem if "%_EMSVS_NO_ERRORS%" equ "" echo error: no target architecture specified in command line arguments & exit /b 1
if "%_EMSVS_NO_WARNINGS%" equ "" echo warning: no target architecture specified - defaulting to 'x64'
set "_EMSVS_TGT_ARCHITECTURE=x64"


:test_msvs
rem validate msvs
call "%MAKER_BUILD%\validate_msvs.bat" %_EMSVS_TGT_VERSION% %MAKER_ENV_VERBOSE% --no_info
if "%ERRORLEVEL%" equ "0" goto :test_EMSVS_version_ok
:msvs_self_healing:
if "%_EMSVS_TGT_VERSION%" equ "2019" if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\vsdevcmd.bat" goto :init_vs2019
if "%_EMSVS_TGT_VERSION%" equ "2022" if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\vsdevcmd.bat" goto :init_vs2022
goto :test_msvs_failed

:init_vs2019
rem set "path=%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\Common7\Tools;%path%"
rem if "%__VSCMD_PREINIT_PATH%" neq "" set "path=%__VSCMD_PREINIT_PATH%"
rem set VCPKG_ROOT=
rem set VCIDEInstallDir=
rem set VCINSTALLDIR=
rem set VCToolsInstallDir=
rem set VCToolsRedistDir=
rem set VCToolsVersion=
rem set VSCMD_DEBUG=3
rem echo on
call "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\vsdevcmd.bat"
goto :test_msvs_again
:init_vs2022
call "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\vsdevcmd.bat"
goto :test_msvs_again

:test_msvs_again
rem validate msvs
call "%MAKER_BUILD%\validate_msvs.bat" %_EMSVS_TGT_VERSION% %MAKER_ENV_VERBOSE% --no_info
if "%ERRORLEVEL%" equ "0" goto :test_EMSVS_version_ok
:test_msvs_failed
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
