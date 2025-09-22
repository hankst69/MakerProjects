@echo off
set VERSION_MAJOR=
set VERSION_MINOR=
set VERSION_PATCH=

set "_SPLIT_SCRIPT_NAME=_%~n0"
set "_SPLIT_SCRIPT_NAME=_split"
set _SPLIT_TGT_VERSION=
set _SPLIT_TGT_COMPARE=
set _SPLIT_NO_WARNINGS=
set _SPLIT_NO_ERRORS=
set _SPLIT_NO_INFO=
:param_loop
if /I "%~1" equ "--no_warnings" (set "_SPLIT_NO_WARNINGS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_errors"   (set "_SPLIT_NO_ERRORS=%~1" &shift &goto :param_loop)
if /I "%~1" equ "--no_info"     (set "_SPLIT_NO_INFO=%~1" &shift &goto :param_loop)
if "%~1" neq "" if "%_SPLIT_TGT_VERSION%" equ "" (set "_SPLIT_TGT_VERSION=%~1" &shift &goto :param_loop)
if "%~1" neq "" (echo warning: unknown argument '%~1' &shift &goto :param_loop)

rem extract compare mode from version
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "GEQ" set "_SPLIT_TGT_COMPARE=GEQ"
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "GEQ" set "_SPLIT_TGT_VERSION=%_SPLIT_TGT_VERSION:~3%"
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "GTR" set "_SPLIT_TGT_COMPARE=GTR"
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "GTR" set "_SPLIT_TGT_VERSION=%_SPLIT_TGT_VERSION:~3%"
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "LEQ" set "_SPLIT_TGT_COMPARE=LEQ"
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "LEQ" set "_SPLIT_TGT_VERSION=%_SPLIT_TGT_VERSION:~3%"
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "LSS" set "_SPLIT_TGT_COMPARE=LSS"
if /I "%_SPLIT_TGT_VERSION:~0,3%" equ "LSS" set "_SPLIT_TGT_VERSION=%_SPLIT_TGT_VERSION:~3%"

if /I "%_SPLIT_TGT_VERSION:~0,1%" equ "v" set "_SPLIT_TGT_VERSION=%_SPLIT_TGT_VERSION:~1%"
if "%_SPLIT_TGT_VERSION%" equ "" (echo error 1%_SPLIT_SCRIPT_NAME%: missing argument ^<tgt_version^> &exit /b 1)

for /f "tokens=1,2,3 delims=." %%i in ("%_SPLIT_TGT_VERSION%") do set VERSION_MAJOR=%%~i
for /f "tokens=1,2,3 delims=." %%i in ("%_SPLIT_TGT_VERSION%") do set VERSION_MINOR=%%~j
for /f "tokens=1,2,3 delims=." %%i in ("%_SPLIT_TGT_VERSION%") do set VERSION_PATCH=%%~k

if "%VERSION_MAJOR%" neq "" goto :version_major_ok
if "%_SPLIT_NO_ERRORS%" equ "" echo error 2%_SPLIT_SCRIPT_NAME%: MAJOR_VERSION could not be derived from given version '%_SPLIT_TGT_VERSION%'
exit /b 2

:version_major_ok
if "%VERSION_MINOR%" neq "" goto :version_minor_ok
if "%_SPLIT_NO_WARNINGS%" equ "" echo warning%_SPLIT_SCRIPT_NAME%: MINOR_VERSION could not be derived from given version '%_SPLIT_TGT_VERSION%'
:version_minor_ok
if "%VERSION_PATCH%" neq "" goto :version_patch_ok
if "%_SPLIT_NO_WARNINGS%" equ "" echo warning%_SPLIT_SCRIPT_NAME%: PATCH_VERSION could not be derived from given version '%_SPLIT_TGT_VERSION%'
:version_patch_ok

set VERSION_COMPARE=%_SPLIT_TGT_COMPARE%
set VERSION=%VERSION_MAJOR%.%VERSION_MINOR%.%VERSION_PATCH%
if "%VERSION_PATCH%" equ "" set VERSION=%VERSION_MAJOR%.%VERSION_MINOR%
if "%VERSION_MINOR%.%VERSION_PATCH%" equ "" set VERSION=%VERSION_MAJOR%

if "%_SPLIT_NO_INFO%" equ "" echo using: version %VERSION%
set _SPLIT_SCRIPT_NAME=
set _SPLIT_TGT_VERSION=
set _SPLIT_TGT_COMPARE=
set _SPLIT_NO_WARNINGS=
set _SPLIT_NO_ERRORS=
set _SPLIT_NO_INFO=
exit /b 0
