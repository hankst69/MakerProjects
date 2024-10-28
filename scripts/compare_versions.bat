@echo off
set "_SCRIPT_ROOT=%~dp0"

set _COMPARE_SRC_VERSION_MAJOR=
set _COMPARE_SRC_VERSION_MINOR=
set _COMPARE_SRC_VERSION_PATCH=
set _COMPARE_TGT_VERSION_MAJOR=
set _COMPARE_TGT_VERSION_MINOR=
set _COMPARE_TGT_VERSION_PATCH=

set _COMPARE_SRC_VERSION=
set _COMPARE_TGT_VERSION=
set _COMPARE_VERSION_MODE=
set _COMPARE_NO_WARNINGS=
set _COMPARE_NO_ERRORS=
set _COMPARE_NO_INFO=
:param_loop
if /I "%~1" equ "--no_warnings" (set "_COMPARE_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_COMPARE_NO_ERRORS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_info"     (set "_COMPARE_NO_INFO=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_COMPARE_SRC_VERSION%"  equ "" (set "_COMPARE_SRC_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_COMPARE_TGT_VERSION%"  equ "" (set "_COMPARE_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_COMPARE_VERSION_MODE%" equ "" (set "_COMPARE_VERSION_MODE=%~1" &shift &goto :param_loop)
if "%~1" neq ""         (echo warning: unknown argument '%~1' &shift &goto :param_loop)

if "%_COMPARE_SRC_VERSION%"  equ "" echo error: missing argument ^<src_version^>
if "%_COMPARE_SRC_VERSION%"  equ "" exit /b 1
if "%_COMPARE_TGT_VERSION%" equ "" echo error: missing argument ^<tgt_version^>
if "%_COMPARE_TGT_VERSION%" equ "" exit /b 2

if "%_COMPARE_VERSION_MODE%" equ "" set _COMPARE_VERSION_MODE=EQU
if /I "%_COMPARE_VERSION_MODE%" equ "EQU" goto :compare_versions
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" goto :compare_versions
if /I "%_COMPARE_VERSION_MODE%" equ "GEQ" goto :compare_versions
if /I "%_COMPARE_VERSION_MODE%" equ "NEQ" goto :compare_versions
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" goto :compare_versions
if /I "%_COMPARE_VERSION_MODE%" equ "LEQ" goto :compare_versions
echo error: invalid value '%_COMPARE_VERSION_MODE%' for optional argument [version_compare]
exit /b 3

:compare_versions
call "%_SCRIPT_ROOT%split_version.bat" "%_COMPARE_SRC_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_COMPARE_SRC_VERSION_ok
if "%_COMPARE_NO_ERRORS%" equ "" echo error: target version '%_COMPARE_SRC_VERSION%' not available or invalid
exit /b 4
:split_COMPARE_SRC_VERSION_ok
set "_COMPARE_SRC_VERSION_MAJOR=%VERSION_MAJOR%"
set "_COMPARE_SRC_VERSION_MINOR=%VERSION_MINOR%"
set "_COMPARE_SRC_VERSION_PATCH=%VERSION_PATCH%"

call "%_SCRIPT_ROOT%split_version.bat" "%_COMPARE_TGT_VERSION%" 1>NUL
if "%ERRORLEVEL%" equ "0" goto :split_COMPARE_TGT_VERSION_ok
if "%_COMPARE_NO_ERRORS%" equ "" echo error: target version '%_COMPARE_TGT_VERSION%' not available or invalid
exit /b 5
:split_COMPARE_TGT_VERSION_ok
set "_COMPARE_TGT_VERSION_MAJOR=%VERSION_MAJOR%"
set "_COMPARE_TGT_VERSION_MINOR=%VERSION_MINOR%"
set "_COMPARE_TGT_VERSION_PATCH=%VERSION_PATCH%"

rem already ensured in split_version.bat
rem if "%_COMPARE_SRC_VERSION_MAJOR%" equ "" set _COMPARE_SRC_VERSION_MAJOR=0
rem if "%_COMPARE_SRC_VERSION_MINOR%" equ "" set _COMPARE_SRC_VERSION_MINOR=0
rem if "%_COMPARE_SRC_VERSION_PATCH%" equ "" set _COMPARE_SRC_VERSION_PATCH=0
rem if "%_COMPARE_TGT_VERSION_MAJOR%" equ "" set _COMPARE_TGT_VERSION_MAJOR=0
rem if "%_COMPARE_TGT_VERSION_MINOR%" equ "" set _COMPARE_TGT_VERSION_MINOR=0
rem if "%_COMPARE_TGT_VERSION_PATCH%" equ "" set _COMPARE_TGT_VERSION_PATCH=0

:compare_major_version
if "%_COMPARE_SRC_VERSION_MAJOR%" %_COMPARE_VERSION_MODE% "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_major_version_ok
:compare_major_version_failed
rem support: compare_versions.bat 3.3.1 3.2.2 GTR
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" if "%_COMPARE_SRC_VERSION_MAJOR%" EQU "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_minor_version
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" if "%_COMPARE_SRC_VERSION_MAJOR%" EQU "%_COMPARE_TGT_VERSION_MAJOR%" goto :compare_minor_version
if "%_COMPARE_NO_ERRORS%" equ "" echo error: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.x.x %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
exit /b 6
:compare_major_version_ok
if "%_COMPARE_SRC_VERSION_MAJOR%" NEQ "%_COMPARE_TGT_VERSION_MAJOR%" goto :version_compare_success

:compare_minor_version
if "%_COMPARE_SRC_VERSION_MINOR%" %_COMPARE_VERSION_MODE% "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_minor_version_ok
:compare_minor_version_failed
rem support: compare_versions.bat 3.3.1 3.2.2 GTR
if /I "%_COMPARE_VERSION_MODE%" equ "GTR" if "%_COMPARE_SRC_VERSION_MINOR%" EQU "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_patch_version
if /I "%_COMPARE_VERSION_MODE%" equ "LSS" if "%_COMPARE_SRC_VERSION_MINOR%" EQU "%_COMPARE_TGT_VERSION_MINOR%" goto :compare_patch_version
if "%_COMPARE_NO_ERRORS%" equ "" echo error: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.x %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
exit /b 7
:compare_minor_version_ok
if "%_COMPARE_SRC_VERSION_MINOR%" NEQ "%_COMPARE_TGT_VERSION_MINOR%" goto :version_compare_success

:compare_patch_version
if "%_COMPARE_SRC_VERSION_PATCH%" %_COMPARE_VERSION_MODE% "%_COMPARE_TGT_VERSION_PATCH%" goto :version_compare_success
if "%_COMPARE_NO_ERRORS%" equ "" echo error: version compare failed, requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' not met
exit /b 8

:version_compare_success
if "%_COMPARE_NO_INFO%" equ "" echo version requirement '%_COMPARE_SRC_VERSION_MAJOR%.%_COMPARE_SRC_VERSION_MINOR%.%_COMPARE_SRC_VERSION_PATCH% %_COMPARE_VERSION_MODE% %_COMPARE_TGT_VERSION_MAJOR%.%_COMPARE_TGT_VERSION_MINOR%.%_COMPARE_TGT_VERSION_PATCH%' met
rem echo using: msvs %MSVS_YEAR% (VS%MSVS_VERSION%) for %MSVS_TARGET_ARCHITECTURE%
set _COMPARE_SRC_VERSION_MAJOR=
set _COMPARE_SRC_VERSION_MINOR=
set _COMPARE_SRC_VERSION_PATCH=
set _COMPARE_TGT_VERSION_MAJOR=
set _COMPARE_TGT_VERSION_MINOR=
set _COMPARE_TGT_VERSION_PATCH=
set _COMPARE_SRC_VERSION=
set _COMPARE_TGT_VERSION=
set _COMPARE_VERSION_MODE=
set _COMPARE_NO_WARNINGS=
set _COMPARE_NO_ERRORS=
set _COMPARE_NO_INFO=
exit /b 0
