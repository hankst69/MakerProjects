@echo off
rem validate choco
set "_SCRIPT_ROOT=%~dp0"
set CHOCO_VERSION=
set CHOCO_VERSION_MAJOR=
set CHOCO_VERSION_MINOR=
set CHOCO_VERSION_PATCH=

set _CHOCO_TGT_VERSION=
set _CHOCO_TGT_VERSION_COMPARE=
set _CHOCO_NO_WARNINGS=
set _CHOCO_NO_ERRORS=
set _CHOCO_NO_INFO=
:param_loop
if /I "%~1" equ "--no_warnings" (set "_CHOCO_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_CHOCO_NO_ERRORS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_info"     (set "_CHOCO_NO_INFO=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_CHOCO_TGT_VERSION%" equ "" (set "_CHOCO_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo warning: unknown argument '%~1' &shift &goto :param_loop)

if "%_CHOCO_TGT_VERSION%" equ "" goto :validate_choco
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "GEQ" set "_CHOCO_TGT_VERSION_COMPARE=GEQ"
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "GEQ" set "_CHOCO_TGT_VERSION=%_CHOCO_TGT_VERSION:~3%"
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "GTR" set "_CHOCO_TGT_VERSION_COMPARE=GTR"
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "GTR" set "_CHOCO_TGT_VERSION=%_CHOCO_TGT_VERSION:~3%"
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "LEQ" set "_CHOCO_TGT_VERSION_COMPARE=LEQ"
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "LEQ" set "_CHOCO_TGT_VERSION=%_CHOCO_TGT_VERSION:~3%"
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "LSS" set "_CHOCO_TGT_VERSION_COMPARE=LSS"
if /I "%_CHOCO_TGT_VERSION:~0,3%" equ "LSS" set "_CHOCO_TGT_VERSION=%_CHOCO_TGT_VERSION:~3%"

:validate_choco
call which choco 1>nul 2>nul
if %ERRORLEVEL% equ 0 goto :choco_available
if "%_CHOCO_NO_ERRORS%" equ "" echo error: CHOCO not available
exit /b 1
:choco_available
set CHOCO_VERSION=
for /f "tokens=*" %%i in ('call choco --version') do if "%%i" neq "" set "CHOCO_VERSION=%%i"
if "%CHOCO_VERSION%" neq "" goto :choco_version_available
if "%_CHOCO_NO_ERRORS%" equ "" echo error: CHOCO version unknown
exit /b 2
:choco_version_available
rem echo choco %CHOCO_VERSION%
call "%_SCRIPT_ROOT%split_version.bat" "%CHOCO_VERSION%" 1>nul
if %ERRORLEVEL% equ 0 goto :choco_version_split_ok
if "%_CHOCO_NO_ERRORS%" equ "" echo error: CHOCO version '%CHOCO_VERSION%' not available or invalid
exit /b 3
:choco_version_split_ok
set "CHOCO_VERSION_MAJOR=%VERSION_MAJOR%"
set "CHOCO_VERSION_MINOR=%VERSION_MINOR%"
set "CHOCO_VERSION_PATCH=%VERSION_PATCH%"
:test_choco_version
if "%_CHOCO_TGT_VERSION%" equ "" goto :test_choco_success
call "%_SCRIPT_ROOT%compare_versions.bat" "%CHOCO_VERSION%" "%_CHOCO_TGT_VERSION%" "%_CHOCO_TGT_VERSION_COMPARE%" --no_info
if %ERRORLEVEL% equ 0 goto :test_choco_success
if "%_MSVS_NO_ERRORS%" equ "" echo error: CHOCO version '%CHOCO_VERSION%' does not match required version '%_CHOCO_TGT_VERSION%'
exit /b 4

:test_choco_success
if "%_CHOCO_NO_INFO%" equ "" echo using: choco %CHOCO_VERSION%
rem set CHOCO_VERSION=
rem set CHOCO_VERSION_MAJOR=
rem set CHOCO_VERSION_MINOR=
rem set CHOCO_VERSION_PATCH=
set _CHOCO_TGT_VERSION=
set _CHOCO_TGT_VERSION_COMPARE=
set _CHOCO_NO_WARNINGS=
set _CHOCO_NO_ERRORS=
set _CHOCO_NO_INFO=
set _SCRIPT_ROOT=
exit /b 0
