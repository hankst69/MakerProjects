@rem validate msvs:
@echo off
call "%~dp0\maker_env.bat" %* --silent
set "_VMSVS_NO_INFOS=%MAKER_ENV_NOINFOS%"

set MSVS_YEAR=
set MSVS_VERSION=
set MSVS_VERSION_MAJOR=
set MSVS_VERSION_MINOR=
set MSVS_VERSION_PATCH=
set MSVS_TARGET_ARCHITECTURE=

@call "%~dp0core\generic_validate.bat" "MSVS" "msbuild -version" "echo %VSCMD_VER%" "--tool_arch:%VSCMD_ARG_TGT_ARCH%" %* --no_info
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"
if /I "%MSVS_VERSION_MAJOR%" equ "18" (set "MSVS_YEAR=2026" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "17" (set "MSVS_YEAR=2022" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "16" (set "MSVS_YEAR=2019" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "15" (set "MSVS_YEAR=2017" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "14" (set "MSVS_YEAR=2015" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "12" (set "MSVS_YEAR=2013" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "11" (set "MSVS_YEAR=2012" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "10" (set "MSVS_YEAR=2010" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "9"  (set "MSVS_YEAR=2008" &goto :test_msvs_success)
if /I "%MSVS_VERSION_MAJOR%" equ "8"  (set "MSVS_YEAR=2005" &goto :test_msvs_success)
if "%MAKER_ENV_NOERRORS%" equ "" echo error 88: MSVS not available (unexpected major version '%MSVS_VERSION_MAJOR%')
exit /b 88

:test_msvs_success
if "%_VMSVS_NO_INFOS%" equ "" echo using: MSVS %MSVS_YEAR% (%MSVS_VERSION%) for %MSVS_TARGET_ARCHITECTURE%
set _VMSVS_NO_INFOS=
goto :EOF
