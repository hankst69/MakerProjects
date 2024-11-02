@echo off
rem validate msvs
set "_SCRIPT_ROOT=%~dp0"
set MSVS_TARGET_ARCHITECTURE=
set MSVS_YEAR=
set MSVS_VERSION=
set MSVS_VERSION_MAJOR=
set MSVS_VERSION_MINOR=
set MSVS_VERSION_PATCH=

set _MSVS_TGT_ARCHITECTURE=
set _MSVS_TGT_VERSION=
set _MSVS_TGT_VERSION_COMPARE=
set _MSVS_NO_WARNINGS=
set _MSVS_NO_ERRORS=
set _MSVS_NO_INFO=
:param_loop
if /I "%~1" equ "x86"   (set "_MSVS_TGT_ARCHITECTURE=x86" &shift &goto :param_loop)
if /I "%~1" equ "x64"   (set "_MSVS_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "amd64" (set "_MSVS_TGT_ARCHITECTURE=x64" &shift &goto :param_loop)
if /I "%~1" equ "--no_warnings" (set "_MSVS_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_MSVS_NO_ERRORS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_info"     (set "_MSVS_NO_INFO=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_MSVS_TGT_VERSION%" equ "" (set "_MSVS_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo warning: unknown argument '%~1' &shift &goto :param_loop)

if "%_MSVS_TGT_VERSION%" equ "" goto :validate_msvs
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "GEQ" set "_MSVS_TGT_VERSION_COMPARE=GEQ"
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "GEQ" set "_MSVS_TGT_VERSION=%_MSVS_TGT_VERSION:~3%"
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "GTR" set "_MSVS_TGT_VERSION_COMPARE=GTR"
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "GTR" set "_MSVS_TGT_VERSION=%_MSVS_TGT_VERSION:~3%"
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "LEQ" set "_MSVS_TGT_VERSION_COMPARE=LEQ"
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "LEQ" set "_MSVS_TGT_VERSION=%_MSVS_TGT_VERSION:~3%"
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "LSS" set "_MSVS_TGT_VERSION_COMPARE=LSS"
if /I "%_MSVS_TGT_VERSION:~0,3%" equ "LSS" set "_MSVS_TGT_VERSION=%_MSVS_TGT_VERSION:~3%"

rem https://en.wikipedia.org/wiki/Microsoft_Visual_C%2B%2B#Internal_version_numbering
if "%_MSVS_TGT_VERSION%" equ "2022" (set "_MSVS_TGT_VERSION=17" &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2019" (set "_MSVS_TGT_VERSION=16" &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2017" (set "_MSVS_TGT_VERSION=15" &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2015" (set "_MSVS_TGT_VERSION=14" &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2013" (set "_MSVS_TGT_VERSION=12" &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2012" (set "_MSVS_TGT_VERSION=11" &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2010" (set "_MSVS_TGT_VERSION=10" &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2008" (set "_MSVS_TGT_VERSION=9"  &goto :tgt_version_normalized)
if "%_MSVS_TGT_VERSION%" equ "2005" (set "_MSVS_TGT_VERSION=8"  &goto :tgt_version_normalized)
:tgt_version_normalized


:validate_msvs
set "MSVS_TARGET_ARCHITECTURE=%VSCMD_ARG_TGT_ARCH%"
set "MSVS_YEAR="
set "MSVS_VERSION=%VSCMD_VER%"
call "%_SCRIPT_ROOT%split_version.bat" "%MSVS_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_msvs_version_ok
if "%_MSVS_NO_ERRORS%" equ "" echo error: MSVS version '%MSVS_VERSION%' not available or invalid
exit /b 2

:split_msvs_version_ok
set "MSVS_VERSION_MAJOR=%VERSION_MAJOR%"
set "MSVS_VERSION_MINOR=%VERSION_MINOR%"
set "MSVS_VERSION_PATCH=%VERSION_PATCH%"

if /I "%MSVS_VERSION_MAJOR%" equ "17" (set "MSVS_YEAR=2022" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "16" (set "MSVS_YEAR=2019" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "15" (set "MSVS_YEAR=2017" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "14" (set "MSVS_YEAR=2015" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "12" (set "MSVS_YEAR=2013" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "11" (set "MSVS_YEAR=2012" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "10" (set "MSVS_YEAR=2010" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "9"  (set "MSVS_YEAR=2008" &goto :test_msvs_version)
if /I "%MSVS_VERSION_MAJOR%" equ "8"  (set "MSVS_YEAR=2005" &goto :test_msvs_version)
if "%_MSVS_NO_ERRORS%" equ "" echo error: MSVS not available (unexpected major version '%MSVS_VERSION_MAJOR%')
exit /b 3

:test_msvs_version
if "%_MSVS_TGT_VERSION%" equ "" goto :test_msvs_tgt_architecture
call "%_SCRIPT_ROOT%compare_versions.bat" "%MSVS_VERSION%" "%_MSVS_TGT_VERSION%" "%_MSVS_TGT_VERSION_COMPARE%" --no_info
if "%ERRORLEVEL%" equ "0" goto :test_msvs_tgt_architecture
if "%_MSVS_NO_ERRORS%" equ "" echo error: MSVS version '%MSVS_VERSION%' does not match required version '%_MSVS_TGT_VERSION%'
exit /b 4

:test_msvs_tgt_architecture
if "%_MSVS_TGT_ARCHITECTURE%" equ "" goto :test_msvs_success
if /I "%MSVS_TARGET_ARCHITECTURE%" equ "%_MSVS_TGT_ARCHITECTURE%" goto :test_msvs_success
if "%_MSVS_NO_ERRORS%" equ "" echo error: MSVS target architecture '%MSVS_TARGET_ARCHITECTURE%' does not match required type '%_MSVS_TGT_ARCHITECTURE%'
exit /b 5


:test_msvs_success
if "%_MSVS_NO_INFO%" equ "" echo using: msvs %MSVS_YEAR% (vs %MSVS_VERSION%) for %MSVS_TARGET_ARCHITECTURE%

set _MSVS_TGT_ARCHITECTURE=
set _MSVS_TGT_VERSION=
set _MSVS_TGT_VERSION_COMPARE=
set _MSVS_NO_WARNINGS=
set _MSVS_NO_ERRORS=
set _MSVS_NO_INFO=
set _SCRIPT_ROOT=
exit /b 0
