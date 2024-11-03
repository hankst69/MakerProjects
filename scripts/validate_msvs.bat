@rem validate msvs:
@echo off
set MSVS_YEAR=
set MSVS_VERSION=
set MSVS_VERSION_MAJOR=
set MSVS_VERSION_MINOR=
set MSVS_VERSION_PATCH=
set MSVS_TARGET_ARCHITECTURE=

call "%~dp0\validate.bat" "MSVS" "msbuild -version" "echo %VSCMD_VER%" "--tool_arch:%VSCMD_ARG_TGT_ARCH%" %*
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"
if /I "%MSVS_VERSION_MAJOR%" equ "17" (set "MSVS_YEAR=2022" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "16" (set "MSVS_YEAR=2019" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "15" (set "MSVS_YEAR=2017" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "14" (set "MSVS_YEAR=2015" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "12" (set "MSVS_YEAR=2013" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "11" (set "MSVS_YEAR=2012" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "10" (set "MSVS_YEAR=2010" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "9"  (set "MSVS_YEAR=2008" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "8"  (set "MSVS_YEAR=2005" &goto :test_msvs_version)
if "%_MSVS_NO_ERRORS%" equ "" echo error 88: MSVS not available (unexpected major version '%MSVS_VERSION_MAJOR%')
exit /b 88

:test_msvs_version
:test_msvs_success
rem if "%_MSVS_NO_INFO%" equ "" echo using: msvs %MSVS_YEAR% (vs %MSVS_VERSION%) for %MSVS_TARGET_ARCHITECTURE%
goto :EOF
